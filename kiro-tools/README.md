# Kiro Tools

Bulk import Kiro AI refresh tokens into 9Router.

## How It Works

The tool runs **inside your 9Router** at `http://localhost:20128/kiro.html`. Because it's on the same origin, there are no CORS issues, no extensions, no installs.

## Usage

1. Make sure 9Router is running
2. Open `http://localhost:20128/kiro.html` in your browser
3. Paste your Kiro refresh tokens (one per line)
4. Click **Process**

## GitHub Pages Landing

The page at `https://jinkaka98.github.io/kiro-tools/` detects whether 9Router is running and provides a direct link to the tool.

## File Location

The tool file `kiro.html` lives in 9Router's public folder:
- **Windows**: `%APPDATA%\9router\public\kiro.html`
- **macOS/Linux**: `~/.9router/public/kiro.html`

## Security

- Tokens go directly from your browser to your local 9Router
- No data is sent to any third-party server
- No telemetry, no tracking
