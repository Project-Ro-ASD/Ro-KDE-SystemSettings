#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE="$ROOT/.work/upstream"
mkdir -p "$WORKSPACE"

declare -A URLS=(
  [systemsettings]="https://invent.kde.org/plasma/systemsettings.git"
  [plasma-desktop]="https://invent.kde.org/plasma/plasma-desktop.git"
  [plasma-nm]="https://invent.kde.org/plasma/plasma-nm.git"
  [powerdevil]="https://invent.kde.org/plasma/powerdevil.git"
  [kscreen]="https://invent.kde.org/plasma/kscreen.git"
)

list_projects() {
  printf "%s\n" "${!URLS[@]}" | sort
}

fetch_project() {
  local project="$1"
  local url="${URLS[$project]:-}"
  local dest="$WORKSPACE/$project"

  if [[ -z "$url" ]]; then
    echo "Unknown upstream project: $project" >&2
    echo "Known projects:" >&2
    list_projects >&2
    exit 2
  fi

  if [[ -d "$dest/.git" ]]; then
    current="$(git -C "$dest" remote get-url origin)"
    if [[ "$current" != "$url" ]]; then
      echo "Refusing to update $dest: origin is $current, expected $url" >&2
      exit 3
    fi
    echo "Updating $project..."
    git -C "$dest" fetch --tags --prune origin
  elif [[ -e "$dest" ]]; then
    echo "Refusing to overwrite non-git path: $dest" >&2
    exit 4
  else
    echo "Cloning $project..."
    git clone "$url" "$dest"
  fi

  echo
  echo "$project workspace: $dest"
  echo "HEAD: $(git -C "$dest" rev-parse HEAD)"
  echo "Branch: $(git -C "$dest" branch --show-current || true)"
}

case "${1:-}" in
  list)
    list_projects
    ;;
  all)
    while IFS= read -r project; do
      fetch_project "$project"
      echo
    done < <(list_projects)
    ;;
  "")
    echo "Usage: bash scripts/fetch-upstream.sh <project|all|list>" >&2
    exit 2
    ;;
  *)
    fetch_project "$1"
    ;;
esac
