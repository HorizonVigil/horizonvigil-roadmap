# Competitive read — Cloudeva.ai, 2026-09-22

Source: cloudeva.ai homepage claims, read 2026-09-22. Their marketing, our
measurements — nothing below assumes their claims are implemented.

---

## What they sell

| Their pillar | Claim |
|---|---|
| **Decision governance** | "Every recommendation goes through your team for review and approval before anything happens" — Decision Queue, Decision Records (immutable) |
| **Actor attribution** | "Who did it" across all change types, **including automated systems** |
| **Agentic AI governance** | First platform designed to govern changes made by "AI agents, Copilot, Amazon Q, Terraform, auto-scale, remediation bots" |
| **Signal reduction** | "400+ weekly alert signals → 10 governed decisions" |
| **Three-in-one** | FinOps + SecOps + ComplianceOps in one view |
| **Non-invasive** | Works "on top of what you already have"; reads signals from existing tools |

Positioning: credit-based pricing, 14-day trial, 15-minute setup, enterprise
multi-cloud.

---

## Where we are genuinely stronger

**We own the collection; they read other tools' signals.** Their
"non-invasive, works on top of what you already have" is a real advantage for
time-to-value and a real ceiling on trustworthiness: a platform that reads
another tool's output inherits that tool's blind spots and cannot say how
fresh anything is. We call AWS APIs directly and carry provenance per record.

**Our honesty machinery has no equivalent in their pitch.** Every number we
publish can distinguish *measured zero* from *not measured*:
`NOT_ASSESSED`, `NOT_COLLECTED`, availability envelopes, freshness SLOs,
coverage, `complete` flags, `validity` on recommendations. "400 signals → 10
decisions" is a compression claim; ours is a correctness claim, and the second
is the one that survives an auditor.

**Read-only by design.** They emphasise human approval *before execution*. We
do not execute provider mutations at all in V1 — the same safety property,
with nothing to misconfigure.

---

## Where they were genuinely ahead — and what we did about it

### 1. Actor attribution — CLOSED 2026-09-22

Their headline, and our sharpest gap. We already collected **every** signal
needed — `userAgent`, `userIdentity.type`, `userIdentity.arn`, `eventSource` —
parsed `invokedBy` and **threw it away**, and did zero classification. We
handed customers raw user-agent strings and let them work out that
`APN/1.0 HashiCorp/1.0 Terraform/1.5.7` meant infrastructure-as-code.

Now shipped (`connector-aws lib/changeProvenance.ts`, frontend `ActorBadge`):
classification into human / automation / aws_service / unknown, with the
specific tool named — Terraform, OpenTofu, CDK, Pulumi, Ansible,
CloudFormation, Amazon Q, AI coding assistants, console, CLI, SDK — plus the
AWS service that self-initiated a change.

**And it refuses to guess.** Every verdict carries the `basis` that produced
it. The AWS CLI is used by people at terminals *and* by half the CI pipelines
in the world, and CloudTrail does not distinguish them — so the kind is `cli`
and the class stays `unknown`, with the ambiguity named. A misattributed
change is worse than an unattributed one: it sends the reviewer to the wrong
person. That distinction is a feature no marketing page makes, and it is the
part a security team will test us on.

### 2. Decision Queue / Decision Records — NOT BUILT

Their second pillar. We have three *separate* review mechanisms already —
`compliance_exceptions` (accepted risk with a mandatory expiry),
`control_evaluations.reviewer_decision`, and recommendation dismiss/exclude —
with no unifying ledger and no immutable record of who decided what.

The honest V1 shape is **not** an approval queue for future actions, because
we execute nothing. It is a **review ledger over what was found**: this
change, this finding, this recommendation — reviewed, by whom, when, with what
reasoning, and for how long. We already have the three halves; they need one
contract.

Largest remaining competitive gap. Not started.

### 3. Signal reduction — PARTIAL

We already suppress harder than most: invalid recommendations are excluded
from savings, V2 findings are gated out of V1, unproven zeros are refused. But
we do not *rank* or *group*, and a reviewer facing a week of changes has no
"here are the 10 that matter". Our provenance classification is the raw
material for exactly that — an unattributed console change to a security group
at 02:00 is not the same signal as Terraform applying a reviewed plan.

### 4. AI advisor — NOT BUILT, deliberately

They ship "EVA Advisor". Our ChatWidget is gated off. An advisor that
summarises data we have not verified would undo the entire evidence discipline
above; one built *on* the availability envelopes would be differentiated. Not
a V1 item either way.

---

## Recommended order

1. **Review ledger** (their pillar 1) — unify the three existing mechanisms
   behind one immutable decision record. Highest competitive value, and it
   makes our evidence model visible as a product surface rather than an
   internal discipline.
2. **Change ranking** built on provenance (their pillar 3) — cheap now that
   classification exists.
3. Leave the AI advisor until the ledger gives it something trustworthy to
   talk about.

---

## The line worth holding

Their pitch is *fewer, governed decisions*. Ours should be *decisions you can
defend*. Every capability above already carries its own evidence, freshness
and coverage — so when a customer asks "how do you know?", we answer with a
row, and they answer with a model. That is the durable difference, and it is
worth protecting in every feature we add: **never ship a capability that
cannot say how it knows.**
