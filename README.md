# iCloudFix

**iCloudFix** Fix the issue of iCloud Windows App having high CPU consumption during idling/display off. By leveraging Task Scheduler, iCloudFix closes the iCloud UI during system idle periods, reducing CPU load while preserving core iCloud functionality.

## Table of Contents
- [Background](#background)
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [License](#license)

## Background

One day, I discover my PC fans always spin much louder during idle screen off. And then I found there is 30% increase in CPU usage and 20 Watts increase in power consumption on my PC, during **display OFF idle**. Using System Informer, I found out the issue: iCloud application on Windows (*`iCloudHome.exe`*) consumes excessive CPU resources, due to its iCloudHome UI thread (**dwmcorei.dll!LiftedCompositionEngine_Uninitialize**) keep running and use lots of CPU cycle . 

This issue is most noticeable in the following cases:
- **Display Off or Absent**: When the display is turned off or unavailable (e.g., in virtual machines or remote desktops), the iCloud UI attempts to render to a non-existent display, causing high CPU usage.
- **Auto-Run During Logon**: iCloud may launch automatically at logon but fail to minimize its UI, leading to persistent CPU consumption.

iCloudFix mitigates the issue, by closing the iCloud UI (Only keep iCloud services running without UI) during system idle periods, optimizing resource usage without disrupting functionality.

## Features
- **Automatic UI Termination**: Force closes the iCloudHome UI, when the system is idle for more than 1 minute, reducing CPU usage without affecting iCloud services.

- **Lightweight Implementation**: Uses minimal resources via a simple VBScript launcher and simple PowerShell script, executed through Windows own Task Scheduler.

- **Task Scheduler Integration**: Configured to run indefinitely during idle conditions and restart if idle state resumes.

- **Logging**: Maintains a log file at  %APPDATA%\iCloudFix\iCloudFix.log  (capped at 20KB) for debugging.

- **Customizable Settings**: Easily adjust Task Scheduler parameters (e.g., idle duration, execution time) via the XML configuration.


## Installation

Follow these steps to install and configure iCloudFix:

1. **Download the Project**:
   - Download the iCloudFix folder as a ZIP file from the repository/release.
   - Extract the ZIP to a directory of your choice
   - Do not change the extracted folder structure before running Installer.bat


2. **Run the Installer**:
   - Locate **Installer.bat** in the extracted folder.
   - Right-click **Installer.bat** and select **Run as Administrator**.
   - Confirm the User Account Control (UAC) prompt by clicking **Yes**.
   - The Installer.bat will install by doing following:     
     - Copy *Launch.vbs* and *Fix.ps1* to *%APPDATA%\iCloudFix*.
     - Create a Task Scheduler task named *"iCloudFix"*.
     - Set up logging at **%APPDATA%\iCloudFix\iCloudFix.log*.

3. **Verify Installation**:
   - Upon completion, the script will display **"Task scheduler setup complete."**
   - The task will then automatically run when the system is idle for 1 minute.

### Uninstall
Uninstall by removing the Scheduled Task in Taskschedular and your Task Schedular folder.


## Configuration

The Task Scheduler settings are defined in *iCloudFix_Settings.xml*. You can modify these settings before running *Installer.bat* to customize the task behavior. Below is a detailed guide to key settings and how to adjust them.

### Key Task Scheduler Settings
The following settings can be modified in *iCloudFix_Settings.xml* before running *Installer.bat*:

#### How to Modify Settings
1. Open *iCloudFix_Settings.xml* in a text editor
2. Locate and modify the desired settings
3. Save the file
4. Re-run *Installer.bat* as Administrator to apply changes

#### Core Settings
- **Idle Duration** (`<IdleSettings><Duration>`):
  - Specifies how long the system must be idle before the task runs
  - **Default**: *PT1M* (1 minute)
  - **Format**: *n* is a number, *PTnH* for hours, *PTnM* for minutes, *PTnS* for seconds  

- **Priority** (`<Priority>`):
  - Sets task process priority level
  - **Default**: *10* (Idle, Lowest prority)  
  - **Format**: Number between *0-10*
  - **Values**:
    - *0-1*: Real-time (use with caution)
    - *2-3*: High
    - *4-6*: Normal
    - *7-9*: Below normal
    - *10*: Idle  
  - **Recommendation**: Use 10 for background tasks, 4-6 for normal operations

- **Wait Timeout** (`<IdleSettings><WaitTimeout>`):
  - Maximum time to wait for idle conditions
  - **Default**: *PT0S* (In iCloudFix, have to wait any idle indefinitely)
  - **Format**: *n* is a number, *PTnH* for hours, *PTnM* for minutes, *PTnS* for seconds, *PT0S* for no limit

- **Restart on Idle** (`<IdleSettings><RestartOnIdle>`):
  - Controls whether task restarts when system becomes idle again, if it is pause by ended idle
  - **Default**: *false* (Have to be false in iCloudFix)

- **Execution Time Limit** (`<Settings><ExecutionTimeLimit>`):
  - Maximum allowed runtime before task termination
  - **Default**: *PT60S* (Normally iCloudFix will finish within a seconds, I set to 60 seconds just in case prority is too low and get on hold by other high cpu demand process)
  - **Format**: *n* is a number, *PTnH* for hours, *PTnM* for minutes, *PTnS* for seconds, *PT0S* for no limit
  
- **Multiple Instances Policy** (`<MultipleInstancesPolicy>`):
  - Controls behavior when new instance triggers while task is running
  - **Default**: *StopExisting* (Remove other iCloudFix before begin new iCloudFix if it is stuck)
  - **Options**:
    - *Parallel*: Allow multiple concurrent instances
    - *Queue*: Run new instances after current completes
    - *IgnoreNew*: Skip new triggers if instance running
    - *StopExisting*: Stop current and start new instance


## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---
**Author**: Zenqlo  
**Last Updated**: May 15, 2025
