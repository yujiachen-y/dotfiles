---
name: mermaid-viewer
description: Renders Mermaid diagrams in a local browser with beautiful themes. This skill should be used when creating, viewing, or sharing flowcharts, sequence diagrams, state diagrams, class diagrams, or ER diagrams. Triggers include requests to "show this as a diagram", "visualize this flow", "create a mermaid chart", or any Mermaid-related visualization task.
---

# Mermaid Viewer

A local server for rendering Mermaid diagrams with beautiful-mermaid themes and live reload.

## Quick Start

1. Write Mermaid code to a `.mmd` file in `/tmp/mermaid-session/`
2. Start the server (if not running)
3. Open browser to view the diagram

## Workflow

### Step 1: Create the Mermaid File

Write the Mermaid diagram to `/tmp/mermaid-session/<name>.mmd`:

```bash
mkdir -p /tmp/mermaid-session
cat > /tmp/mermaid-session/diagram.mmd << 'EOF'
graph TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action 1]
    B -->|No| D[Action 2]
    C --> E[End]
    D --> E
EOF
```

### Step 2: Start the Server

Run the start script (first run will install dependencies):

```bash
~/.claude/skills/mermaid-viewer/scripts/start-server.sh
```

The server runs at `http://localhost:3456` and watches for file changes.

### Step 3: Open in Browser

```bash
open http://localhost:3456
```

The browser will auto-reload when `.mmd` files change.

## Managing Multiple Diagrams

Create multiple `.mmd` files in `/tmp/mermaid-session/`:

```bash
# Create different diagrams
echo 'graph LR; A-->B-->C' > /tmp/mermaid-session/flow.mmd
echo 'sequenceDiagram; Alice->>Bob: Hello' > /tmp/mermaid-session/sequence.mmd
echo 'stateDiagram-v2; [*] --> Active' > /tmp/mermaid-session/state.mmd
```

Switch between diagrams using the file selector in the web UI.

## Theme Selection

The viewer supports 15 built-in themes from beautiful-mermaid:

- tokyo-night (default)
- catppuccin-mocha
- dracula
- github-dark
- nord
- solarized-dark
- And more...

Select themes via the dropdown in the web UI.

## Supported Diagram Types

- **Flowcharts**: `graph TD` / `graph LR`
- **Sequence Diagrams**: `sequenceDiagram`
- **State Diagrams**: `stateDiagram-v2`
- **Class Diagrams**: `classDiagram`
- **ER Diagrams**: `erDiagram`

## Prerequisites

- **Bun**: Install with `curl -fsSL https://bun.sh/install | bash`
- Dependencies are auto-installed on first server start

## Example: Visualizing a Code Flow

When asked to visualize code architecture or flow:

```bash
mkdir -p /tmp/mermaid-session
cat > /tmp/mermaid-session/architecture.mmd << 'EOF'
graph TB
    subgraph Frontend
        UI[React App]
        State[Redux Store]
    end

    subgraph Backend
        API[REST API]
        Auth[Auth Service]
        DB[(PostgreSQL)]
    end

    UI --> State
    UI --> API
    API --> Auth
    API --> DB
EOF

# Start server if not running
~/.claude/skills/mermaid-viewer/scripts/start-server.sh &

# Open browser
open http://localhost:3456
```

## Server Management

Check if server is running:
```bash
lsof -i :3456
```

Stop the server:
```bash
pkill -f "bun.*server.ts"
```

## Resources

### scripts/

- `server.ts` - Bun server with beautiful-mermaid rendering and SSE live reload
- `start-server.sh` - Startup script with dependency installation
- `package.json` - Dependencies (beautiful-mermaid)
