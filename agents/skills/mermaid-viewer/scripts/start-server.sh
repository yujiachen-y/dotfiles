#!/bin/bash
# Start the Mermaid Viewer server

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if bun is installed
if ! command -v bun &> /dev/null; then
    echo "Error: Bun is not installed."
    echo "Install it with: curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    bun install
fi

# Start the server
exec bun run server.ts
