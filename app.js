/* ═══════════════════════════════════════════
   XIXERO — Landing Page Logic
   ═══════════════════════════════════════════ */

const GITHUB_REPO = 'jinkaka98/xixero'
const GITHUB_API = `https://api.github.com/repos/${GITHUB_REPO}/releases/latest`

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

// ─── Fetch GitHub Release ───
async function loadRelease() {
  try {
    const resp = await fetch(GITHUB_API)
    if (!resp.ok) throw new Error('No release')
    const data = await resp.json()
    renderRelease(data)
  } catch {
    document.getElementById('version-badge').textContent = 'PRE-RELEASE'
    document.getElementById('download-grid').innerHTML = renderNoRelease()
    document.getElementById('changelog-content').innerHTML =
      '<p class="changelog__loading">No releases published yet.</p>'
  }
}

function renderRelease(release) {
  const version = release.tag_name || 'latest'

  // Version badge
  document.getElementById('version-badge').textContent = `${version} AVAILABLE`

  // Download cards
  const platforms = [
    { os: 'Windows', arch: 'x64', pattern: /windows.*amd64|xixero.*\.exe/i },
    { os: 'Linux', arch: 'x64', pattern: /linux.*amd64/i },
    { os: 'macOS', arch: 'Intel', pattern: /darwin.*amd64/i },
    { os: 'macOS', arch: 'Apple Silicon', pattern: /darwin.*arm64/i },
  ]

  const grid = document.getElementById('download-grid')
  grid.innerHTML = platforms.map(p => {
    const asset = (release.assets || []).find(a => p.pattern.test(a.name))
    const url = asset?.browser_download_url
    return `
      <div class="dl-card reveal visible">
        <div class="dl-card__os">${p.os}</div>
        <div class="dl-card__arch">${p.arch}</div>
        ${url
          ? `<a href="${url}" class="dl-card__btn">DOWNLOAD</a>`
          : `<span class="dl-card__btn dl-card__btn--disabled">N/A</span>`
        }
      </div>
    `
  }).join('')

  // Release info
  const info = document.getElementById('release-info')
  info.textContent = `Latest: ${version} · ${new Date(release.published_at).toLocaleDateString()}`
  info.classList.add('visible')

  // Changelog
  const cl = document.getElementById('changelog-content')
  cl.innerHTML = `
    <div>
      <span class="changelog__tag">${version}</span>
      <span class="changelog__date">${new Date(release.published_at).toLocaleDateString()}</span>
    </div>
    <div class="changelog__body">${escapeHtml(release.body || 'No release notes.')}</div>
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
let lastScroll = 0
const nav = document.getElementById('nav')
window.addEventListener('scroll', () => {
  const y = window.scrollY
  if (y > 100) {
    nav.style.borderBottomColor = 'rgba(255, 140, 0, 0.25)'
  } else {
    nav.style.borderBottomColor = ''
  }
  lastScroll = y
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
