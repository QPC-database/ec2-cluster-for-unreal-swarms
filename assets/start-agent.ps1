<powershell>
## Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
## SPDX-License-Identifier: MIT-0

# Define Coordinator IP, Cloudformation replaces this when task is been created
$coordinator_ip = "COORDINATOR_IP"

# Template of the Swarm Agent Developper Options file
$developeroptions = '<?xml version="1.0"?>
<SettableDeveloperOptions xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <LocalEnableLocalPerformanceMonitoring>true</LocalEnableLocalPerformanceMonitoring>
  <LocalJobsDefaultProcessorCount>LOCALCORES</LocalJobsDefaultProcessorCount>
  <LocalJobsDefaultProcessPriority>BelowNormal</LocalJobsDefaultProcessPriority>
  <RemoteJobsDefaultProcessorCount>REMOTECORES</RemoteJobsDefaultProcessorCount>
  <RemoteJobsDefaultProcessPriority>Idle</RemoteJobsDefaultProcessPriority>
  <UpdateAutomatically>false</UpdateAutomatically>
  <OptionsVersion>15</OptionsVersion>
</SettableDeveloperOptions>'

# Calculate number of cores
$cores = (Get-WmiObject -Class Win32_Processor | Select-Object -Property NumberOfLogicalProcessors).NumberOfLogicalProcessors

# Set the core values for the Swarm Agent
$developeroptions = $developeroptions.replace("REMOTECORES", $cores)
$developeroptions = $developeroptions.replace("LOCALCORES", $cores-1)

# Save the configureation file
$developeroptions | Out-File -FilePath "C:\ue4-swarm\SwarmAgent.DeveloperOptions.xml"

# Template of the Swarm Options file
$agentoptions = '<?xml version="1.0"?>
<SettableOptions xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <SerialisableColours>
    <SerialisableColour LocalColour="-1" />
    <SerialisableColour LocalColour="-1" />
    <SerialisableColour LocalColour="-1" />
    <SerialisableColour LocalColour="-1" />
    <SerialisableColour LocalColour="-5658199" />
    <SerialisableColour LocalColour="-5658199" />
    <SerialisableColour LocalColour="-5658199" />
    <SerialisableColour LocalColour="-2894893" />
    <SerialisableColour LocalColour="-1" />
    <SerialisableColour LocalColour="-7667712" />
    <SerialisableColour LocalColour="-7667712" />
    <SerialisableColour LocalColour="-2987746" />
    <SerialisableColour LocalColour="-2987746" />
    <SerialisableColour LocalColour="-16777077" />
    <SerialisableColour LocalColour="-16777077" />
    <SerialisableColour LocalColour="-16777077" />
    <SerialisableColour LocalColour="-16777077" />
    <SerialisableColour LocalColour="-16777077" />
    <SerialisableColour LocalColour="-16777077" />
    <SerialisableColour LocalColour="-7278960" />
    <SerialisableColour LocalColour="-16744448" />
    <SerialisableColour LocalColour="-16711681" />
    <SerialisableColour LocalColour="-8388480" />
    <SerialisableColour LocalColour="-16744448" />
    <SerialisableColour LocalColour="-16777216" />
    <SerialisableColour LocalColour="-16777216" />
    <SerialisableColour LocalColour="-16777216" />
  </SerialisableColours>
  <AllowedRemoteAgentNames>*</AllowedRemoteAgentNames>
  <AllowedRemoteAgentGroup>ue4-swarm-aws</AllowedRemoteAgentGroup>
  <AgentGroupName>ue4-swarm-aws</AgentGroupName>
  <CoordinatorRemotingHost>COORDINATORHOST</CoordinatorRemotingHost>
  <CacheFolder>C:\ue4-swarm/SwarmCache</CacheFolder>
  <MaximumJobsToKeep>5</MaximumJobsToKeep>
  <BringToFront>false</BringToFront>
  <ShowDeveloperMenu>true</ShowDeveloperMenu>
  <OptionsVersion>15</OptionsVersion>
  <WindowLocation>
    <X>0</X>
    <Y>0</Y>
  </WindowLocation>
  <WindowSize>
    <Width>768</Width>
    <Height>768</Height>
  </WindowSize>
  <AgentTabIndex>2</AgentTabIndex>
  <VisualiserZoomLevel>4</VisualiserZoomLevel>
</SettableOptions>'

# Replace the Coordinator IP in the template
$agentoptions = $agentoptions.replace("COORDINATORHOST", $coordinator_ip)

# Save the configuration file
$agentoptions | Out-File -FilePath "C:\ue4-swarm\SwarmAgent.Options.xml"

# Define the Swarm agent as Scheduled Task that starts at instance boot
$action = New-ScheduledTaskAction -Execute "C:\ue4-swarm\SwarmAgent.exe"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "SwarmAgent" -Description "UE4 Swarm Agent"

# Restart the instance to trigger the Swarm Agent Scheduled Task
Restart-Computer
</powershell>