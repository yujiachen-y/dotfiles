/**
 * Mermaid Viewer Server
 *
 * A local server that renders Mermaid diagrams using beautiful-mermaid.
 * Watches /tmp/mermaid-session/ for .mmd files and provides a web UI.
 */

import { renderMermaid, THEMES } from "beautiful-mermaid";
import { watch } from "fs";
import { readdir, readFile, mkdir } from "fs/promises";
import { join } from "path";

const PORT = 3456;
const SESSION_DIR = "/tmp/mermaid-session";

// Ensure session directory exists
await mkdir(SESSION_DIR, { recursive: true });

// Available themes from beautiful-mermaid
const themeNames = Object.keys(THEMES);

// Track connected SSE clients for live reload
const clients: Set<ReadableStreamDefaultController> = new Set();

// Watch for file changes
watch(SESSION_DIR, { recursive: true }, () => {
  // Notify all connected clients to reload
  for (const client of clients) {
    try {
      client.enqueue(new TextEncoder().encode("data: reload\n\n"));
    } catch {
      clients.delete(client);
    }
  }
});

async function getMermaidFiles(): Promise<string[]> {
  try {
    const files = await readdir(SESSION_DIR);
    return files.filter(f => f.endsWith(".mmd")).sort();
  } catch {
    return [];
  }
}

async function renderDiagram(filename: string, theme: string): Promise<string> {
  const filepath = join(SESSION_DIR, filename);
  const content = await readFile(filepath, "utf-8");

  const themeConfig = THEMES[theme as keyof typeof THEMES] || THEMES["tokyo-night"];
  const svg = await renderMermaid(content, themeConfig);

  return svg;
}

function generateHTML(files: string[], currentFile: string | null, svg: string | null, currentTheme: string, error: string | null): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mermaid Viewer</title>
  <style>
    :root {
      --bg: #1a1b26;
      --fg: #a9b1d6;
      --accent: #7aa2f7;
      --surface: #24283b;
      --border: #414868;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background: var(--bg);
      color: var(--fg);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }
    header {
      background: var(--surface);
      border-bottom: 1px solid var(--border);
      padding: 1rem 2rem;
      display: flex;
      align-items: center;
      gap: 2rem;
      flex-wrap: wrap;
    }
    h1 {
      font-size: 1.25rem;
      font-weight: 600;
      color: var(--accent);
    }
    .controls {
      display: flex;
      gap: 1rem;
      align-items: center;
      flex-wrap: wrap;
    }
    label {
      font-size: 0.875rem;
      color: var(--fg);
    }
    select {
      background: var(--bg);
      color: var(--fg);
      border: 1px solid var(--border);
      border-radius: 4px;
      padding: 0.5rem 1rem;
      font-size: 0.875rem;
      cursor: pointer;
    }
    select:hover {
      border-color: var(--accent);
    }
    main {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    }
    .diagram-container {
      max-width: 100%;
      overflow: auto;
    }
    .diagram-container svg {
      max-width: 100%;
      height: auto;
    }
    .empty-state {
      text-align: center;
      color: var(--fg);
      opacity: 0.7;
    }
    .empty-state h2 {
      font-size: 1.5rem;
      margin-bottom: 1rem;
    }
    .empty-state code {
      background: var(--surface);
      padding: 0.25rem 0.5rem;
      border-radius: 4px;
      font-size: 0.875rem;
    }
    .error {
      background: #f7768e22;
      border: 1px solid #f7768e;
      color: #f7768e;
      padding: 1rem;
      border-radius: 8px;
      max-width: 600px;
    }
    .file-list {
      display: flex;
      gap: 0.5rem;
      flex-wrap: wrap;
    }
    .file-btn {
      background: ${currentFile ? 'var(--bg)' : 'var(--accent)'};
      color: var(--fg);
      border: 1px solid var(--border);
      border-radius: 4px;
      padding: 0.5rem 1rem;
      font-size: 0.875rem;
      cursor: pointer;
      text-decoration: none;
    }
    .file-btn:hover, .file-btn.active {
      background: var(--accent);
      color: var(--bg);
      border-color: var(--accent);
    }
  </style>
</head>
<body>
  <header>
    <h1>Mermaid Viewer</h1>
    <div class="controls">
      <label>File:</label>
      <div class="file-list">
        ${files.length === 0
          ? '<span style="opacity: 0.5">No files</span>'
          : files.map(f => `<a href="/?file=${encodeURIComponent(f)}&theme=${currentTheme}" class="file-btn ${f === currentFile ? 'active' : ''}">${f}</a>`).join('')
        }
      </div>
    </div>
    <div class="controls">
      <label for="theme">Theme:</label>
      <select id="theme" onchange="window.location.href='/?file=${currentFile || ''}&theme='+this.value">
        ${themeNames.map(t => `<option value="${t}" ${t === currentTheme ? 'selected' : ''}>${t}</option>`).join('')}
      </select>
    </div>
  </header>
  <main>
    ${error
      ? `<div class="error"><strong>Error:</strong> ${error}</div>`
      : svg
        ? `<div class="diagram-container">${svg}</div>`
        : `<div class="empty-state">
            <h2>No diagram selected</h2>
            <p>Create a <code>.mmd</code> file in <code>/tmp/mermaid-session/</code></p>
          </div>`
    }
  </main>
  <script>
    // Server-Sent Events for live reload
    const evtSource = new EventSource('/events');
    evtSource.onmessage = () => window.location.reload();
  </script>
</body>
</html>`;
}

const server = Bun.serve({
  port: PORT,
  async fetch(req) {
    const url = new URL(req.url);

    // SSE endpoint for live reload
    if (url.pathname === "/events") {
      const stream = new ReadableStream({
        start(controller) {
          clients.add(controller);
        },
        cancel(controller) {
          clients.delete(controller);
        }
      });

      return new Response(stream, {
        headers: {
          "Content-Type": "text/event-stream",
          "Cache-Control": "no-cache",
          "Connection": "keep-alive",
        },
      });
    }

    // Main page
    const files = await getMermaidFiles();
    const currentFile = url.searchParams.get("file") || files[0] || null;
    const currentTheme = url.searchParams.get("theme") || "tokyo-night";

    let svg: string | null = null;
    let error: string | null = null;

    if (currentFile && files.includes(currentFile)) {
      try {
        svg = await renderDiagram(currentFile, currentTheme);
      } catch (e) {
        error = e instanceof Error ? e.message : String(e);
      }
    }

    const html = generateHTML(files, currentFile, svg, currentTheme, error);

    return new Response(html, {
      headers: { "Content-Type": "text/html" },
    });
  },
});

console.log(`🎨 Mermaid Viewer running at http://localhost:${PORT}`);
console.log(`📁 Watching: ${SESSION_DIR}`);
console.log(`\nCreate .mmd files in the session directory to see them rendered.`);
