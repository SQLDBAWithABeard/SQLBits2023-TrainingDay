# SQLBits2023-TrainingDay
Where Jess and Rob do Training Day for SQLBits 2023 and don't get Covid (or any other illness/injury that means only one of them is available)

## Interact with the lab

```PowerShell
Get-Lab -List

Import-Lab SQLBits2023-TrainingDay -NoValidation

Start-LabVM -All

Stop-Lab -All -Wait
```

## Copy the lab files from the repo into the automated lab folder

```PowerShell
#Delete files in lab folder
Get-ChildItem C:\ProgramData\AutomatedLab\Labs\ SQLBits2023-TrainingDay -Recurse | rm -Recurse -Confirm:$false

# copy new stuff
Copy-Item .\Environment\AutomatedLab\SQLBits2023-TrainingDay\ C:\ProgramData\AutomatedLab\Labs\ -Recurse
```
