#!/usr/bin/env bash
#
# I1 — re-apply the published least-privilege collection policy to both AWS
# principals, replacing AdministratorAccess.
#
# WHY THIS SCRIPT EXISTS RATHER THAN THE CHANGE BEING MADE FOR YOU
#
# HorizonVigil holds no AWS identity of its own: `connector-aws` carries no
# PLATFORM_AWS_* credentials, and cross-account AssumeRole is gated off. The
# only AWS credentials in the system are the customer's, encrypted at rest and
# decryptable only inside the connector. Using those to mutate IAM would breach
# the exact boundary this policy exists to enforce -- a collection role that
# can rewrite its own permissions is not a collection role.
#
# So this runs from YOUR AWS credentials, not the product's.
#
# WHAT IT DOES
#
#   1. Attaches the published policy as a customer-managed policy
#   2. DETACHES AdministratorAccess
#   3. Prints the resulting attached-policy list for both principals
#
# Order matters: attach before detach, so there is no window in which the
# principal can do neither.
#
# Run once per account. The two production principals, from
# cloud_connections (2026-09-23):
#
#   604179600483  connection "kamal-k8s"
#   354307071074  connection "pavan-test1"
#
set -euo pipefail

POLICY_FILE="$(dirname "$0")/horizonvigil-collection-policy.json"
POLICY_NAME="${POLICY_NAME:-HorizonVigilCollectionReadOnly}"

# The IAM principal these access keys belong to. Find it with:
#   aws sts get-caller-identity
# and, for a user, the name is the tail of the Arn.
PRINCIPAL_TYPE="${PRINCIPAL_TYPE:-user}"   # "user" or "role"
PRINCIPAL_NAME="${PRINCIPAL_NAME:-}"

if [ -z "$PRINCIPAL_NAME" ]; then
  echo "Set PRINCIPAL_NAME (and PRINCIPAL_TYPE=user|role) first." >&2
  echo "  aws sts get-caller-identity" >&2
  exit 1
fi

ACCOUNT="$(aws sts get-caller-identity --query Account --output text)"
echo "Account          : $ACCOUNT"
echo "Principal        : $PRINCIPAL_TYPE/$PRINCIPAL_NAME"
echo "Policy document  : $POLICY_FILE"
echo

# ---- 1. create or update the customer-managed policy ----------------------
POLICY_ARN="arn:aws:iam::${ACCOUNT}:policy/${POLICY_NAME}"

if aws iam get-policy --policy-arn "$POLICY_ARN" >/dev/null 2>&1; then
  echo "Policy exists; publishing a new default version…"
  # AWS caps a managed policy at 5 versions. Prune the oldest non-default
  # first so a re-run cannot fail on LimitExceeded.
  for v in $(aws iam list-policy-versions --policy-arn "$POLICY_ARN" \
      --query 'Versions[?IsDefaultVersion==`false`].VersionId' --output text); do
    aws iam delete-policy-version --policy-arn "$POLICY_ARN" --version-id "$v" || true
  done
  aws iam create-policy-version \
    --policy-arn "$POLICY_ARN" \
    --policy-document "file://${POLICY_FILE}" \
    --set-as-default >/dev/null
else
  echo "Creating policy…"
  aws iam create-policy \
    --policy-name "$POLICY_NAME" \
    --policy-document "file://${POLICY_FILE}" \
    --description "HorizonVigil read-only collection role. Least privilege: no credential-minting, no mutation, no secret retrieval." >/dev/null
fi
echo "  -> $POLICY_ARN"

# ---- 2. attach it BEFORE removing admin -----------------------------------
echo "Attaching the collection policy…"
aws iam "attach-${PRINCIPAL_TYPE}-policy" \
  "--${PRINCIPAL_TYPE}-name" "$PRINCIPAL_NAME" \
  --policy-arn "$POLICY_ARN"

# ---- 3. detach AdministratorAccess ----------------------------------------
ADMIN_ARN="arn:aws:iam::aws:policy/AdministratorAccess"
if aws iam "list-attached-${PRINCIPAL_TYPE}-policies" \
     "--${PRINCIPAL_TYPE}-name" "$PRINCIPAL_NAME" \
     --query 'AttachedPolicies[].PolicyArn' --output text | grep -q "$ADMIN_ARN"; then
  echo "Detaching AdministratorAccess…"
  aws iam "detach-${PRINCIPAL_TYPE}-policy" \
    "--${PRINCIPAL_TYPE}-name" "$PRINCIPAL_NAME" \
    --policy-arn "$ADMIN_ARN"
else
  echo "AdministratorAccess is not attached; nothing to detach."
fi

# ---- 4. show the end state ------------------------------------------------
echo
echo "Attached policies now:"
aws iam "list-attached-${PRINCIPAL_TYPE}-policies" \
  "--${PRINCIPAL_TYPE}-name" "$PRINCIPAL_NAME" \
  --query 'AttachedPolicies[].[PolicyName,PolicyArn]' --output table

echo
echo "Inline policies (these are NOT touched by this script — check them):"
aws iam "list-${PRINCIPAL_TYPE}-policies" "--${PRINCIPAL_TYPE}-name" "$PRINCIPAL_NAME" \
  --query 'PolicyNames' --output text

echo
echo "Done. Next: tell HorizonVigil to re-validate and re-scan, then confirm"
echo "the seven drifted services report granted and no type is degraded for a"
echo "permission reason."
