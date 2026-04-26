/* ═══════════════════════════════════════════
   XIXERO Landing Page
   Downloads from /releases/ (Windows only)
   ═══════════════════════════════════════════ */

const RELEASES_BASE = '/releases'
const LATEST_JSON = `${RELEASES_BASE}/latest.json`

// --- Scroll Reveal ---
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible')
      observer.unobserve(entry.target)
    }
  })
}, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' })

document.querySelectorAll('.reveal').forEach(el => observer.observe(el))

// --- Load Release ---
async function loadRelease() {
  try {
    const resp = await fetch(LATEST_JSON)
    if (!resp.ok) throw new Error('No release')
    const data = await resp.json()
    renderRelease(data)
  } catch {
    document.getElementById('version-badge').textContent = 'COMING SOON'
    document.getElementById('download-section').innerHTML =
      '<p style="color:#6b6560;text-align:center;padding:40px;font-size:13px">No release available yet.</p>'
    document.getElementById('changelog-content').innerHTML =
      '<p style="color:#6b6560;font-size:13px">No releases published yet.</p>'
  }
}

function renderRelease(data) {
  const version = `v${data.version}`
  const win = data.binaries?.['windows-amd64']

  // Version badge
  document.getElementById('version-badge').textContent = `${version} AVAILABLE`

  // Download section - Windows only, direct download
  const dl = document.getElementById('download-section')
  if (win?.url) {
    const sizeMB = win.size ? `${(win.size / 1024 / 1024).toFixed(1)} MB` : ''
    dl.innerHTML = `
      <div class="dl-main reveal visible">
        <div class="dl-main__icon">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="currentColor"><path d="M0 3.449L9.75 2.1v9.451H0m10.949-9.602L24 0v11.4H10.949M0 12.6h9.75v9.451L0 20.699M10.949 12.6H24V24l-12.9-1.801"/></svg>
        </div>
        <div class="dl-main__info">
          <h3>Download for Windows</h3>
          <p>Windows 10/11 (64-bit) ${sizeMB ? '- ' + sizeMB : ''}</p>
        </div>
        <a href="${win.url}" class="btn btn--primary dl-main__btn">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
          Download ${version}
        </a>
      </div>
      <p class="dl-alt">
        Or install via PowerShell:
        <code>irm https://jinkaka98.github.io/install.ps1 | iex</code>
      </p>
    `
  } else {
    dl.innerHTML = '<p style="color:#6b6560;text-align:center;padding:40px;font-size:13px">Windows binary not available yet.</p>'
  }

  // Release info
  const info = document.getElementById('release-info')
  if (info) {
    info.textContent = `${version} - ${data.date || ''}`
    info.classList.add('visible')
  }

  // Changelog
  const cl = document.getElementById('changelog-content')
  cl.innerHTML = `
    <div style="margin-bottom:16px">
      <span class="changelog__tag">${version}</span>
      <span class="changelog__date">${data.date || ''}</span>
    </div>
    <div class="changelog__body">${escapeHtml(data.notes || 'No release notes.')}</div>
  `
}

function escapeHtml(str) {
  const div = document.createElement('div')
  div.textContent = str
  return div.innerHTML
}

// --- Copy Code ---
function copyCode(btn) {
  const code = btn.closest('.code-block').querySelector('code')
  navigator.clipboard.writeText(code.textContent).then(() => {
    const orig = btn.textContent
    btn.textContent = 'Copied!'
    btn.style.color = 'var(--c-green)'
    btn.style.borderColor = 'var(--c-green)'
    setTimeout(() => { btn.textContent = orig; btn.style.color = ''; btn.style.borderColor = '' }, 2000)
  })
}

// --- Nav ---
const nav = document.getElementById('nav')
window.addEventListener('scroll', () => {
  nav.style.borderBottomColor = window.scrollY > 100 ? 'rgba(255,140,0,0.25)' : ''
}, { passive: true })

document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    const t = document.querySelector(a.getAttribute('href'))
    if (t) { e.preventDefault(); t.scrollIntoView({ behavior: 'smooth' }) }
  })
})

// --- Init ---
loadRelease()
