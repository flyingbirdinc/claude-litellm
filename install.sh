#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.local/bin"
TARGET_BIN="${TARGET_DIR}/claude-litellm"

mkdir -p "${TARGET_DIR}"
chmod +x "${SCRIPT_DIR}/claude-litellm"
cp "${SCRIPT_DIR}/claude-litellm" "${TARGET_BIN}"
chmod +x "${TARGET_BIN}"

echo "✓ Installed claude-litellm to ${TARGET_BIN}"

if [[ ":${PATH}:" != *":${TARGET_DIR}:"* ]]; then
  echo ""
  echo "Note: ${TARGET_DIR} is not currently in your PATH."
  echo "Add the following line to your ~/.zshrc or ~/.bashrc:"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi
