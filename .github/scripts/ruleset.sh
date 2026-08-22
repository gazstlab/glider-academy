#!/usr/bin/env bash
# Creates or updates the ruleset for the main branch.
#
# Protection configured in the browser is not reviewable, not reproducible, and
# nobody remembers what was switched on. Here it is a file.
#
# Usage: ruleset.sh [--dry-run]
# Requires admin permission on the repository.
set -euo pipefail

REPO=${REPO:-gazstlab/glider-academy}
NAME="main"
DRY=${1:-}

# The only required check is `gate`. It aggregates the others and explicitly
# distinguishes "skipped because there is no application yet" from "skipped
# because a dependency fell" — see the comment on the job in
# .github/workflows/ci.yml.
#
# Requiring `tests` and `lint` directly would look stricter and be weaker: on
# GitHub a skipped job counts as success, so the protection would switch itself
# off the day an `if:` changed.
#
# No required approvals: with a single maintainer, nobody approves their own PR
# and the repository would lock. What holds quality here is the gate plus the
# contract review, not a ceremonial approval.
rules=$(cat <<'JSON'
[
  { "type": "deletion" },
  { "type": "non_fast_forward" },
  { "type": "required_linear_history" },
  {
    "type": "pull_request",
    "parameters": {
      "required_approving_review_count": 0,
      "dismiss_stale_reviews_on_push": true,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": true,
      "allowed_merge_methods": ["squash"]
    }
  },
  {
    "type": "required_status_checks",
    "parameters": {
      "strict_required_status_checks_policy": true,
      "do_not_enforce_on_create": false,
      "required_status_checks": [{ "context": "gate" }]
    }
  }
]
JSON
)

body=$(jq -n --arg name "$NAME" --argjson rules "$rules" '{
  name: $name,
  target: "branch",
  enforcement: "active",
  conditions: { ref_name: { include: ["~DEFAULT_BRANCH"], exclude: [] } },
  bypass_actors: [],
  rules: $rules
}')

if [ "$DRY" = "--dry-run" ]; then
  printf '%s\n' "$body" | jq .
  exit 0
fi

existing=$(gh api "repos/$REPO/rulesets" --jq ".[] | select(.name==\"$NAME\") | .id" 2>/dev/null || true)

if [ -n "$existing" ]; then
  echo "Updating ruleset $existing"
  printf '%s' "$body" | gh api --method PUT "repos/$REPO/rulesets/$existing" --input - --jq '.name + " · " + .enforcement'
else
  echo "Creating ruleset"
  printf '%s' "$body" | gh api --method POST "repos/$REPO/rulesets" --input - --jq '.name + " · " + .enforcement'
fi

cat <<'TXT'

Enabled. Two things worth knowing before you need them:

  · There are no bypass_actors. Not even an admin pushes straight to main.
    That is deliberate: a silent bypass turns the gate into a suggestion.

  · The emergency exit is disabling the whole ruleset, which is loud and
    leaves an audit trail:

      gh api --method PUT repos/OWNER/REPO/rulesets/ID -f enforcement=disabled

    Loud is the intended property. If switching it off has to hurt a little,
    nobody switches it off out of laziness.

  · The "gate" check only starts existing after CI has run once. Enable this
    ruleset AFTER merging the pipeline, or every PR will wait on a check that
    never reports.
TXT
