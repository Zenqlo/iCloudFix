# Author: Zenqlo
# Version: v0.0.2
# Date: 2025-05-16
# Description: This script fixes the high CPU usage of a program UI when display is off.

# Create a log file in the script directory
$logFile = "iCloudFix.log"
$FixName = "iCloudFix"
$processName = 'iCloudHome'

# Create log file if it doesn't exist
$logPath = Join-Path $PSScriptRoot $logFile
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType File -Force | Out-Null
}

# Function to write to log
function Write-Log {    
    param($Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    # Check file size and limit to 20KB
    $logFile = Get-Item $logPath -ErrorAction SilentlyContinue
    if ($logFile -and $logFile.Length -gt 20KB) {        
        # Get last 100 lines using tail instead of reading entire file
        $tempFile = "$logPath.tmp"
        Get-Content -Path $logPath -Tail 100 | Set-Content -Path $tempFile
        Move-Item -Path $tempFile -Destination $logPath -Force
    }
    # Append new message directly without reading file
    Add-Content -Path $logPath -Value $logMessage
}

# Import necessary DLL
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class User32 {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);    

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int GetClassName(IntPtr hWnd, System.Text.StringBuilder lpClassName, int nMaxCount);
}
"@ | Out-Null


# Get process needs to be fixed
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue

# Check if process is found, if process not found, exit 
if ($null -eq $process) {    
    Write-Log "$($FixName) triggered, but $processName process not found"
    exit 0
}

# Process is found, try to fix
try {
    #Get target process id
    $targetProcessId = $process.Id
    $targetClass = "WinUIDesktopWin32WindowClass"
    $script:windowHandles = @()

    # More efficient callback using a script block
    $enumWindowCallback = {
        param($hwnd, $lparam)
        
        $processId = 0
        if ([User32]::GetWindowThreadProcessId($hwnd, [ref]$processId) -and 
            $processId -eq $targetProcessId) {
            
            $className = New-Object -TypeName System.Text.StringBuilder -ArgumentList 256
            if ([User32]::GetClassName($hwnd, $className, $className.Capacity) -gt 0 -and 
                $className.ToString() -eq $targetClass) {
                $script:windowHandles += $hwnd
            }
        }
        return $true
    }

    # Single call to enumerate windows
    [User32]::EnumWindows($enumWindowCallback -as [User32+EnumWindowsProc], [IntPtr]::Zero)

    # Official Windows state constants defined in User32.dll
    #$SW_HIDE = 0
    #$SW_SHOWNORMAL = 1
    #$SW_SHOWMINIMIZED = 2
    #$SW_SHOWMAXIMIZED = 3
    #$SW_SHOWNOACTIVATE = 4
    #$SW_SHOW = 5
    #$SW_MINIMIZE = 6
    #$SW_SHOWMINNOACTIVE = 7
    #$SW_SHOWNA = 8
    #$SW_RESTORE = 9
    #$SW_SHOWDEFAULT = 10
    #$SW_FORCEMINIMIZE = 11   
    
    #Fix all windows
    foreach ($windowHandle in $script:windowHandles) {
        
        # Set UI to be minimized
        [User32]::ShowWindow($windowHandle, 2)

        # Set UI to load UI correctly but not activate
        [User32]::ShowWindow($windowHandle, 4)

        # Set UI to close(hide) correctly  
        [User32]::ShowWindow($windowHandle, 0)
    
        Write-Log "$($FixName) triggered, $($process.Name) ProcessID: $($process.Id), WinUI: $($windowHandle), Correctly closed"
    }
}
catch {
    Write-Log "$($FixName) triggered. $($process.Name) ID: $($process.Id). Error occurred: $($_.Exception.Message)"
}