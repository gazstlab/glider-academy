#!/usr/bin/env bash
# DESIGN-SYSTEM.md §9: UI copy lives in locale files, never inline, and locales
# stay in parity.
#
# pt-BR is the source. English is optional — the product ships in Portuguese and
# grows into English when it is ready. But a locale that exists must be
# complete: a half-translated `en` is worse than no `en` at all, because the
# fallback is silent. The learner gets a screen in two languages and no error
# anywhere.
#
# So this is not "translate everything now". It is "whatever you started, finish".
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 1

ROOT=${LOCALES_ROOT:-src/locales}
SOURCE=${SOURCE_LOCALE:-pt-BR}

if [ ! -d "$ROOT" ]; then
  echo "  skipped · no $ROOT yet"
  exit 0
fi
if [ ! -d "$ROOT/$SOURCE" ]; then
  echo "$ROOT exists but the source locale $ROOT/$SOURCE does not." >&2
  echo "Every other locale is compared against it, so it cannot be missing." >&2
  exit 1
fi

keys() { jq -r '[paths(scalars) | join(".")] | sort[]' "$1" 2>/dev/null; }

failures=0
targets=0

for dir in "$ROOT"/*/; do
  locale=$(basename "$dir")
  [ "$locale" = "$SOURCE" ] && continue
  targets=$((targets + 1))
  echo "  $locale"

  for src in "$ROOT/$SOURCE"/*.json; do
    [ -f "$src" ] || continue
    file=$(basename "$src")
    dst="$dir$file"

    if [ ! -f "$dst" ]; then
      printf '    MISSING FILE  %s\n' "$file" >&2
      failures=$((failures + 1))
      continue
    fi

    if ! jq -e . "$dst" >/dev/null 2>&1; then
      printf '    INVALID JSON  %s\n' "$file" >&2
      failures=$((failures + 1))
      continue
    fi

    missing=$(comm -23 <(keys "$src") <(keys "$dst"))
    extra=$(comm -13 <(keys "$src") <(keys "$dst"))

    if [ -n "$missing" ] || [ -n "$extra" ]; then
      failures=$((failures + 1))
      printf '    OUT OF PARITY %s\n' "$file" >&2
      [ -n "$missing" ] && printf '%s\n' "$missing" | sed 's/^/      missing: /' >&2
      # An extra key is not harmless: it is copy nobody can reach, and it hides
      # a rename that only landed on one side.
      [ -n "$extra" ]   && printf '%s\n' "$extra"   | sed 's/^/      orphan:  /' >&2
    else
      printf '    ok            %s\n' "$file"
    fi
  done

  # A file only in the target locale is copy the source cannot render.
  for dst in "$dir"*.json; do
    [ -f "$dst" ] || continue
    file=$(basename "$dst")
    if [ ! -f "$ROOT/$SOURCE/$file" ]; then
      printf '    NOT IN SOURCE %s\n' "$file" >&2
      failures=$((failures + 1))
    fi
  done
done

echo
if [ "$failures" -eq 0 ]; then
  echo "  ok · $SOURCE plus $targets locale(s), all in parity"
  exit 0
fi
{
  echo "$failures parity problem(s)."
  echo
  echo "Either complete the locale or remove it. A locale that exists and is"
  echo "incomplete fails silently at runtime, which is the one failure mode a"
  echo "teaching product cannot afford."
} >&2
exit 1
