#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="$(pwd)"
DRY_RUN=false
SKIP_BUILD=false

usage() {
  cat <<'EOF'
Backstage Plugin Installation Script

Usage:
  ./install-plugins.sh [--app-path /path/to/backstage-app] [--dry-run] [--skip-build]

Options:
  --app-path   Path to the Backstage app root (default: current directory)
  --dry-run    Print commands without executing them
  --skip-build Skip final `yarn build`
  -h, --help   Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-path)
      APP_PATH="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --skip-build)
      SKIP_BUILD=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

run_cmd() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

echo "=========================================="
echo "Backstage Plugin Installation Script"
echo "=========================================="
echo "App path: $APP_PATH"
echo ""

if [[ ! -f "$APP_PATH/package.json" || ! -d "$APP_PATH/packages/app" || ! -d "$APP_PATH/packages/backend" ]]; then
  echo "Error: '$APP_PATH' is not a Backstage app root."
  echo "Expected: package.json, packages/app, packages/backend."
  exit 1
fi

if ! command -v yarn >/dev/null 2>&1; then
  echo "Error: yarn is required."
  exit 1
fi

FRONTEND_PACKAGES=(
  "@spotify/backstage-plugin-terraform"
  "@backstage/plugin-github"
  "@backstage/plugin-kubernetes"
  "@backstage/plugin-jenkins"
  "@aws-backstage/plugin-aws-core"
  "@aws-backstage/plugin-s3"
  "@backstage/plugin-scaffolder"
)

BACKEND_PACKAGES=(
  "@backstage/plugin-terraform-backend"
  "@spotify/backstage-plugin-scaffolder-backend-module-terraform"
  "@backstage/plugin-github-backend"
  "@backstage/plugin-kubernetes-backend"
  "@backstage/plugin-jenkins-backend"
  "@aws-backstage/plugin-aws-backend"
  "@backstage/plugin-scaffolder-backend-module-github"
)

echo "[1/4] Installing frontend plugins"
run_cmd yarn --cwd "$APP_PATH/packages/app" add "${FRONTEND_PACKAGES[@]}"
echo "Frontend plugins installed."
echo ""

echo "[2/4] Installing backend plugins"
run_cmd yarn --cwd "$APP_PATH/packages/backend" add "${BACKEND_PACKAGES[@]}"
echo "Backend plugins installed."
echo ""

echo "[3/4] Integration guidance"
echo "Use these files from this repository:"
echo "  - $SCRIPT_DIR/app-config-plugins.yaml"
echo "  - $SCRIPT_DIR/PLUGIN-INSTALLATION-WSL.md"
echo "  - $SCRIPT_DIR/plugin-code-snippets.md"
echo ""

echo "[4/4] Verifying installation"
if [[ "$SKIP_BUILD" == "true" ]]; then
  echo "Skipping build by request."
else
  run_cmd yarn --cwd "$APP_PATH" build
fi

echo ""
echo "=========================================="
echo "Plugin installation workflow completed."
echo "=========================================="
echo "Next steps:"
echo "  1. Merge app-config settings."
echo "  2. Apply frontend/backend code snippets."
echo "  3. Start Backstage and verify /terraform, /github, /kubernetes, /jenkins."
