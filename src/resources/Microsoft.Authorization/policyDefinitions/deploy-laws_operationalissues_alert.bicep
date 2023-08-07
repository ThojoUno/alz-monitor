// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

targetScope = 'managementGroup'

param policyLocation string = 'centralus'

param deploymentRoleDefinitionIds array = [
  '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]

@allowed([
  '0'
  '1'
  '2'
  '3'
  '4'
])
param parAlertSeverity string = '3'

@allowed([
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
  'PT6H'
  'PT12H'
  'P1D'
])
param parWindowSize string = 'P1D'

@allowed([
  'Equals'
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'

])
param parOperator string = 'GreaterThan'

@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
  'P1D'
])
param parEvaluationFrequency string = 'P1D'

@allowed([
  'deployIfNotExists'
  'disabled'
])
param parPolicyEffect string = 'deployIfNotExists'

param parAutoMitigate string = 'false'

// param parautoResolve string = 'true'
// param parautoResolveTime string = '00:10:00'

param parAlertState string = 'true'

param parThreshold string = '0'

param parEvaluationPeriods string = '1'

param parFailingPeriods string = '1'

@allowed([
  'Average'
  'Count'
  'Maximum'
  'Minimum'
  'Total'
])
param parTimeAggregation string = 'Count'

// param parComputersToInclude array = [
//     '*'
// ]
// param parDisksToInclude array = [
//    '*'
// ]

param parMonitorDisable string = 'MonitorDisable'

module LawsOperationalIssuesAlert '../../arm/Microsoft.Authorization/policyDefinitions/managementGroup/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-lawsoi-policyDefinitions'
  params: {
    name: 'Deploy_LAWS_operationalIssues_Alert'
    displayName: 'Deploy Laws Operational Issues Alert'
    description: 'Policy to audit/deploy Laws Operational Issues Alert'
    location: policyLocation
    metadata: {
      version: '1.0.0'
      category: 'Compute'
      source: 'Lunavi'
      alzCloudEnvironments: [
        'AzureCloud'
      ]
    }
    parameters: {
      severity: {
        type: 'String'
        metadata: {
          displayName: 'Severity'
          description: 'Severity of the Alert'
        }
        allowedValues: [
          '0'
          '1'
          '2'
          '3'
          '4'
        ]
        defaultValue: parAlertSeverity
      }
      operator: {
        type: 'String'
        metadata: { displayName: 'Operator' }
        allowedvalues: [
          'Equals'
          'GreaterThan'
          'GreaterThanOrEqual'
          'LessThan'
          'LessThanOrEqual'
        ]
        defaultvalue: parOperator
      }
      timeAggregation: {
        type: 'String'
        metadata: {
          displayName: 'TimeAggregation'
        }
        allowedValues: [
          'Average'
          'Count'
          'Maximum'
          'Minimum'
          'Total'

        ]

        defaultvalue: parTimeAggregation

      }

      windowSize: {
        type: 'String'
        metadata: {
          displayName: 'Window Size'
          description: 'Window size for the alert'
        }
        allowedValues: [

          'PT5M'
          'PT15M'
          'PT30M'
          'PT1H'
          'PT6H'
          'PT12H'
          'PT24H'
        ]
        defaultValue: parWindowSize
      }
      evaluationFrequency: {
        type: 'String'
        metadata: {
          displayName: 'Evaluation Frequency'
          description: 'Evaluation frequency for the alert'
        }
        allowedValues: [
          'PT5M'
          'PT15M'
          'PT30M'
          'PT1H'
        ]
        defaultValue: parEvaluationFrequency
      }
      autoMitigate: {
        type: 'String'
        metadata: {
          displayName: 'Auto Mitigate'
          description: 'Auto Mitigate for the alert'
        }
        allowedValues: [
          'true'
          'false'
        ]
        defaultValue: parAutoMitigate
      }
      enabled: {
        type: 'String'
        metadata: {
          displayName: 'Alert State'
          description: 'Alert state for the alert'
        }
        allowedValues: [
          'true'
          'false'
        ]
        defaultValue: parAlertState
      }

      threshold: {
        type: 'String'
        metadata: {
          displayName: 'Threshold'
          description: 'Threshold for the alert'
        }
        defaultValue: parThreshold
      }

      failingPeriods: {
        type: 'String'
        metadata: {
          disaplayname: 'Failing Periods'
          description: 'Number of failing periods before alert is fired'
        }
        defaultValue: parFailingPeriods
      }
      evaluationPeriods: {
        type: 'String'
        metadata: {
          displayname: 'Evaluation Periods'
          description: 'The number of aggregated lookback points.'
        }
        defaultValue: parEvaluationPeriods
      }
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Effect of the policy'
        }
        allowedValues: [
          'deployIfNotExists'
          'disabled'
        ]
        defaultValue: parPolicyEffect
      }
      MonitorDisable: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Tag name to disable monitoring resource. Set to true if monitoring should be disabled'
        }

        defaultValue: parMonitorDisable
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.OperationalInsights/workspaces'
          }
          {
            field: '[concat(\'tags[\', parameters(\'MonitorDisable\'), \']\')]'
            notEquals: 'true'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          roleDefinitionIds: deploymentRoleDefinitionIds
          type: 'Microsoft.Insights/scheduledQueryRules'
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Insights/scheduledQueryRules/scopes[*]'
                equals: '[concat(subscription().id, \'/resourceGroups/\', resourceGroup().name, \'/providers/Microsoft.OperationalInsights/workspaces/\', field(\'fullName\'))]'
              }
              {
                field: 'Microsoft.Insights/scheduledqueryrules/enabled'
                equals: '[parameters(\'enabled\')]'
              }
            ]
          }
          deployment: {
            location: policyLocation
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {

                  policyLocation: {
                    type: 'string'
                    defaultValue: policyLocation
                  }
                  severity: {
                    type: 'String'
                  }
                  windowSize: {
                    type: 'String'
                  }
                  evaluationFrequency: {
                    type: 'String'
                  }
                  autoMitigate: {
                    type: 'String'
                  }
                  autoResolve: {
                    type: 'String'
                  }
                  autoResolveTime: {
                    type: 'String'
                  }
                  enabled: {
                    type: 'String'
                  }
                  threshold: {
                    type: 'String'
                  }
                  operator: {
                    type: 'String'

                  }
                  timeAggregation: {
                    type: 'String'

                  }
                  failingPeriods: {
                    type: 'String'

                  }
                  evaluationPeriods: {
                    type: 'String'

                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Resources/deployments'
                    apiVersion: '2019-10-01'
                    name: 'LAWSOperationalIssueAlert'
                    properties: {
                      mode: 'Incremental'
                      template: {
                        '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                        contentVersion: '1.0.0.0'
                        parameters: {
                          enabled: {
                            type: 'string'
                          }
                        }
                        variables: {}
                        resources: [
                          {
                            type: 'Microsoft.Insights/scheduledQueryRules'
                            apiVersion: '2022-08-01-preview'
                            name: '[concat(subscription().displayName, \'-LAWSOperationalIssueAlert\')]'
                            properties: {
                              displayName: '[concat(subscription().displayName, \'-LAWSOperationalIssueAlert\')]'
                              description: 'Log Alert for Virtual Machine dataDiskReadLatency'
                              severity: '[parameters(\'severity\')]'
                              enabled: '[parameters(\'enabled\')]'
                              scopes: [
                                '[subscription().Id]'
                              ]
                              targetResourceTypes: [
                                'Microsoft.OperationalInsights/workspaces'
                              ]
                              evaluationFrequency: '[parameters(\'evaluationFrequency\')]'
                              windowSize: '[parameters(\'windowSize\')]'
                              criteria: {
                                allOf: [
                                  {
                                    query: '_LogOperation | where Level == "Warning"'
                                    metricMeasureColumn: ''
                                    threshold: '[parameters(\'threshold\')]'
                                    operator: '[parameters(\'operator\')]'
                                    resourceIdColumn: '_ResourceId'
                                    timeAggregation: '[parameters(\'timeAggregation\')]'
                                    failingPeriods: {
                                      numberOfEvaluationPeriods: '[parameters(\'evaluationPeriods\')]'
                                      minFailingPeriodsToAlert: '[parameters(\'failingPeriods\')]'
                                    }
                                  }
                                ]

                              }
                              autoMitigate: '[parameters(\'autoMitigate\')]'
                              parameters: {
                                severity: {
                                  value: '[parameters(\'severity\')]'
                                }
                                windowSize: {
                                  value: '[parameters(\'windowSize\')]'
                                }
                                evaluationFrequency: {
                                  value: '[parameters(\'evaluationFrequency\')]'
                                }
                                autoMitigate: {
                                  value: '[parameters(\'autoMitigate\')]'
                                }
                                autoResolve: {
                                  value: '[parameters(\'autoResolve\')]'
                                }
                                enabled: {
                                  value: '[parameters(\'enabled\')]'
                                }
                                threshold: {
                                  value: '[parameters(\'threshold\')]'
                                }
                                failingPeriods: {
                                  value: '[parameters(\'failingPeriods\')]'
                                }
                                evaluationPeriods: {
                                  value: '[parameters(\'evaluationPeriods\')]'
                                }

                              }
                            }
                          }
                        ]
                      }
                      parameters: {
                        enabled: {
                          value: '[parameters(\'enabled\')]'
                        }
                      }
                    }
                  }

                ]
              }
              parameters: {
                severity: {
                  value: '[parameters(\'severity\')]'
                }
                windowSize: {
                  value: '[parameters(\'windowSize\')]'
                }
                evaluationFrequency: {
                  value: '[parameters(\'evaluationFrequency\')]'
                }
                autoMitigate: {
                  value: '[parameters(\'autoMitigate\')]'
                }
                enabled: {
                  value: '[parameters(\'enabled\')]'
                }
                threshold: {
                  value: '[parameters(\'threshold\')]'
                }
                operator: {
                  value: '[parameters(\'operator\')]'
                }
                timeAggregation: {
                  value: '[parameters(\'timeAggregation\')]'
                }
                failingPeriods: {
                  value: '[parameters(\'failingPeriods\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}
