
$location = "westus2"
$pseudoRootManagementGroup = "alz"
$identityManagementGroup = "alz-platform"
$managementManagementGroup = "alz-platform"
$connectivityManagementGroup = "alz-platform"
$LZManagementGroup="alz-landingzones"

#LunaviLab
$TenantId = '0c557776-7f20-4c23-8c8e-53bebcc62ae6'
$hubSubId = '0397f14b-7a87-4673-a605-037288623760'
# $prodSpokeSubId = '0116efb4-24cc-4d32-b9c8-3912ef0869b8'

Connect-AzAccount -TenantId $tenantId
Set-AzContext -Subscription $hubSubId

$Tags  = @{'_deployed_by_alz_monitor'= 'true'; 'Expiry Date'='8/1/2099'; 'Business Unit'='Cloud Enablement'; 'Owner'='Joe Thompson'; 'Environment'='Lab'}


#Deploy policy definitions
New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
   -policyLocation $location `
   -TemplateFile ./infra-as-code/bicep/deploy_dine_policies.bicep -verbose


#Deploy policy definitions - Adds tags to policy definitions
# New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
#    -policyLocation $location `
#    -parResourceGroupTags $Tags `
#    -TemplateFile ./infra-as-code/bicep/deploy_dine_policies-custom.bicep -verbose

 
#Deploy policy initiatives, wait approximately 1-2 minutes after deploying policies to ensure that there are no errors when creating initiatives
# custom version allow additional tags on resource groups, required for testing in LunaviLab.
# Todo - These all default to centralus, add parameter to set custom location.

New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorConnectivity-custom.json `
    -ResourceGroupLocation $location `
    -ResourceGroupTags $Tags -verbose

New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorManagement-custom.json `
    -ResourceGroupLocation $location `
    -ResourceGroupTags $Tags -verbose

New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorIdentity-custom.json `
    -ResourceGroupLocation $location `
    -ResourceGroupTags $Tags -verbose

New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorLandingZone-custom.json `
    -ResourceGroupLocation $location `
    -ResourceGroupTags $Tags -verbose

New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorServiceHealth-custom.json `
    -ResourceGroupLocation $location `
    -ResourceGroupTags $Tags -verbose




# PolicySetDefinitions for virtual machine (VM) monitoring (*work-in-progress*)   
New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./src/resources/Microsoft.Authorization/policySetDefinitions/ALZ-MonitorVM-custom.json `
    -ResourceGroupLocation $location `
    -ResourceGroupTags $Tags -verbose





#Assign Policy Initiatives, wait approximately 1-2 minutes after deploying initiatives policies to ensure that there are no errors when assigning them
New-AzManagementGroupDeployment -ManagementGroupId $connectivityManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_connectivity.bicep `
    -TemplateParameterFile ./workloads/lunavilab/parameters-complete-connectivity.json -verbose

New-AzManagementGroupDeployment -ManagementGroupId $managementManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_management.bicep `
    -TemplateParameterFile ./workloads/lunavilab/parameters-complete-management.json -verbose

New-AzManagementGroupDeployment -ManagementGroupId $identityManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_identity.bicep `
    -TemplateParameterFile ./workloads/lunavilab/parameters-complete-identity.json -verbose 

New-AzManagementGroupDeployment -ManagementGroupId $LZManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_landingzones.bicep `
    -TemplateParameterFile ./workloads/lunavilab/parameters-complete-landingzones.json -verbose

New-AzManagementGroupDeployment -ManagementGroupId $pseudoRootManagementGroup -Location $location `
    -TemplateFile ./infra-as-code/bicep/assign_initiatives_servicehealth.bicep `
    -TemplateParameterFile ./workloads/lunavilab/parameters-complete-servicehealth.json -verbose




# This adds virtual machine (VM) alerts to identity management group, if domain controllers are deployed. (*work-in-progress*)
# New-AzManagementGroupDeployment -ManagementGroupId $identityManagementGroup -Location $location `
#     -TemplateFile ./infra-as-code/bicep/assign_initiatives_identity_VM-custom.bicep `
#     -TemplateParameterFile ./infra-as-code/bicep/parameters-complete-identity_VM-custom.json -verbose




    Start-AzPolicyComplianceScan

    
#Run the following commands to initiate remediation (if deploying to Brownfield)
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $connectivityManagementGroup -policyName Alerting-Connectivity
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $managementManagementGroup -policyName Alerting-Management
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $identityManagementGroup -policyName Alerting-Identity

.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $LZManagementGroup -policyName Alerting-LandingZone
.github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $pseudoRootManagementGroup -policyName Alerting-ServiceHealth



# .github\scripts\Start-ALZMonitorRemediation.ps1 -managementGroupName $identityManagementGroup -policyName Alerting-VM

.\src\scripts\Start-ALZMonitorCleanup.ps1 -force