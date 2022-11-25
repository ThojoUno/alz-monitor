targetScope = 'managementGroup'

param policyLocation string = 'centralus'
param resourceGroupName string = 'AlzMonitoring-rg'
param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]

module ActivityLogLAWorkspaceDeleteAlert '../../arm/Microsoft.Authorization/policyDefinitions/managementGroup/deploy.bicep' = {
    name: '${uniqueString(deployment().name)}-shi-policyDefinitions'
    params: {
        name: 'Deploy_activitylog_LAWorkspace_Delete'
        displayName: '[DINE] Deploy Activity Log LA Workspace Delete Alert'
        description: 'DINE policy to Deploy Activity Log LA Workspace Delete Alert'
        location: policyLocation
        metadata: {
            version: '1.0.0'
            Category: 'ActivityLog'
            source: 'https://github.com/Azure/ALZ-Monitor/'
        }
        policyRule: {
            if: {
                allOf: [
                    {
                        field: 'type'
                        equals: 'Microsoft.Resources/subscriptions'
                    }
                    {
                      field: 'type'
                      equals: 'Microsoft.OperationalInsights/workspaces'
                    }
                ]
            }
            then: {
                effect: 'deployIfNotExists'
                details: {
                    roleDefinitionIds: deploymentRoleDefinitionIds
                    type: 'Microsoft.Insights/activityLogAlerts'
                    // should be replaced with parameter value
                    resourceGroupName: resourceGroupName
                    existenceCondition: {
                        allOf: [
  
                          {
                            field: 'Microsoft.Insights/ActivityLogAlerts/enabled'
                            equals: 'true'
                          }
                          {
                            count: {
                              field: 'Microsoft.Insights/ActivityLogAlerts/condition.allOf[*]'
                              where: {
                                anyOf: [
                                  {
                                    allOf: [
                                      {
                                        field: 'Microsoft.Insights/ActivityLogAlerts/condition.allOf[*].field'
                                        equals: 'category'
                                      }
                                      {
                                        field: 'Microsoft.Insights/ActivityLogAlerts/condition.allOf[*].equals'
                                        equals: 'Administrative'
                                      }
                                    ]
                                  }
                                  {
                                    allOf: [
                                      {
                                        field: 'microsoft.insights/activityLogAlerts/condition.allOf[*].field'
                                        equals: 'operationName'
                                      }
                                      {
                                        field: 'microsoft.insights/activityLogAlerts/condition.allOf[*].equals'
                                        equals: 'Microsoft.OperationalInsights/workspaces/delete'
                                      }
                                    ]
                                  }
                                ]
                              }
                            }
                            equals: 2
                          }
                        ]
                    }
                    deployment: {
                        properties: {
                            mode: 'incremental'
                            template: {
                                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                                contentVersion: '1.0.0.0'
                                variables: {}
                                resources: [ 

                                  {
                                    type: 'Microsoft.Resources/resourceGroups'
                                    apiVersion: '2020-10-01'
                                    name: resourceGroupName
                                    location: policyLocation
                                    properties: {}
                                    }
                                //should deploy resource group as well
                                {
                                        type: 'microsoft.insights/activityLogAlerts'
                                        apiVersion: '2020-10-01'
                                        //name: '[concat(subscription().subscriptionId, \'-ActivityVPNGatewayDelete\')]'
                                        name: 'ActivityLAWorkspaceDelete'
                                        location: 'global'
                                        properties: {
                                            description: 'Activity Log LA Workspace Delete'
                                            enabled: true
                                            scopes: [
                                                '[subscription().id]'
                                            ]
                                            condition: {
                                            allOf: [
                                                {
                                                  field:'category'
                                                  equals: 'Administrative'
                                                }
                                                {
                                                  field: 'operationName'
                                                  equals: 'Microsoft.OperationalInsights/workspaces/delete'
                                                }
                                                {
                                                  field: 'status'
                                                  containsAny: ['succeeded']
                                                }
                                              
                                              ]
                                            }
                                        }
  
                                    }
                                ]
                            }
                           
                        }
                    }
                }
            }
        }
    }
  }
  