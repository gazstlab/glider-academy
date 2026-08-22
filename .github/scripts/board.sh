#!/usr/bin/env bash
# Move one item into a board column (Projects v2).
#
# Usage: board.sh <owner> <project-number> <content-node-id> <column>
# Needs GH_TOKEN with Projects permission. The runner's GITHUB_TOKEN cannot
# reach Projects v2 — the number one cause of "the workflow went green and the
# card did not move".
#
# addProjectV2ItemById is idempotent: if the item is already on the board it
# returns the existing id instead of duplicating. That is why there is no
# pagination here — looking the item up in the list would cost a sweep of the
# whole board on every event.
set -euo pipefail

owner=${1:?owner}
number=${2:?project number}
content=${3:?content node id}
column=${4:?target column}

api() { gh api graphql "$@"; }

# ---- project, the Status field and its options ---------------------------
project=$(api -f owner="$owner" -F number="$number" -f query='
  query($owner:String!, $number:Int!) {
    organization(login:$owner) {
      projectV2(number:$number) {
        id
        title
        field(name:"Status") {
          ... on ProjectV2SingleSelectField { id options { id name } }
        }
      }
    }
  }')

project_id=$(printf '%s' "$project" | jq -r '.data.organization.projectV2.id // empty')
field_id=$(printf '%s' "$project" | jq -r '.data.organization.projectV2.field.id // empty')

if [ -z "$project_id" ]; then
  echo "::error::project $number not found in organization $owner" >&2
  exit 1
fi
if [ -z "$field_id" ]; then
  echo "::error::the project has no single-select field named Status" >&2
  exit 1
fi

option_id=$(printf '%s' "$project" \
  | jq -r --arg c "$column" '.data.organization.projectV2.field.options[] | select(.name==$c) | .id')

if [ -z "$option_id" ]; then
  {
    echo "::error::column \"$column\" does not exist on the board."
    echo "Available columns:"
    printf '%s' "$project" | jq -r '.data.organization.projectV2.field.options[] | "  " + .name'
    echo
    echo "Renaming a column in the browser breaks this workflow silently:"
    echo "the job stays green and the card does not move. Align the name or"
    echo "adjust .github/workflows/project.yml."
  } >&2
  exit 1
fi

# ---- make sure the item is on the board, then move it --------------------
item_id=$(api -f project="$project_id" -f content="$content" -f query='
  mutation($project:ID!, $content:ID!) {
    addProjectV2ItemById(input:{projectId:$project, contentId:$content}) {
      item { id }
    }
  }' --jq '.data.addProjectV2ItemById.item.id')

api -f project="$project_id" -f item="$item_id" -f field="$field_id" -f option="$option_id" -f query='
  mutation($project:ID!, $item:ID!, $field:ID!, $option:String!) {
    updateProjectV2ItemFieldValue(input:{
      projectId: $project, itemId: $item, fieldId: $field,
      value: { singleSelectOptionId: $option }
    }) { projectV2Item { id } }
  }' > /dev/null

echo "  → $column"
