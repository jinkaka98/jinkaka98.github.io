// DOM Elements
const versionBadge = document.getElementById('version-badge');
const downloadBtnMsi = document.getElementById('download-btn-msi');
const downloadInfoMsi = document.getElementById('download-info-msi');
const downloadBtnExe = document.getElementById('download-btn-exe');
const downloadInfoExe = document.getElementById('download-info-exe');
const changelogContent = document.getElementById('changelog-content');
const copyBtn = document.getElementById('copy-btn');
const installCommand = document.getElementById('install-command');
const navToggle = document.getElementById('nav-toggle');
const navMenu = document.getElementById('nav-menu');
const navbar = document.getElementById('navbar');

// State
let releaseData = null;

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    loadReleaseData();
    setupScrollReveal();
    setupNavigation();
    setupCopyButton();
    setupSmoothScroll();
    setupScrollEffects();
});

// Load release data from JSON
async function loadReleaseData() {
    try {
        const response = await fetch('releases/latest.json');
        releaseData = await response.json();
        
        updateVersionInfo();
        updateDownloadButtons();
        updateChangelog();
    } catch (error) {
        console.error('Failed to load release data:', error);
        // Fallback to default values
        updateVersionInfo('v0.1.2');
        updateDownloadButtons();
        updateChangelog({
            version: '0.1.2',
            published_at: '2026-04-28T12:15:46.767Z',
            release_notes: '*add TRAE IDE Connection on version 3.5.53'
        });
    }
}

// Update version badge
function updateVersionInfo(version = null) {
    const versionText = version || (releaseData ? `v${releaseData.version}` : 'v0.1.2');
    if (versionBadge) {
        versionBadge.textContent = versionText;
    }
}

// Update download buttons with dynamic data
function updateDownloadButtons() {
    if (!releaseData) {
        // Fallback values
        if (downloadInfoMsi) {
            downloadInfoMsi.textContent = 'v0.1.2 • 7.2 MB • Recommended';
        }
        if (downloadInfoExe) {
            downloadInfoExe.textContent = 'v0.1.2 • 5.0 MB • NSIS Setup';
        }
        return;
    }

    // Support both old and new JSON formats
    const msiInfo = releaseData.downloads?.msi || releaseData.installer;
    const exeInfo = releaseData.downloads?.exe || releaseData.installer;

    if (downloadInfoMsi && msiInfo) {
        const msiSize = msiInfo.size_human || '7.2 MB';
        downloadInfoMsi.textContent = `v${releaseData.version} • ${msiSize} • Recommended`;
    }

    if (downloadInfoExe && exeInfo) {
        const exeSize = exeInfo.size_human || '5.0 MB';
        downloadInfoExe.textContent = `v${releaseData.version} • ${exeSize} • NSIS Setup`;
    }

    // Update download URLs if available
    if (downloadBtnMsi && msiInfo?.url) {
        downloadBtnMsi.href = msiInfo.url;
    }

    if (downloadBtnExe && exeInfo?.url) {
        downloadBtnExe.href = exeInfo.url;
    }
}

// Update changelog section
function updateChangelog(fallbackData = null) {
    if (!changelogContent) return;

    const data = releaseData || fallbackData;
    if (!data) return;

    const publishedDate = data.published_at ? 
        new Date(data.published_at).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        }) : 'Recent';

    const changelogHTML = `
        <div class="changelog-item">
            <div class="changelog-header">
                <div class="changelog-version">v${data.version}</div>
                <div class="changelog-date">${publishedDate}</div>
            </div>
            <div class="changelog-notes">${data.release_notes || 'Latest updates and improvements'}</div>
        </div>
    `;

    changelogContent.innerHTML = changelogHTML;
}

// Setup scroll reveal animations
function setupScrollReveal() {
    const revealElements = document.querySelectorAll('[data-reveal]');
    
    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('revealed');
                revealObserver.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    });

    revealElements.forEach(element => {
        revealObserver.observe(element);
    });
}

// Setup navigation functionality
function setupNavigation() {
    if (!navToggle || !navMenu) return;

    navToggle.addEventListener('click', () => {
        const isActive = navToggle.classList.contains('active');
        
        navToggle.classList.toggle('active');
        navMenu.classList.toggle('active');
        navToggle.setAttribute('aria-expanded', !isActive);
        
        // Prevent body scroll when menu is open
        document.body.style.overflow = isActive ? '' : 'hidden';
    });

    // Close menu when clicking nav links
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            navToggle.classList.remove('active');
            navMenu.classList.remove('active');
            navToggle.setAttribute('aria-expanded', 'false');
            document.body.style.overflow = '';
        });
    });

    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!navToggle.contains(e.target) && !navMenu.contains(e.target)) {
            navToggle.classList.remove('active');
            navMenu.classList.remove('active');
            navToggle.setAttribute('aria-expanded', 'false');
            document.body.style.overflow = '';
        }
    });
}

// Setup copy button functionality
function setupCopyButton() {
    if (!copyBtn || !installCommand) return;

    copyBtn.addEventListener('click', async () => {
        try {
            await navigator.clipboard.writeText(installCommand.textContent);
            
            // Visual feedback
            copyBtn.classList.add('copied');
            const originalHTML = copyBtn.innerHTML;
            copyBtn.innerHTML = `
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                    <polyline points="20,6 9,17 4,12"/>
                </svg>
            `;
            
            setTimeout(() => {
                copyBtn.classList.remove('copied');
                copyBtn.innerHTML = originalHTML;
            }, 2000);
        } catch (err) {
            console.error('Failed to copy text: ', err);
            
            // Fallback for older browsers
            const textArea = document.createElement('textarea');
            textArea.value = installCommand.textContent;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
            
            // Visual feedback
            copyBtn.classList.add('copied');
            setTimeout(() => {
                copyBtn.classList.remove('copied');
            }, 2000);
        }
    });
}

// Setup smooth scroll for anchor links
function setupSmoothScroll() {
    const anchorLinks = document.querySelectorAll('a[href^="#"]');
    
    anchorLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            const href = link.getAttribute('href');
            if (href === '#') return;
            
            const target = document.querySelector(href);
            if (target) {
                e.preventDefault();
                
                const offsetTop = target.offsetTop - 80; // Account for fixed navbar
                
                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });
            }
        });
    });
}

// Setup scroll effects (navbar background)
function setupScrollEffects() {
    if (!navbar) return;

    let ticking = false;

    function updateNavbar() {
        const scrolled = window.scrollY > 50;
        navbar.classList.toggle('scrolled', scrolled);
        ticking = false;
    }

    function requestTick() {
        if (!ticking) {
            requestAnimationFrame(updateNavbar);
            ticking = true;
        }
    }

    window.addEventListener('scroll', requestTick);
}

// Keyboard navigation improvements
document.addEventListener('keydown', (e) => {
    // Escape key closes mobile menu
    if (e.key === 'Escape' && navMenu && navMenu.classList.contains('active')) {
        navToggle.classList.remove('active');
        navMenu.classList.remove('active');
        navToggle.setAttribute('aria-expanded', 'false');
        document.body.style.overflow = '';
        navToggle.focus();
    }
});

// Handle window resize
window.addEventListener('resize', () => {
    // Close mobile menu on resize to desktop
    if (window.innerWidth > 768 && navMenu && navMenu.classList.contains('active')) {
        navToggle.classList.remove('active');
        navMenu.classList.remove('active');
        navToggle.setAttribute('aria-expanded', 'false');
        document.body.style.overflow = '';
    }
});

// Preload critical resources
function preloadResources() {
    // Preload the releases JSON
    const link = document.createElement('link');
    link.rel = 'prefetch';
    link.href = 'releases/latest.json';
    document.head.appendChild(link);
}

// Initialize preloading
preloadResources();

// Performance monitoring (optional)
if ('performance' in window) {
    window.addEventListener('load', () => {
        const loadTime = performance.now();
        console.log(`Page loaded in ${Math.round(loadTime)}ms`);
    });
}

// Service worker registration (for future PWA features)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        // Uncomment when service worker is implemented
        // navigator.serviceWorker.register('/sw.js');
    });
}