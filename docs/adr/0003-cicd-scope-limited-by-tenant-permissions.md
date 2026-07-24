# ADR 0003: CI/CD Scope Limited by Tenant App Registration Restrictions

## Status
Accepted

## Context
Phase 6 originally planned two GitHub Actions workflows: PR-time Bicep
validation, and a scheduled job re-running `az deployment what-if`
against the live subscription to detect configuration drift. Both
Service Principal and OIDC federated credential approaches require
creating an Azure AD App Registration so GitHub Actions can authenticate
to Azure.

Attempting this (`az ad app create`) returned:
`Insufficient privileges to complete the operation.`

Investigation confirmed this is the Entra ID tenant setting
"Users can register applications" set to `No` for this tenant
(Task Systems Limited) — a deliberate security control restricting app
registration to Global Administrators, Application Administrators, or
Cloud Application Administrators. This is a legitimate enterprise
governance control, not a bug, and not something fixable from the CLI
or by a non-admin user.

## Decision
Phase 6 is scoped down to what's achievable without elevated tenant
permissions:

- **PR validation workflow** (`bicep-validate.yml`): runs `az bicep build`
  against every `.bicep` file on every pull request. This requires no
  Azure authentication at all — it's local compilation, not a live
  deployment check — and would have caught every configuration bug
  encountered in this project (unused policy parameters, incorrect
  `mode: Indexed` vs `mode: All`, the anomaly-alert subject length
  limit) automatically, before merge.

- **Scheduled drift detection** (`az deployment what-if` against the
  live subscription) is **not implemented** in this project, because it
  requires an App Registration this tenant does not permit a
  non-admin user to create. This is documented as a known limitation
  rather than worked around insecurely (e.g. by using a personal
  long-lived credential stored as a plaintext secret, which would
  undermine the project's own governance principles).

## Alternatives considered
- **Request Application Administrator role from tenant admin**: possible
  in principle, but disproportionate to ask for a personal portfolio
  project on an organizational tenant — rejected.
- **Use a personal Azure account's credentials directly as a GitHub
  Secret without a scoped Service Principal**: rejected — grants GitHub
  Actions the same permissions as the full user account, violating
  least-privilege, and directly contradicts the governance principles
  established in ADR 0001 and 0002.

## Consequences
- Drift between deployed Azure state and the repository's Bicep source
  is currently only caught manually (as demonstrated throughout Phases
  2–5, where `az deployment sub create` was re-run to reconcile fixes).
- If this project moved to a tenant where the user held Application
  Administrator rights, `drift-detection.yml` could be added using the
  same OIDC pattern as `bicep-validate.yml`, with no other architecture
  changes required.
- This constraint is a realistic example of a security control
  interacting with automation ambitions — governance sometimes
  intentionally limits what "self-service" CI/CD can achieve, and that
  tradeoff is itself part of what this project demonstrates.
