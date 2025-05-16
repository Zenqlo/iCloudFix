' Author: Zenqlo
' Version: v0.0.2
' Date: 2025-05-16
' Description: This script fixes the high CPU usage of a program UI when display is off.

psScript = "Fix.ps1"

Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
scriptdir = fso.GetParentFolderName(WScript.ScriptFullName)
psScript = fso.BuildPath(scriptdir, psScript)
WshShell.Run "powershell -ExecutionPolicy Bypass -File """ & psScript & """", 0, False 
