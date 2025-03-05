#!/bin/bash
# Installation script for development tools

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET_DIR="${HOME}/.local/bin"

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Check if the target directory is in PATH
if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
  echo "Warning: $TARGET_DIR is not in your PATH"
  echo "Add the following line to your ~/.bashrc or ~/.zshrc:"
  echo "export PATH=\"\$PATH:$TARGET_DIR\""
fi

# Install GitHub scripts
echo "Installing GitHub scripts..."
for script in "${SCRIPT_DIR}/github-scripts/"*.sh; do
  if [ -f "$script" ]; then
    script_name=$(basename "$script")
    target="${TARGET_DIR}/${script_name}"
    cp "$script" "$target"
    chmod +x "$target"
    echo "Installed: $script_name"
  fi
done

# Install CI tools
echo "Installing CI tools..."
for script in "${SCRIPT_DIR}/ci-tools/"*.sh; do
  if [ -f "$script" ]; then
    script_name=$(basename "$script")
    target="${TARGET_DIR}/${script_name}"
    cp "$script" "$target"
    chmod +x "$target"
    echo "Installed: $script_name"
  fi
done

# Install development tools
echo "Installing development tools..."
for script in "${SCRIPT_DIR}/development/"*.sh; do
  if [ -f "$script" ]; then
    script_name=$(basename "$script")
    target="${TARGET_DIR}/${script_name}"
    cp "$script" "$target"
    chmod +x "$target"
    echo "Installed: $script_name"
  fi
done

echo "Installation complete!"
echo "You can now use the tools from anywhere if $TARGET_DIR is in your PATH."
