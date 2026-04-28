# Xixero Website

This repository contains the official website for **Xixero**, a Local AI Gateway desktop application for Windows.

## 🌐 Live Site

Visit the website at: **https://jinkaka98.github.io**

## 🚀 About Xixero

Xixero is a Local AI Gateway that acts as a reverse proxy between AI-powered IDEs (Trae.ai, Cursor, VS Code) and AI providers (OpenAI, Anthropic, OpenRouter). Users point their IDE to `localhost:1445` and Xixero routes requests transparently.

### Key Features

- **AI Gateway**: Connect to OpenAI, Anthropic, OpenRouter seamlessly
- **One-Click Setup**: Auto MITM proxy, zero configuration needed  
- **IDE Integration**: Works with Trae.ai, Cursor, VS Code
- **Model Mixing**: Remap and combine models across providers

## 🛠️ Tech Stack

- **Frontend**: Vanilla HTML, CSS, JavaScript (no frameworks)
- **Design**: Cyberpunk/terminal aesthetic with dark theme
- **Fonts**: Syne (headings), JetBrains Mono (code)
- **Deployment**: GitHub Pages with automated CI/CD

## 📁 Project Structure

```
├── index.html          # Main landing page
├── style.css           # Cyberpunk styling
├── app.js              # Dynamic content & interactions
├── 404.html            # Custom error page
├── install.ps1         # PowerShell installation script
├── releases/
│   └── latest.json     # Version manifest
└── .github/workflows/
    └── static.yml      # GitHub Pages deployment
```

## 🎨 Design System

### Colors
- **Background**: `#000000`, `#0a0a0f`
- **Accent**: `#3b82f6` (Electric Blue)
- **Text**: `#ffffff`, `#a1a1aa`, `#71717a`

### Typography
- **Headings**: Syne (Google Fonts)
- **Code/Mono**: JetBrains Mono (Google Fonts)
- **Body**: System fonts

### Effects
- Glowing borders and shadows
- Grid/dot pattern overlays
- Smooth scroll-reveal animations
- Terminal-style code blocks

## 🚀 Development

### Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/jinkaka98/jinkaka98.github.io.git
   cd jinkaka98.github.io
   ```

2. Serve locally (any HTTP server):
   ```bash
   # Python
   python -m http.server 8000
   
   # Node.js
   npx serve .
   
   # PHP
   php -S localhost:8000
   ```

3. Open `http://localhost:8000` in your browser

### Release Management

Update `releases/latest.json` to modify:
- Version number
- Download links
- File sizes
- Changelog content

The website automatically loads this data to update:
- Version badge in navbar
- Download button information
- Changelog section

### Deployment

The site automatically deploys to GitHub Pages when changes are pushed to the `main` branch via GitHub Actions.

## 📱 Responsive Design

The website is fully responsive with breakpoints at:
- **Mobile**: 375px+
- **Tablet**: 768px+
- **Desktop**: 1024px+
- **Large**: 1440px+

## ♿ Accessibility

- Semantic HTML structure
- ARIA labels and roles
- Keyboard navigation support
- Focus indicators
- Alt text for images
- Color contrast compliance

## 🔗 Links

- **Website**: https://jinkaka98.github.io
- **Discord**: https://discord.gg/TFErxnnEfY
- **GitHub**: https://github.com/jinkaka98/xixero

## 📄 License

This website is open source. The Xixero application itself is proprietary software.

---

Built with ⚡ by [jinkaka98](https://github.com/jinkaka98)