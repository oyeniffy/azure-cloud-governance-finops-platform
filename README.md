# Azure Cloud Governance & FinOps Platform

A policy-as-code governance and cost-management platform built on Azure,
demonstrating tag enforcement, automated remediation, budget guardrails,
cost anomaly detection, and a live compliance/cost dashboard — all
deployed via Bicep, all proven with real evidence, all torn down clean.

This is a companion project to
[multicloud-zero-trust-landing-zone](https://github.com/oyeniffy/multicloud-zero-trust-landing-zone):
that project asks "who can access what," this one asks "what does it
cost, and is it governed."

## Why governance + FinOps together

Cost data without governance behind it is just a chart — it can't answer
"whose spend is this" or "was this expected." This project treats the
two as one system: Azure Policy enforces the tagging structure that
makes cost data trustworthy, and Cost Management surfaces that data back
by the same tags the policy enforces. See
[ADR 0001](docs/adr/0001-tagging-policy-and-budget-strategy.md) for the
full reasoning.

## What's actually deployed and proven here

| Phase | What it demonstrates | Evidence |
|---|---|---|
| 1 | Architecture & design decisions before any code | [ADR 0001](docs/adr/0001-tagging-policy-and-budget-strategy.md), [architecture.md](docs/architecture.md) |
| 2 | Subscription-wide deny policy for missing tags | [deny proof](docs/evidence/phase2-deny-missing-environment-tag.png), [allow proof](docs/evidence/phase2-allow-fully-tagged.png) |
| 3 | Budget + action group + cost anomaly alerts | [budget](docs/evidence/phase3-budget-configured.png), [anomaly alert](docs/evidence/phase3-anomaly-alert-configured.png) |
| 4 | Real workload deployed and governed | [workload](docs/evidence/phase4-demo-workload-deployed.png), [policy blocks untagged storage](docs/evidence/phase4-policy-blocks-untagged-storage.png) |
| 5 | Self-healing tag remediation (least-privilege) | [before/after](docs/evidence/phase5-remediation-before-after.png), [ADR 0002](docs/adr/0002-tag-remediation-strategy.md) |
| 6 | CI validation catching broken IaC before merge | [CI fails on broken syntax](docs/evidence/phase6-ci-catches-broken-bicep.png), [ADR 0003](docs/adr/0003-cicd-scope-limited-by-tenant-permissions.md) |
| 7 | Live compliance/cost dashboard, real data | [dashboard](docs/evidence/phase7-dashboard-full-view.png) |
| 8 | Full teardown, $0 ongoing spend | see below |

## Architecture

See [docs/architecture.md](docs/architecture.md) for the full diagram
and trust-boundary reasoning.

## Repository structure
bicep/
policies/ # tag enforcement (deny) + tag remediation (modify)
budgets/ # action group, budget, anomaly alert
workload/ # demo workload used to prove policy enforcement
dashboard/ # cost/governance Workbook
docs/
adr/ # architecture decision records
evidence/ # real screenshots from real deployments
architecture.md
.github/workflows/
bicep-validate.yml # PR-time Bicep compilation check
## Real constraints hit and documented, not hidden

This project intentionally documents what went wrong, not just what
went right — see the
[Lessons Learned section of architecture.md](docs/architecture.md#lessons-learned)
for details on Azure Policy mode gotchas, Git Bash path-conversion
issues, a tenant-level permission restriction that limited CI/CD scope
(ADR 0003), and an Azure Resource Graph indexing limitation that changed
the dashboard's design.

## Cost discipline

Deployed on a ~$150/month Azure credit. Every phase was deployed,
evidenced with screenshots, and torn down before moving to the next —
confirmed via `az resource list` showing zero remaining tagged resources
and `az group exists` returning `false` for the working resource group
after final teardown.

## Tech stack

- **IaC:** Bicep
- **Governance:** Azure Policy (deny + modify effects), Azure Policy
  Exemptions
- **FinOps:** Azure Consumption Budgets, Cost Management anomaly
  detection, Azure Resource Graph
- **Dashboard:** Azure Monitor Workbooks
- **CI:** GitHub Actions
- **Identity:** System-assigned managed identity, least-privilege
  (Tag Contributor only)
