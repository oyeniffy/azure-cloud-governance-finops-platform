# ADR 0002: Tag Remediation Strategy — Auto-fix vs Flag-only

## Status
Accepted

## Context
Phase 2 established a deny policy that blocks non-compliant resources at
creation time. That doesn't cover drift on resources that predate the
policy, or tags removed after the fact. Azure Policy's `modify` effect
can automatically add missing tags via a remediation task, but blindly
auto-filling every tag risks silently mislabeling cost attribution.

## Decision
Remediation is applied per-tag, not uniformly:

- **Environment**: auto-remediated to `Unknown` if missing. Low-stakes —
  an "Unknown" environment is easy to spot in a report and correct later,
  and doesn't misattribute cost or ownership to the wrong party.
- **CostCenter** and **Owner**: flagged for human review only, never
  auto-filled. Guessing either risks charging the wrong team's budget or
  assigning accountability to someone uninvolved — worse outcomes than
  simply leaving the resource visibly non-compliant until a person
  corrects it.

## Alternatives considered
- **Auto-remediate all three tags**: rejected — optimizes for "green
  dashboard" compliance numbers over actually-correct cost attribution,
  which defeats the purpose of a FinOps platform.
- **Flag-only for all three, no auto-remediation at all**: rejected —
  misses a real opportunity to demonstrate self-healing governance for
  the one tag where a safe default genuinely exists.

## Consequences
- Compliance reporting must distinguish "auto-remediated" from
  "flagged, pending human review" — a single compliance percentage
  isn't enough on its own.
- The remediation identity only needs `modify` rights on the
  `Environment` tag; `CostCenter`/`Owner` policies remain deny/audit-only,
  keeping the automation's permissions minimal.
