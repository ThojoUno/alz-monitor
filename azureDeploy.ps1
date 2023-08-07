


$location = "westus2"
$pseudoRootManagementGroup = "The pseudo root management group id parenting the identity, management and connectivity management groups"
$identityManagementGroup = "The management group id for Identity"
$managementManagementGroup = "The management group id for Management"
$connectivityManagementGroup = "The management group id for Connectivity"
$LZManagementGroup="The management group id for Landing Zones"




  #Deploy policy definitions
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location -TemplateFile ./infra-as-code/bicep/deploy_dine_policies.bicep
  
  #Deploy policy initiatives, wait approximately 1-2 minutes after deploying policies to ensure that there are no errors when creating initiatives
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorConnectivity.json
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorIdentity.json
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorManagement.json
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorLandingZone.json
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorServiceHealth.json
  
  #Assign Policy Initiatives, wait approximately 1-2 minutes after deploying initiatives policies to ensure that there are no errors when assigning them
  New-AzManagementGroupDeployment -ManagementGroupId $identityManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_identity.bicep -TemplateParameterFile ./infra-as-code/bicep/parameters-complete-identity.json
  New-AzManagementGroupDeployment -ManagementGroupId $managementManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_management.bicep -TemplateParameterFile ./infra-as-code/bicep/parameters-complete-management.json
  New-AzManagementGroupDeployment -ManagementGroupId $connectivityManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_connectivity.bicep -TemplateParameterFile ./infra-as-code/bicep/parameters-complete-connectivity.json
  New-AzManagementGroupDeployment -ManagementGroupId $LZManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_landingzones.bicep -TemplateParameterFile ./infra-as-code/bicep/parameters-complete-landingzones.json
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_servicehealth.bicep -TemplateParameterFile ./infra-as-code/bicep/parameters-complete-servicehealth.json




    
#Run the following commands to initiate remediation (if deploying to Brownfield)
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $managementManagementGroup -policyName Alerting-Management
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $connectivityManagementGroup -policyName Alerting-Connectivity
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $identityManagementGroup -policyName Alerting-Identity
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $LZManagementGroup -policyName Alerting-LandingZone
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $managementGroupId -policyName Alerting-ServiceHealth