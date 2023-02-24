# Managing Estate

> What if we go through dbachecks and find a bunch of 'broken' stuff then this section can be fixing some of that at scale
> install whoisactive on every machine
> rename\disable all sa accounts
> set auto shrink off across the estate

- Setting up Ola maintenance jobs?
- Encrypting some databases?
- Configuring and managing SQL Server instances (e.g. using SQL Server Configuration Manager)
- Monitoring and troubleshooting SQL Server instances

- dbachecks (stuff that's in pester v5)
  - Instance
    - Configurations
      - Default trace
      - OLE Automaition
      - DAC
      - cross db ownership chaining
      - adhoc workload
      - sa login renamed\disabled
      - clr
      - whoisactive installed
  - Database
    - Database Collation
    - Database owners (valid\invalid)
    - Auto close & Auto Shrink
    - VLFs
    - One log file per database
    - Auto create\update statistics
    - Trustworthy
    - Database status
  - Agent
    - Database mail XPs
    - SQL Agent account ?
    - DBA Operator exists

- PowerShell performance - foreach vs parallel