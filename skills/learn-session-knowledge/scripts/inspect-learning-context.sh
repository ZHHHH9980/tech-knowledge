#!/usr/bin/env bash
set -euo pipefail

root="${1:-.}"
cd "$root"

echo "== cwd =="
pwd

echo
echo "== git =="
git status --short --branch 2>/dev/null || echo "not a git repository"

echo
echo "== explicit learning protocol =="
if [ -f docs/rules/learning-protocol.md ]; then
  echo "FOUND docs/rules/learning-protocol.md"
  sed -n '1,220p' docs/rules/learning-protocol.md
else
  echo "missing docs/rules/learning-protocol.md"
fi

echo
echo "== rule files mentioning learning/memory =="
for f in AGENTS.md CLAUDE.md WORKSPACE.md WORKSPACE.markdown workspace.yaml workspace.yml; do
  if [ -f "$f" ]; then
    matches="$(grep -nEi 'learn|learning|memory|knowledge|沉淀|记忆|知识' "$f" || true)"
    if [ -n "$matches" ]; then
      echo "-- $f"
      printf '%s\n' "$matches"
    fi
  fi
done

echo
echo "== repository shape =="
find . -maxdepth 2 -type d \
  -not -path './.git*' \
  -not -path './node_modules*' \
  -not -path './vendor*' \
  | sort | sed -n '1,120p'

echo
echo "== candidate docs/index files =="
find . -maxdepth 4 \( -name 'README*' -o -name 'INDEX.md' -o -name 'docs' \) 2>/dev/null \
  | sort | sed -n '1,160p'

echo
echo "== likely stack markers =="
find . -maxdepth 3 -type f \( \
  -name 'package.json' -o -name 'pyproject.toml' -o -name 'go.mod' -o -name 'Cargo.toml' -o \
  -name 'pom.xml' -o -name 'build.gradle' -o -name 'Makefile' -o -name 'workspace.yaml' -o -name 'workspace.yml' \
\) 2>/dev/null | sort | sed -n '1,120p'
