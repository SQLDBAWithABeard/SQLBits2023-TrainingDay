# Notes as Jess is forgetful

This is a dump of stuff and notes - not for prime time
Wondered if I should call it 'Effing around & finding out' - but I don't think that relates to learning...

- run the bicep deployment to get sql vm & jump box
- on jumpbox
  - ran the `RunOnTheJumpBox.ps` script to get tools and modules
  - connect in ADS to `bits-sqlvm-1` with sqladmin login
    - connect with windows auth
    - change trust server cert option to true
    - set trustedhosts so we can use WMI
    `Set-Item WSMan:localhost\client\trustedhosts -value *`

![connection settings](https://user-images.githubusercontent.com/981370/212472314-d8ef2577-bc20-4f1a-9358-b00086728805.png)

![connected](https://user-images.githubusercontent.com/981370/212472310-6f111429-04c6-43ec-8248-d9c7e199bb2e.png)

Or connect with dbatools
![connect with dbatools](https://user-images.githubusercontent.com/981370/212472342-ad334915-2d98-4af3-b6cb-99459450d70e.png)

## patching with kbupdate

```PowerShell
Install-Module kbupdate
Get-KbNeededUpdate -ComputerName bits-sqlvm-1
```

```text
ComputerName      : bits-sqlvm-1
Title             : 2021-01 Update for Windows Server 2019 for x64-based Systems (KB4589208)
KBUpdate          : KB4589208
UpdateId          : 89e11227-761b-4396-bf37-37a2b641fa84
Description       : Install this update to resolve issues in Windows. For a complete listing of the issues that are
                    included in this update, see the associated Microsoft Knowledge Base article for more information.
                    After you install this item, you may have to restart your computer.
LastModified      :
RebootBehavior    : False
RequestsUserInput : False
NetworkRequired   : False
Link              : {https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2021/01/windows10.0
                    -kb4589208-v2-x64_c7af21cdf923f050a3dc8e7924c0245ee651da56.cab}
```
```PowerShell
## windows patch - but could do the same with SQL if we weren't already on the latest
Install-KbUpdate -ComputerName bits-sqlvm-1 -HotfixId KB4589208
```

```Text
Exception calling "Create" with "1" argument(s): "At line:3 char:29
+ ...             Import-DscResource -ModuleName xWindowsUpdate -ModuleVers ...
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Could not find the module '<xWindowsUpdate, 3.0.0>'."
    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
    + FullyQualifiedErrorId : ParseException
    + PSComputerName        : localhost



ComputerName : bits-sqlvm-1
Title        : 2021-01 Update for Windows 10 Version 1809 for x64-based Systems (KB4589208)
ID           : KB4589208
Status       : Install successful
FileName     : windows10.0-kb4589208-v2-x64_fa90a4bdc1da0f5758cdfa53c58187d9fc894fa0.msu

Exception calling "Create" with "1" argument(s): "At line:3 char:29
+ ...             Import-DscResource -ModuleName xWindowsUpdate -ModuleVers ...
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Could not find the module '<xWindowsUpdate, 3.0.0>'."
    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
    + FullyQualifiedErrorId : ParseException
    + PSComputerName        : localhost

ComputerName : bits-sqlvm-1
Title        : 2021-01 Update for Windows Server 2019 for x64-based Systems (KB4589208)
ID           : KB4589208
Status       : Install successful
FileName     : windows10.0-kb4589208-v2-x64_fa90a4bdc1da0f5758cdfa53c58187d9fc894fa0.msu

[13:20:36][<ScriptBlock><Process>] Downloaded files may still exist on your local drive and other servers as well, in the Downloads directory.
[13:20:36][<ScriptBlock><Process>] If you ran this as SYSTEM, the downloads will be in windows\system32\config\systemprofile.
```

Some errors - but it worked - TODO: check those errors

![patching magic](https://user-images.githubusercontent.com/981370/212473910-ef4c1d39-b8d6-446b-85cd-97cad213f8ad.png)

## archived notes

### to connect as sql login do this - but turned out not to need it

- then in the portal
  - enabled sql authentication & setup username & password (sqladmin - same password but twice)
- on jumpbox
  - connect in ADS to `bits-sqlvm-1` with sqladmin login
    - change trust server cert option to true
