/* ═══════════════════════════════════════════
   XIXERO — Landing Page Logic
   Downloads from jinkaka98.github.io/releases/
   (repo xixero is private, binaries hosted here)
   ═══════════════════════════════════════════ */

const RELEASES_BASE = '/releases'
const LATEST_JSON = `${RELEASES_BASE}/latest.json`

// ─── Scroll Reveal ───
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible')
      observer.unobserve(entry.target)
    }
  })
}, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' })

document.querySelectorAll('.reveal').forEach(el => observer.observe(el))

// ─── Load Release Info ───
async function loadRelease() {
  try {
    const resp = await fetch(LATEST_JSON)
    if (!resp.ok) throw new Error('No release')
    const data = await resp.json()
    renderRelease(data)
  } catch {
    document.getElementById('version-badge').textContent = 'COMING SOON'
    document.getElementById('download-grid').innerHTML = renderNoRelease()
    document.getElementById('changelog-content').innerHTML =
      '<p class="changelog__loading">No releases published yet. Check back soon.</p>'
  }
}

function renderRelease(release) {
  const version = `v${release.version}`

  // Version badge
  document.getElementById('version-badge').textContent = `${version} AVAILABLE`

  // Download cards
  const platforms = [
    { os: 'Windows', arch: 'x64', key: 'windows-amd64' },
    { os: 'Linux', arch: 'x64', key: 'linux-amd64' },
    { os: 'macOS', arch: 'Intel', key: 'darwin-amd64' },
    { os: 'macOS', arch: 'Apple Silicon', key: 'darwin-arm64' },
  ]

  const grid = document.getElementById('download-grid')
  grid.innerHTML = platforms.map(p => {
    const bin = release.binaries?.[p.key]
    const url = bin?.url
    const size = bin?.size ? `${(bin.size / 1024 / 1024).toFixed(1)}MB` : ''
    return `
      <div class="dl-card reveal visible">
        <div class="dl-card__os">${p.os}</div>
        <div class="dl-card__arch">${p.arch}${size ? ` · ${size}` : ''}</div>
        ${url
          ? `<a href="${url}" class="dl-card__btn">DOWNLOAD</a>`
          : `<span class="dl-card__btn dl-card__btn--disabled">N/A</span>`
        }
      </div>
    `
  }).join('')

  // Release info
  const info = document.getElementById('release-info')
  info.textContent = `Latest: ${version} · ${release.date || ''}`
  info.classList.add('visible')

  // Changelog
  const cl = document.getElementById('changelog-content')
  cl.innerHTML = `
    <div>
      <span class="changelog__tag">${version}</span>
      <span class="changelog__date">${release.date || ''}</span>
    </div>
    <div class="changelog__body">${release.notes ? escapeHtml(release.notes) : 'Initial release.'}</div>
  `
}

function renderNoRelease() {
  return ['Windows', 'Linux', 'macOS Intel', 'macOS ARM'].map(os => `
    <div class="dl-card reveal visible">
      <div class="dl-card__os">${os.split(' ')[0]}</div>
      <div class="dl-card__arch">${os.includes(' ') ? os.split(' ')[1] : 'x64'}</div>
      <span class="dl-card__btn dl-card__btn--disabled">COMING SOON</span>
    </div>
  `).join('')
}

function escapeHtml(str) {
  const div = document.createElement('div')
  div.textContent = str
  return div.innerHTML
}

// ─── Copy Code ───
function copyCode(btn) {
  const code = btn.closest('.code-block').querySelector('code')
  navigator.clipboard.writeText(code.textContent).then(() => {
    const orig = btn.textContent
    btn.textContent = 'Copied!'
    btn.style.color = 'var(--c-green)'
    btn.style.borderColor = 'var(--c-green)'
    setTimeout(() => {
      btn.textContent = orig
      btn.style.color = ''
      btn.style.borderColor = ''
    }, 2000)
  })
}

// ─── Nav scroll effect ───
const nav = document.getElementById('nav')
window.addEventListener('scroll', () => {
  nav.style.borderBottomColor = window.scrollY > 100
    ? 'rgba(255, 140, 0, 0.25)' : ''
}, { passive: true })

// ─── Smooth anchor scroll ───
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    const target = document.querySelector(a.getAttribute('href'))
    if (target) {
      e.preventDefault()
      target.scrollIntoView({ behavior: 'smooth' })
    }
  })
})

// ─── Init ───
loadRelease()
