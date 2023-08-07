


$location = "northcentralus"
$pseudoRootManagementGroup = "GCRTA"
$identityManagementGroup = "GCRTA-platform"
$managementManagementGroup = "GCRTA-platform"
$connectivityManagementGroup = "GCRTA-platform"
$LZManagementGroup="GCRTA-landingzones"

# VONTAS GCRTA
$tenantId = 'b3f4e160-e374-481d-b543-c6e18c1c92e4'
$hubSubId = '6eb5bb60-eb00-4adf-8b4f-8abd742350f1'
$prodSpokeSubId = 'ff8ad2b4-2776-4eb3-971c-6704ef298733'
$testSpokeSubId = '59cc8f37-1f25-48d4-8647-20dac11364f5'

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
    -TemplateParameterFile ./workloads/vontas-gcrta/parameters-complete-identity.json `
    -parPolicyPseudoRootMgmtGroup $pseudoRootManagementGroup  -verbose


New-AzManagementGroupDeployment -ManagementGroupId $managementManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_management.bicep `
    -TemplateParameterFile ./workloads/vontas-gcrta/parameters-complete-management.json `
    -parPolicyPseudoRootMgmtGroup $pseudoRootManagementGroup  -verbose
  
New-AzManagementGroupDeployment -ManagementGroupId $connectivityManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_connectivity.bicep `
    -TemplateParameterFile ./workloads/vontas-gcrta/parameters-complete-connectivity.json `
    -parPolicyPseudoRootMgmtGroup $pseudoRootManagementGroup  -verbose

New-AzManagementGroupDeployment -ManagementGroupId $LZManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_landingzones.bicep `
    -TemplateParameterFile ./workloads/vontas-gcrta/parameters-complete-landingzones.json `
    -parPolicyPseudoRootMgmtGroup $pseudoRootManagementGroup  -verbose

New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_servicehealth.bicep `
    -TemplateParameterFile ./workloads/vontas-gcrta/parameters-complete-servicehealth.json `
    -parPolicyPseudoRootMgmtGroup $pseudoRootManagementGroup  -verbose

# This was an attempt to pass several object to template, but it would hang up and not complete, work-in-progress.
#
# # Parameters necessary for deployment
# $inputObject = @{
#   ManagementGroupId     = $pseudoRootManagementGroup
#   Location              = $Location
#   TemplateFile          = './infra-as-code/bicep/assign_initiatives_servicehealth.bicep'
#   TemplateParameterFile = './infra-as-code/bicep/parameters-complete-servicehealth.json'
#   parPolicyAssignmentParameters = @{
#     ALZMonitorResourceGroupName = "rg-alz-monitor"
#     ALZMonitorResourceGroupTags = @{
#       Project    = "alz-monitor"
#       DeployedBy = "Lunavi"
#     }
#     ALZMonitorResourceGroupLocation = "northcentralus"
#   }  
#   parPolicyPseudoRootMgmtGroup = $pseudoRootManagementGroup
#   Verbose               = $true
# }

# New-AzManagementGroupDeployment @inputObject




    
#Run the following commands to initiate remediation (if deploying to Brownfield)
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $managementManagementGroup -policyName Alerting-Management
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $connectivityManagementGroup -policyName Alerting-Connectivity
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $identityManagementGroup -policyName Alerting-Identity
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $LZManagementGroup -policyName Alerting-LandingZone

.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $pseudoRootManagementGroup -policyName Alerting-ServiceHealth