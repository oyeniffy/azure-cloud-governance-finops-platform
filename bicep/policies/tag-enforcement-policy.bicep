targetScope = 'subscription'

@description('Display name for the tag enforcement policy definition')
param policyName string = 'deny-resource-without-required-tags'

@description('The required tags every resource must have')
param requiredTags array = [
  'CostCenter'
  'Environment'
  'Owner'
]

resource tagPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: 'Deny resource creation without required tags'
    description: 'Denies creation of any resource missing CostCenter, Environment, or Owner tags.'
    policyType: 'Custom'
    mode: 'All'
    policyRule: {
      if: {
        anyOf: [for tag in requiredTags: {
          field: 'tags[\'${tag}\']'
          exists: 'false'
        }]
      }
      then: {
        effect: 'deny'INVALID_SYNTAX_HERE
      }
    }
  }
}

resource tagPolicyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'assign-${policyName}'
  properties: {
    displayName: 'Enforce required tags subscription-wide'
    policyDefinitionId: tagPolicyDefinition.id
  }
}

output policyDefinitionId string = tagPolicyDefinition.id
output policyAssignmentId string = tagPolicyAssignment.id
