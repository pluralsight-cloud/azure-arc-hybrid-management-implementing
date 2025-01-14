param arcVMNames array = [
  'LinuxVM1'
  'LinuxVM2'
]
param forceUpdateTag string = utcNow()
param servicePrincipalId string
@secure()
param servicePrincipalSecret string

var location  = resourceGroup().location

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: 'law-default'
}

resource arcMachines 'Microsoft.HybridCompute/machines@2024-07-10' existing = [for arcVM in arcVMNames: {
  name: arcVM
}]

resource linuxAgent 'Microsoft.HybridCompute/machines/extensions@2021-12-10-preview' = [for (arcVM,index) in arcVMNames: {
  parent: arcMachines[index]
  name: 'AzureMonitorLinuxAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.21'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}]

resource MSVMIDCR 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: 'MSVMI-VMInsights'
  location: location
  properties: {
    description: 'Data collection rule for VM Insights.'
    dataSources: {
      performanceCounters: [
        {
          name: 'VMInsightsPerfCounters'
          streams: [
            'Microsoft-InsightsMetrics'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\VmInsights\\DetailedMetrics'
          ]
        }
      ]
      extensions: [
        {
          streams: [
            'Microsoft-ServiceMap'
          ]
          extensionName: 'DependencyAgent'
          extensionSettings: {}
          name: 'DependencyAgentDataSource'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspace.id
          name: 'VMInsightsPerf-Logs-Dest'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-InsightsMetrics'
        ]
        destinations: [
          'VMInsightsPerf-Logs-Dest'
        ]
      }
      {
        streams: [
          'Microsoft-ServiceMap'
        ]
        destinations: [
          'VMInsightsPerf-Logs-Dest'
        ]
      }
    ]
  }
}

resource DCRAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = [for (arcVM,index) in arcVMNames: {
  scope: arcMachines[index]
  name: '${arcMachines[index].name}-vmInsights'
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this virtual machine.'
    dataCollectionRuleId: MSVMIDCR.id
  }
}]

resource CSE 'Microsoft.HybridCompute/machines/extensions@2024-07-10' = [for (arcVM,index) in arcVMNames: {
  parent: arcMachines[index]
  name: 'cse-Arc-${arcMachines[index].name}'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    forceUpdateTag: forceUpdateTag
    protectedSettings: {
      commandToExecute: 'curl -sL https://raw.githubusercontent.com/pluralsight-cloud/azure-arc-hybrid-management-implementing/refs/heads/main/LAB-Manage%20hybrid%20environments%20with%20Azure%20Arc/detect_k8s_and_arc_enable.sh | sudo bash -s -- ${servicePrincipalId} ${servicePrincipalSecret} ${tenant().tenantId}'
    }
  }
}]
