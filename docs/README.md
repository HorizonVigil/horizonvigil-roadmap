# HorizonVigil Product and Engineering Handbook

This directory is the documentation entry point for building HorizonVigil in a controlled order. GitHub issues remain the units of delivery; these documents define why they exist, when they may start, and what evidence closes them.

## Read in this order

1. [Product requirements](00-product/PRD.md)
2. [System architecture](01-architecture/ARCHITECTURE.md)
3. [Master execution order](02-delivery/MASTER-EXECUTION-ORDER.md)
4. [Security engineering](03-security/SECURITY-ENGINEERING.md)
5. [Testing and certification](04-testing/TESTING-AND-CERTIFICATION.md)
6. [Design system](05-design/DESIGN-SYSTEM.md)
7. [Code standards](06-engineering/CODE-STANDARDS.md)

Version scopes: [V1](versions/V1-CLOUD-FINOPS.md), [V2](versions/V2-OBSERVABILITY.md), [V3](versions/V3-VULNERABILITY-MANAGEMENT.md), and [Admin Console](versions/ADMIN-CONSOLE.md).

The root [AGENTS.md](../AGENTS.md) tells coding agents how to apply these documents.

## Product release order

| Release | Scope | GitHub phases | Exit gate |
|---|---|---:|---|
| Foundation | Product, architecture, tenant security, delivery platform, Admin and billing | 00–03 | Shared controls certified |
| V1 | Cloud and FinOps: AWS first, then GCP/Azure, AI intelligence and governance | 04–11 | Real multi-account and multi-cloud evidence |
| V2 | Observability: telemetry, infrastructure, APM, logs, traces, SLOs and incidents | 12–16 | Production-scale telemetry certification |
| V3 | Vulnerability management: CNAPP, AppSec, scanners, remediation and reporting | 17–20 | Security efficacy and platform certification |

No V2 production release starts before V1 certification. Design and architectural spikes may run earlier, but they cannot bypass release gates.
