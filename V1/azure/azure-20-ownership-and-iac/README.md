# AZURE-20 — Ownership and IaC

**Status: NOT STARTED**

**Depends on:** AZURE-08

## Missing

- Azure tags, plus resource group and subscription metadata as ownership signals
- ARM / Bicep / Terraform IaC mapping

## Note

Azure gives an ownership signal AWS lacks: the **resource group** is itself an organisational unit, so a resource group name often carries team or application meaning that a tag would carry in AWS.
