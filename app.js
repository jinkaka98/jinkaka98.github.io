// DOM Elements
const versionBadge = document.getElementById('version-badge');
const downloadBtn = document.getElementById('download-btn');
const downloadInfo = document.getElementById('download-info');
const changelogContent = document.getElementById('changelog-content');
const copyBtn = document.getElementById('copy-btn');
const installCommand = document.getElementById('install-command');
const navToggle = document.getElementById('nav-toggle');
const navMenu = document.getElementById('nav-menu');

// State
let releaseData = null;

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    loadReleaseData();
    setupScrollReveal();
    setupNavigation();
    setupCopyButton();
    setupSmoothScroll();
});

// Load release data from JSON
async function loadReleaseData() {
    try {
        const response = await fetch('releases/latest.json');
        releaseData = await response.json();
        
        updateVersionInfo();
        updateDownloadButton();
        updateChangelog();
    } catch (error) {
        console.error('Failed to load release data:', error);
        // Fallback to default values
        updateVersionInfo('v0.1.0');
        updateDownloadButton('v0.1.0', '5.0 MB');
        updateChangelog({
            version: '0.1.0',
            date: '2025-07-15',
            notes: 'Initial release\n\n- AI reverse proxy engine\n- OpenAI, Anthropic, OpenRouter support\n- MITM proxy for Trae.ai\n- Model remapping\n- SSE streaming support\n- License validation'
        });
    }
}

// Update version badge
function updateVersionInfo(version = null) {
    const versionText = version || (releaseData ? `v${releaseData.version}` : 'v0.1.0');
    if (versionBadge) {
        versionBadge.textContent = versionText;
    }
}

// Update download button
function updateDownloadButton(version = null, size = null) {
    if (!downloadBtn || !downloadInfo) return;
    
    const versionText = version || (releaseData ? `v${releaseData.version}` : 'v0.1.0');
    const sizeText = size || (releaseData ? formatFileSize(releaseData.installer.size) : '5.0 MB');
    
    downloadInfo.textContent = `${versionText} • ${sizeText}`;
    
    if (releaseData && releaseData.installer.url) {
        downloadBtn.href = releaseData.installer.url;
    }
}

// Update changelog
function updateChangelog(fallbackData = null) {
    if (!changelogContent) return;
    
    const data = releaseData || fallbackData;
    if (!data) return;
    
    const changelogItem = document.createElement('div');
    changelogItem.className = 'changelog-item';
    
    changelogItem.innerHTML = `
        <div class="changelog-header">
            <span class="changelog-version">v${data.version}</span>
            <span class="changelog-date">${formatDate(data.date)}</span>
        </div>
        <div class="changelog-notes">${data.notes}</div>
    `;
    
    changelogContent.appendChild(changelogItem);
}

// Format file size
function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
}

// Format date
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

// Scroll reveal animation
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

// Navigation functionality
function setupNavigation() {
    if (!navToggle || !navMenu) return;
    
    navToggle.addEventListener('click', () => {
        navToggle.classList.toggle('active');
        navMenu.classList.toggle('active');
    });
    
    // Close menu when clicking on links
    const navLinks = navMenu.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            navToggle.classList.remove('active');
            navMenu.classList.remove('active');
        });
    });
    
    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!navToggle.contains(e.target) && !navMenu.contains(e.target)) {
            navToggle.classList.remove('active');
            navMenu.classList.remove('active');
        }
    });
    
    // Navbar scroll effect
    let lastScrollY = window.scrollY;
    const navbar = document.getElementById('navbar');
    
    window.addEventListener('scroll', () => {
        const currentScrollY = window.scrollY;
        
        if (navbar) {
            if (currentScrollY > lastScrollY && currentScrollY > 100) {
                navbar.style.transform = 'translateY(-100%)';
            } else {
                navbar.style.transform = 'translateY(0)';
            }
        }
        
        lastScrollY = currentScrollY;
    });
}

// Copy button functionality
function setupCopyButton() {
    if (!copyBtn || !installCommand) return;
    
    copyBtn.addEventListener('click', async () => {
        try {
            await navigator.clipboard.writeText(installCommand.textContent);
            
            // Visual feedback
            const originalHTML = copyBtn.innerHTML;
            copyBtn.innerHTML = `
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <polyline points="20,6 9,17 4,12"/>
                </svg>
            `;
            
            setTimeout(() => {
                copyBtn.innerHTML = originalHTML;
            }, 2000);
            
        } catch (error) {
            console.error('Failed to copy text:', error);
            
            // Fallback for older browsers
            const textArea = document.createElement('textarea');
            textArea.value = installCommand.textContent;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
        }
    });
}

// Smooth scroll for anchor links
function setupSmoothScroll() {
    const anchorLinks = document.querySelectorAll('a[href^="#"]');
    
    anchorLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            
            const targetId = link.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                const offsetTop = targetElement.offsetTop - 100; // Account for fixed navbar
                
                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });
            }
        });
    });
}

// Utility functions
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Performance optimizations
const debouncedResize = debounce(() => {
    // Handle resize events if needed
}, 250);

window.addEventListener('resize', debouncedResize);

// Preload critical resources
function preloadResources() {
    const criticalResources = [
        'releases/latest.json'
    ];
    
    criticalResources.forEach(resource => {
        const link = document.createElement('link');
        link.rel = 'preload';
        link.href = resource;
        link.as = 'fetch';
        link.crossOrigin = 'anonymous';
        document.head.appendChild(link);
    });
}

// Initialize preloading
preloadResources();

// Error handling
window.addEventListener('error', (e) => {
    console.error('JavaScript error:', e.error);
});

window.addEventListener('unhandledrejection', (e) => {
    console.error('Unhandled promise rejection:', e.reason);
});

// Analytics placeholder (if needed in the future)
function trackEvent(eventName, properties = {}) {
    // Placeholder for analytics tracking
    console.log('Event:', eventName, properties);
}

// Export functions for potential external use
window.XixeroApp = {
    loadReleaseData,
    trackEvent,
    formatFileSize,
    formatDate
};