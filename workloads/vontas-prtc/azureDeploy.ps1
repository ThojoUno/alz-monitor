


$location = "eastus2"
$pseudoRootManagementGroup = "prtc"
$identityManagementGroup = "prtc-platform"
$managementManagementGroup = "prtc-platform"
$connectivityManagementGroup = "prtc-platform"
$LZManagementGroup="prtc-landingzones"

# VONTAS PRTC
$tenantId = '04bb7969-a23a-4294-ba0a-4151e7c8a88e'
$hubSubId = '82b3f9ea-b1b1-419f-b7c6-6f09c0652088'
$prodSpokeSubId = '6acd9c3a-23bc-4cd8-82e5-0b456f4fe2b1'
$testSpokeSubId = '1516d1c0-1119-47dc-b9f7-c602e7bb106b'

Connect-AzAccount -TenantId $tenantId
Set-AzContext -Subscription $hubSubId


  #Deploy policy definitions
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -policyLocation $location `
    -TemplateFile ./infra-as-code/bicep/deploy_dine_policies.bicep -verbose
  
  #Deploy policy initiatives, wait approximately 1-2 minutes after deploying policies to ensure that there are no errors when creating initiatives
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorConnectivity.json -verbose
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorIdentity.json -verbose
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorManagement.json -verbose
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorLandingZone.json -verbose
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorServiceHealth.json -verbose

 
  #Assign Policy Initiatives, wait approximately 1-2 minutes after deploying initiatives policies to ensure that there are no errors when assigning them
  New-AzManagementGroupDeployment -ManagementGroupId $identityManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_identity.bicep `
    -TemplateParameterFile ./workloads/vontas-prtc/parameters-complete-identity.json -verbose
  New-AzManagementGroupDeployment -ManagementGroupId $managementManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_management.bicep `
    -TemplateParameterFile ./workloads/vontas-prtc/parameters-complete-management.json -verbose
  New-AzManagementGroupDeployment -ManagementGroupId $connectivityManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_connectivity.bicep `
    -TemplateParameterFile ./workloads/vontas-prtc/parameters-complete-connectivity.json -verbose
  New-AzManagementGroupDeployment -ManagementGroupId $LZManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_landingzones.bicep `
    -TemplateParameterFile ./workloads/vontas-prtc/parameters-complete-landingzones.json -verbose
  New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_servicehealth.bicep `
    -TemplateParameterFile ./workloads/vontas-prtc/parameters-complete-servicehealth.json -verbose


    
#Run the following commands to initiate remediation (if deploying to Brownfield)
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $managementManagementGroup -policyName Alerting-Management
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $connectivityManagementGroup -policyName Alerting-Connectivity
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $identityManagementGroup -policyName Alerting-Identity
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $LZManagementGroup -policyName Alerting-LandingZone

.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $pseudoRootManagementGroup -policyName Alerting-ServiceHealth