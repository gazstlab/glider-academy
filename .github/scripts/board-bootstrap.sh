#!/usr/bin/env bash
# Creates the Glider board and its fields. Run ONCE, by a person.
#
# Needs a scope the default gh token does not have:
#
#   gh auth refresh -s project,read:project
#
# Projects v2 cannot be configured from a file in the repository — there is no
# "board.yml" that GitHub reads. This script is as close as it gets: the board's
# definition is version-controlled here, and recreating it means re-running it
# instead of rebuilding it from memory in the browser six months from now.
set -euo pipefail

OWNER=${OWNER:-gazstlab}
TITLE=${TITLE:-Glider}

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

if ! gh auth status 2>&1 | rg -q 'project'; then
  {
    echo "The current token has no Projects scope. Run:"
    echo
    echo "  gh auth refresh -s project,read:project"
    echo
    echo "Without it the calls below fail with 'Resource not accessible',"
    echo "which does not tell you the problem is a scope."
  } >&2
  exit 1
fi

echo "Creating the board \"$TITLE\" under $OWNER"
project=$(gh project create --owner "$OWNER" --title "$TITLE" --format json)
number=$(printf '%s' "$project" | jq -r '.number')
project_id=$(printf '%s' "$project" | jq -r '.id')
echo "  project #$number created"

# ---- Status ---------------------------------------------------------------
# The board is born with Todo/In Progress/Done. Six columns instead of three
# because "In review" and "Blocked" are precisely the two states where a card
# stops moving — and a board that does not tell them apart cannot answer the
# only question people ask while looking at it: what is stuck, and on whom.
status_field=$(gh api graphql -f owner="$OWNER" -F number="$number" -f query='
  query($owner:String!, $number:Int!) {
    organization(login:$owner) { projectV2(number:$number) {
      field(name:"Status") { ... on ProjectV2SingleSelectField { id } } } }
  }' --jq '.data.organization.projectV2.field.id')

status_options='[
  {name:"Inbox",       color:GRAY,   description:"Arrived, not looked at yet"},
  {name:"Ready",       color:BLUE,   description:"Scope is clear, can be started"},
  {name:"In progress", color:YELLOW, description:"Someone is on it right now"},
  {name:"In review",   color:PURPLE, description:"PR open, waiting on gate and review"},
  {name:"Blocked",     color:RED,    description:"Stopped by something external"},
  {name:"Done",        color:GREEN,  description:"Merged and in production"}
]'

gh api graphql -f query="
  mutation {
    updateProjectV2Field(input:{
      fieldId: \"$status_field\",
      singleSelectOptions: $status_options
    }) { projectV2Field { ... on ProjectV2SingleSelectField { options { name } } } }
  }" --jq '.data.updateProjectV2Field.projectV2Field.options[].name' \
  | sed 's/^/  status · /'

# ---- custom fields --------------------------------------------------------
create_select() {
  local name=$1 options=$2
  gh api graphql -f query="
    mutation {
      createProjectV2Field(input:{
        projectId: \"$project_id\",
        dataType: SINGLE_SELECT,
        name: \"$name\",
        singleSelectOptions: $options
      }) { projectV2Field { ... on ProjectV2SingleSelectField { name } } }
    }" --jq '.data.createProjectV2Field.projectV2Field.name' \
    | sed 's/^/  field · /'
}

create_select "Track" '[
  {name:"Fundamentals",  color:BLUE, description:""},
  {name:"Scheduling",    color:BLUE, description:"Scheduling and logical date"},
  {name:"Dependencies",  color:BLUE, description:"Dependencies and trigger rules"},
  {name:"Retries",       color:BLUE, description:"Retries and failures"},
  {name:"Backfill",      color:BLUE, description:""},
  {name:"Executors",     color:BLUE, description:""},
  {name:"None",          color:GRAY, description:"Not content work"}
]'

create_select "Size" '[
  {name:"S", color:GREEN,  description:"Fits in a day"},
  {name:"M", color:YELLOW, description:"A few days"},
  {name:"L", color:RED,    description:"Too big. Split it into smaller issues"}
]'

# The §10 floor is the one gate no machine closes. Without a field of its own it
# becomes the item people forget on the day everything else is green.
create_select "Quality floor" '[
  {name:"Not applicable", color:GRAY,   description:"Does not touch UI"},
  {name:"Pending",        color:ORANGE, description:"Still to be checked by hand"},
  {name:"Checked",        color:GREEN,  description:"360px, keyboard, themes, colour blindness"}
]'

echo
echo "Board ready: https://github.com/orgs/$OWNER/projects/$number"
echo
echo "Now wire the workflow. In .github/workflows/project.yml, confirm:"
echo "  PROJECT_NUMBER: $number"
echo
echo "And create the secret with a fine-grained PAT that has Projects read/write:"
echo "  gh secret set PROJECTS_TOKEN --repo $OWNER/glider-academy"
