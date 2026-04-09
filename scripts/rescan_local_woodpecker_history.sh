#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-/home/cooneycw/Projects}"
OUT="${2:-/home/cooneycw/Projects/woodpecker-baseline/research/local/latest-history-scan.txt}"

repos=()
for d in "$ROOT"/*; do
  if [ -d "$d/.git" ] && { [ -f "$d/.woodpecker.yml" ] || [ -d "$d/.woodpecker" ]; }; then
    repos+=("$d")
  fi
done

{
  echo "woodpecker-history-scan generated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  for repo in "${repos[@]}"; do
    name="$(basename "$repo")"
    echo
    echo "=== $name ==="
    echo "path=$repo"
    count="$(git -C "$repo" rev-list --count HEAD -- .woodpecker .woodpecker.yml 2>/dev/null || echo 0)"
    echo "woodpecker_commit_count=$count"
    git -C "$repo" log -n 12 --date=short --pretty=format:'- %h|%ad|%s' -- \
      .woodpecker .woodpecker.yml scripts/woodpecker_deploy.sh scripts/woodpecker_fanout.py scripts/deploy_lock.sh scripts/docker_host_guard.sh 2>/dev/null || true
    echo
  done
} > "$OUT"

echo "wrote $OUT"
