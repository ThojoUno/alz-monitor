targetScope = 'managementGroup'

param policyLocation string = 'centralus'
param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = false

// Customer Usage Attribution Id
var varCuaid = 'd6b3b08c-5825-4b89-a62b-e3168d3d8fb0'




///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Recovery Vault Alerts
//
///////////////////////////////////////////////////////////////////////////////////////////////////

module rv_backuphealthmonitor_policy '../../src/resources/Microsoft.Authorization/policyDefinitions/deploy-rv_backuphealth_monitor.bicep' = {
  name: '${uniqueString(deployment().name)}-rvbuhm-policyDefinitions-deploy'
  params: {
   deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
   policyLocation: policyLocation
  }
}

// added 2023-07-26, JThompson@Lunavi.com
module rv_backuphealthevent_policy '../../src/resources/Microsoft.Authorization/policyDefinitions/deploy-rv_backuphealth_event.bicep' = {
  name: '${uniqueString(deployment().name)}-rvbhe-policyDefinitions-deploy'
  params: {
   deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
   policyLocation: policyLocation
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Deployment telemetry
//
///////////////////////////////////////////////////////////////////////////////////////////////////


module modCustomerUsageAttribution './CRML/customerUsageAttribution/cuaIdManagementGroup.bicep' = if (!parTelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params //Only to ensure telemetry data is stored in same location as deployment. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  name: 'pid-${varCuaid}-${uniqueString(deployment().location)}'
  params: {}
}
