targetScope = 'subscription'

@description('Name of the remediation policy')
param policyName string = 'modify-missing-environment-tag'

@description('Default value applied when Environment tag is missing')
param defaultEnvironmentValue string = 'Unknown'

resource remediationPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: 'Auto-remediate missing Environment tag'
    description: 'Adds a default Environment tag to resources missing it. Does not modify CostCenter or Owner.'
    policyType: 'Custom'
    mode: 'All'
    parameters: {
      tagValue: {
        type: 'String'
        metadata: {
          displayName: 'Default Environment value'
          description: 'Value to apply when Environment tag is missing'
        }
        defaultValue: defaultEnvironmentValue
      }
    }
    policyRule: {
      if: {
        field: 'tags[\'Environment\']'
        exists: 'false'
      }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f'
          ]
          operations: [
            {
              operation: 'add'
              field: 'tags[\'Environment\']'
              value: '[parameters(\'tagValue\')]'
            }
          ]
        }
      }
    }
  }
}

resource remediationPolicyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'assign-modify-missing-environment-tag'
  location: 'uksouth'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Auto-remediate Environment tag subscription-wide'
    policyDefinitionId: remediationPolicyDefinition.id
  }
}

output policyDefinitionId string = remediationPolicyDefinition.id
output policyAssignmentId string = remediationPolicyAssignment.id
output assignmentPrincipalId string = remediationPolicyAssignment.identity.principalId
