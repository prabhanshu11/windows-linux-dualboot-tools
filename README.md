   # Windows Linux Dual Boot Tools

   Scripts and tools to make Windows and Linux dual-boot systems work better together.

   ## Simple Windows Time Fix for Dual Boot

   ### The Problem
   When dual-booting Windows with Linux, time synchronization issues can occur because Linux uses UTC for the hardware clock while Windows uses local time by default.

   ### Usage
   1. Download `SimpleWindowsTimeFixForDualBoot.ps1`
   2. Right-click the file and select "Run with PowerShell" 
   3. If prompted, confirm to run as administrator
   4. The script will:
      - Set Windows to use UTC for the hardware clock
      - Force time synchronization
      - Create a startup task to maintain the fix

   ### How to run from GitHub directly
   Run this in PowerShell as administrator:
   ```powershell
   irm https://raw.githubusercontent.com/YourUsername/windows-linux-dualboot-tools/main/SimpleWindowsTimeFixForDualBoot.ps1 | iex
   ```
