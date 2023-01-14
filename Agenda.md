# Agenda

Here are some thoughts - I may have too much for part 1 but we can chop and change it as we build it out

## Part 1 - Boost your PowerShell and dbatools automation knowledge

From the abstract:

- Updating and patching your SQL Instances with minimal downtime
- Adding replicas to Availability Groups without effort
- Advanced migrations for large mission critical databases
- Integrating database process automation with CI/CD tooling such as GitHub Actions
- And wherever else the adventure takes us

### Ideas\Thoughts

Thinking it might be cool if we can kind of tell a story about our 'company' with our very important 'app' (if we can get that e-shop working)

- intro to the estate (maybe starting with the database servers on SQL 2019 or 2017 even)
  - this is our app server - quick demo of stuff just working\business as usual
  - these are the database servers - using some dbatools commands to show connections, databases, whatever else we have pre-built
    - could show as much of dbatools stuff as we wanted here
  - could also talk about how we go into a new company and figure out what we have
- we need to upgrade!
  - planning out upgrade\migration
    - talking about the non-technical stuff - how much downtime, how will we test, how do we repoint applications
  - migrate few small databases using straightforward Copy-DbaDatabase
  - what about our giant database!
    - more complex migration scenarios
      - pre-staging full backup
      - Log shipping & cutover
- now we're on 2022 but we need more HA!
  - build out an AG
    - could also talk about the options this adds for rolling migrations\upgrades in the future
  - failover from on-prem --> MI --> back to on-prem as another HA option
- updating and patching
  - if we upgraded to 2022 RTM we could then talk about applying CUs (if there is one by then? 🤔)
  - also could talk about windows updates
    - demo of Chrissy's kbupdate module
- now we're upgraded and HA - we need more automation
  - GitHub actions CI\CD demos?
  - whatever we want to talk about here

## Part 2 - Estate validation

- dbachecks magic on our estate from part 1
- easily demonstrate that every instance is in a particular state
- prove to elven auditors that your instances pass the CIS SQL security benchmark using dbachecks
- etc.

### Last year's schedule

"Morning Break is 10:30 AM for 15 minutes"
"Lunch is at 12:30 PM for one hour"
"Afternoon Break is 3:00 PM for 15 minutes"
"We finish at 5:00 PM"
