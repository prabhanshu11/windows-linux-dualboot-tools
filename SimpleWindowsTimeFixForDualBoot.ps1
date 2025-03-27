<#
.SYNOPSIS
    Fixes Windows time sync issues in dual-boot systems with Linux.
.DESCRIPTION
    Sets Windows to use UTC for hardware clock and fixes time synchronization.
    Automatically creates a scheduled task to run at system startup.
.NOTES
    Author: Dual Boot Time Fix
    Version: 1.1
    Date: 2023
#>

# Check for admin rights and self-elevate if needed
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Set window title
$host.UI.RawUI.WindowTitle = "Windows Time Fix for Dual Boot Systems"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "    Windows Time Fix for Dual Boot Systems" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Display current time
Write-Host "Current time before fix: $(Get-Date)" -ForegroundColor Yellow

# Configure Windows to use UTC time (like Linux)
Write-Host "`nSetting Windows to use UTC for hardware clock..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Value 1 -Type DWord

# Force time resynchronization
Write-Host "`nForcing time resynchronization..." -ForegroundColor Cyan
Start-Process -FilePath "w32tm.exe" -ArgumentList "/resync", "/force" -NoNewWindow -Wait

# Show time after fix
Write-Host "`nCurrent time after fix: $(Get-Date)" -ForegroundColor Green

# Create startup script - using CMD for better visibility
$startupScriptPath = "$env:SystemRoot\TimeFixDualBoot.cmd"
$startupScript = @'
@echo off
title Windows Time Sync for Dual Boot - Startup Fix
color 0B

echo =================================================
echo    Windows Time Sync for Dual Boot - Startup Fix
echo =================================================
echo.

echo Current time before fix: %date% %time%
echo.

echo Setting Windows to use UTC for hardware clock...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f > nul
if %errorlevel% equ 0 (
    echo [SUCCESS] Registry key set successfully.
) else (
    echo [ERROR] Failed to set registry key.
)
echo.

echo Forcing time resynchronization...
w32tm /resync /force
echo.

echo Current time after fix: %date% %time%
echo.
echo Time synchronization completed!
echo.

echo Press any key to exit...
pause > nul
'@

# Save the startup script
Write-Host "`nCreating startup script at $startupScriptPath" -ForegroundColor Cyan
$startupScript | Out-File -FilePath $startupScriptPath -Encoding ascii -Force

# Create scheduled task
$taskName = "Fix Windows Time for Dual Boot"
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($taskExists) {
    Write-Host "`nUpdating existing scheduled task..." -ForegroundColor Cyan
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$startupScriptPath`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Fixes Windows time when dual-booting with Linux by using UTC for hardware clock" -Force

Write-Host "`nScheduled task created successfully!" -ForegroundColor Green

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "Fix applied successfully!" -ForegroundColor Green
Write-Host "- Windows now uses UTC for hardware clock" -ForegroundColor White
Write-Host "- Time synchronization task will run at each startup" -ForegroundColor White
Write-Host "- The startup task will show a window with progress" -ForegroundColor White
Write-Host "==================================================" -ForegroundColor Cyan

# Wait for user input before exiting
Write-Host "`nPress any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
