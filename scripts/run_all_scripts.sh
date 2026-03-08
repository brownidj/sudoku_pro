#!/usr/bin/env zsh
set -u

if [[ -z "${ZSH_VERSION:-}" ]]; then
  exec zsh "$0" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SELF_NAME="$(basename "$0")"

scripts=("${(@f)$(find "$SCRIPT_DIR" -maxdepth 1 -type f ! -name "$SELF_NAME" | sort)}")

if (( ${#scripts} == 0 )); then
  echo "No scripts found in $SCRIPT_DIR"
  exit 0
fi

total=0
failed=0

for script_path in "${scripts[@]}"; do
  script_name="$(basename "$script_path")"
  total=$((total + 1))
  echo "==> Running: $script_name"

  if [[ -x "$script_path" ]]; then
    (cd "$ROOT_DIR" && "$script_path")
  elif [[ "$script_name" == *.py ]]; then
    (cd "$ROOT_DIR" && python3 "$script_path")
  elif [[ "$script_name" == *.sh ]]; then
    (cd "$ROOT_DIR" && zsh "$script_path")
  else
    echo "SKIP: unsupported script type: $script_name"
    continue
  fi

  exit_code=$?
  if (( exit_code != 0 )); then
    failed=$((failed + 1))
    echo "FAIL ($exit_code): $script_name"
  else
    echo "PASS: $script_name"
  fi
  echo
done

echo "Completed $total script(s), failures: $failed"
if (( failed != 0 )); then
  exit 1
fi
