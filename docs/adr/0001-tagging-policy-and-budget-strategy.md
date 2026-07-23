# ADR 0001: Tagging Policy + Budget Guardrails as the FinOps Foundation

## Status
Accepted

## Context
Most "FinOps" portfolio projects show a cost dashboard with numbers pulled
from an account that has no enforced structure behind it — no guarantee
that a resource is tagged to a team, environment, or cost center. Cost
data without governance behind it is just a chart; it can't answer
"whose spend is this" or "was this expected."

This project treats governance and FinOps as one system: Azure Policy
enforces the structure (mandatory tags, allowed regions/SKUs) that makes
cost data trustworthy, and Cost Management surfaces that data back by
the same tags the policy enforces. Each half validates the other.

## Decision
We will implement, in this order:

1. **Tag enforcement policy** (deny effect) — any resource created without
   `CostCenter`, `Environment`, and `Owner` tags is rejected at creation
   time, not caught after the fact.
2. **Region/SKU restriction policy** — prevents accidental deployment of
   expensive SKUs or resources in unintended regions, protecting the
   budget directly.
3. **Tag remediation** (`deployIfNotExists`/`modify` policy or an Azure
   Function) — for resources that predate the policy, or edge cases
   where tags drift, remediation brings them back into compliance
   automatically rather than relying on manual audits.
4. **Consumption budgets + action groups** — alert thresholds (e.g. 50%,
   80%, 100% of a defined budget) route to an action group (email now,
   extensible to Teams/webhook later).
5. **Cost anomaly detection** — native Cost Management anomaly alerts
   catch spend spikes that a fixed budget threshold might miss early.
6. **Drift detection in CI** — a scheduled GitHub Action re-runs
   `az deployment what-if` against the deployed policy/budget definitions
   so configuration drift is caught continuously, not just at deploy time.

## Alternatives considered
- **Cost dashboard only, no policy layer**: rejected — doesn't prove
  governance, only visibility. Anyone can build a chart from raw billing
  data; the harder and more valuable problem is preventing bad spend
  before it happens.
- **Third-party FinOps tooling (e.g. CloudHealth, Vantage)**: rejected
  for this project — the goal is to demonstrate native Azure governance
  and IaC skill, not a SaaS integration skill.
- **Manual tag audits via scripts run on a schedule**: rejected in favor
  of policy-enforced remediation — a scheduled script is reactive and
  can silently fail; a `deployIfNotExists` policy is declarative and
  self-healing.

## Consequences
- Every resource in this project must be deployed through the tagging
  policy scope from day one, or the "proof" is weaker — no manually
  tagged demo resources.
- Budget thresholds are deliberately conservative given the ~$150/month
  constraint; the demo workload is small and torn down promptly after
  each evidence-gathering session.
- Bicep is used throughout (not Terraform) to stay consistent with the
  Azure half of the prior landing-zone project and to keep policy/budget
  definitions native to the ARM/Bicep policy schema.
