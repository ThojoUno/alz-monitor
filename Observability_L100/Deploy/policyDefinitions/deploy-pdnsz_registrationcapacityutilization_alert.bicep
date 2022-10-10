targetScope = 'managementGroup'

param policyLocation string = 'centralus'
param deploymentRoleDefinitionIds array = [
'/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]

module RegistrationCapacityUtilizationAlert '../../arm/Microsoft.Authorization/policyDefinitions/managementGroup/deploy.bicep' = {
    name: '${uniqueString(deployment().name)}-pdnszvnrcu-policyDefinitions'
    params: {
        name: 'Deploy_DNSZ_RegistrationCapacityUtil_Alert'
        displayName: '[DINE] Deploy PDNSZ Registration Capacity Utilization Alert'
        description: 'DINE policy to audit/deploy Private DNS Zone Registration Capacity Utilization Alert'
        location: policyLocation
        metadata: {
            version: '1.0.0'
            Category: 'Networking'
            source: 'https://github.com/Azure/ALZ-Monitor/'
        }
        policyRule: {
            if: {
                allOf: [
                    {
                        field: 'type'
                        equals: 'Microsoft.Network/privateDnsZones'
                    }
                ]
            }
            then: {
                effect: 'deployIfNotExists'
                details: {
                    roleDefinitionIds: deploymentRoleDefinitionIds
                    type: 'Microsoft.Insights/metricAlerts'
                    existenceCondition: {
                        allOf: [
                            {
                                field: 'Microsoft.Insights/metricAlerts/criteria.Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria.allOf[*].metricNamespace'
                                equals: 'Microsoft.Network/privateDnsZones'
                            }
                            {
                                field: 'Microsoft.Insights/metricAlerts/criteria.Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria.allOf[*].metricName'
                                equals: 'VirtualNetworkWithRegistrationCapacityUtilization'
                            }
                            {
                                field: 'Microsoft.Insights/metricalerts/scopes[*]'
                                equals: '[concat(subscription().id, \'/resourceGroups/\', resourceGroup().name, \'/providers/Microsoft.Network/privateDnsZones/\', field(\'fullName\'))]'
                            }
                        ]
                    }
                    deployment: {
                        properties: {
                            mode: 'incremental'
                            template: {
                                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                                contentVersion: '1.0.0.0'
                                parameters: {
                                    resourceName: {
                                        type: 'String'
                                        metadata: {
                                            displayName: 'resourceName'
                                            description: 'Name of the resource'
                                        }
                                    }
                                    resourceId: {
                                        type: 'String'
                                        metadata: {
                                            displayName: 'resourceId'
                                            description: 'Resource ID of the resource emitting the metric that will be used for the comparison'
                                        }
                                    }
                                }
                                variables: {}
                                resources: [
                                {
                                    type: 'Microsoft.Insights/metricAlerts'
                                    apiVersion: '2018-03-01'
                                    name: '[concat(parameters(\'resourceName\'), \'-RequestsAlert\')]'
                                    location: 'global'
                                    properties: {
                                        description: 'Metric Alert for Private DNS Zone Registration Capacity Utilization'
                                        severity: 3
                                        enabled: true
                                        scopes: [
                                        '[parameters(\'resourceId\')]'
                                        ]
                                        evaluationFrequency: 'PT1H'
                                        windowSize: 'PT1H'
                                        criteria: {
                                            allOf: [
                                                {
                                                    name: 'VirtualNetworkWithRegistrationCapacityUtilization'
                                                    metricNamespace: 'Microsoft.Network/privateDnsZones'
                                                    metricName: 'VirtualNetworkWithRegistrationCapacityUtilization'
                                                    operator: 'GreaterThan'
                                                    threshold: 90
                                                    timeAggregation: 'Maximum'
                                                    criterionType: 'StaticThresholdCriterion'
                                                }
                                            ]
                                            'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
                                        }
                                    }

                                }
                                ]
                            }
                            parameters: {
                                resourceName: {
                                    value: '[field(\'name\')]'
                                }
                                resourceId: {
                                    value: '[field(\'id\')]'
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}