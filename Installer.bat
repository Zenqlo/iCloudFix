REM Author: Zenqlo
REM Version: v0.0.2
REM Date: 2025-05-16
REM Description: This script installs the iCloudFix task scheduler.

@ECHO off
REM Create task scheduler folder
echo.

if not exist "%APPDATA%\iCloudFix" (
    mkdir "%APPDATA%\iCloudFix"
    echo Created task scheduler folder: "%APPDATA%\iCloudFix"
) else (
    echo Task scheduler folder already exists
)
echo.




REM Copy script file
if exist "%APPDATA%\iCloudFix\Fix.ps1" (
    echo Found existing PS1 script, replacing it with new version...
    del "%APPDATA%\iCloudFix\Fix.ps1"
)
copy "%~dp0TaskScheduler\Fix.ps1" "%APPDATA%\iCloudFix\Fix.ps1" /Y
echo %APPDATA%\iCloudFix\Fix.ps1




REM Copy launch file
if exist "%APPDATA%\iCloudFix\Launch.vbs" (
    echo Found existing VBS launch file, replacing it with new version...
    del "%APPDATA%\iCloudFix\Launch.vbs"
)
copy "%~dp0TaskScheduler\Launch.vbs" "%APPDATA%\iCloudFix\Launch.vbs" /Y
echo %APPDATA%\iCloudFix\Launch.vbs



REM Create task scheduler task
echo.
schtasks /create /tn "iCloudFix" /xml "%~dp0\iCloudFix_Settings.xml" /F
echo.
if %ERRORLEVEL%==0 (
    echo Task scheduler setup complete.
) else (
    echo ERROR: Task creation failed with code %ERRORLEVEL%.
    if %ERRORLEVEL%==1 (
        echo DESCRIPTION: Access denied or invalid arguments. Run as Administrator and verify XML syntax.
    ) else if %ERRORLEVEL%==2 (
        echo DESCRIPTION: The system cannot find the file specified. Check if iCloudFix_Settings.xml exists in the script directory.
    ) else if %ERRORLEVEL%==5 (
        echo DESCRIPTION: Access denied. Run the script as Administrator.
    ) else if %ERRORLEVEL%==87 (
        echo DESCRIPTION: Invalid parameter or XML format. Check iCloudFix_Settings.xml for errors.
    ) else if %ERRORLEVEL%==1355 (
        echo DESCRIPTION: Invalid user or group in XML. Verify the Principal section.
    ) else (
        echo DESCRIPTION: Unknown error. Verify the XML file and Task Scheduler permissions.
    )
)
echo.

pause







