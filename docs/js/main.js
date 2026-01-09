document.addEventListener('DOMContentLoaded', function() {
    const navToggle = document.querySelector('.nav-toggle');
    const sidebar = document.querySelector('.sidebar');
    const backToTop = document.querySelector('.back-to-top');
    const navLinks = document.querySelectorAll('.nav-link');
    
    navToggle.addEventListener('click', function() {
        sidebar.classList.toggle('active');
        const isExpanded = sidebar.classList.contains('active');
        navToggle.setAttribute('aria-expanded', isExpanded);
    });
    
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            const targetId = this.getAttribute('href');
            if (targetId.startsWith('#')) {
                e.preventDefault();
                const targetElement = document.querySelector(targetId);
                if (targetElement) {
                    const offsetTop = targetElement.offsetTop - 80;
                    window.scrollTo({
                        top: offsetTop,
                        behavior: 'smooth'
                    });
                    
                    navLinks.forEach(l => l.classList.remove('active'));
                    this.classList.add('active');
                    
                    if (window.innerWidth <= 768) {
                        sidebar.classList.remove('active');
                        navToggle.setAttribute('aria-expanded', 'false');
                    }
                }
            }
        });
    });
    
    window.addEventListener('scroll', function() {
        if (window.pageYOffset > 300) {
            backToTop.classList.add('visible');
        } else {
            backToTop.classList.remove('visible');
        }
        
        updateActiveNavLink();
    });
    
    backToTop.addEventListener('click', function() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
    
    function updateActiveNavLink() {
        const sections = document.querySelectorAll('.content-section');
        const scrollPosition = window.pageYOffset + 100;
        
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.offsetHeight;
            const sectionId = section.getAttribute('id');
            
            if (scrollPosition >= sectionTop && scrollPosition < sectionTop + sectionHeight) {
                navLinks.forEach(link => {
                    link.classList.remove('active');
                    if (link.getAttribute('href') === `#${sectionId}`) {
                        link.classList.add('active');
                    }
                });
            }
        });
    }
    
    document.querySelectorAll('.faq-item h3').forEach(faqHeader => {
        faqHeader.style.cursor = 'pointer';
        faqHeader.addEventListener('click', function() {
            const faqItem = this.closest('.faq-item');
            const content = faqItem.querySelectorAll('p, ul, ol, pre');
            
            content.forEach(element => {
                element.style.display = element.style.display === 'none' ? 'block' : 'none';
            });
            
            faqItem.classList.toggle('collapsed');
        });
    });
    
    const searchInput = document.createElement('input');
    searchInput.type = 'text';
    searchInput.placeholder = '搜索内容...';
    searchInput.style.cssText = `
        width: 100%;
        padding: 0.75rem;
        margin-bottom: 1rem;
        border: 1px solid #ddd;
        border-radius: 5px;
        font-size: 1rem;
    `;
    
    const sidebarNav = document.querySelector('.sidebar-nav');
    if (sidebarNav) {
        sidebarNav.insertBefore(searchInput, sidebarNav.firstChild);
        
        searchInput.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const sections = document.querySelectorAll('.content-section');
            
            sections.forEach(section => {
                const text = section.textContent.toLowerCase();
                if (text.includes(searchTerm) || searchTerm === '') {
                    section.style.display = 'block';
                } else {
                    section.style.display = 'none';
                }
            });
        });
    }
    
    const codeBlocks = document.querySelectorAll('pre code');
    codeBlocks.forEach(block => {
        const button = document.createElement('button');
        button.textContent = '复制';
        button.style.cssText = `
            position: absolute;
            top: 5px;
            right: 5px;
            padding: 0.25rem 0.5rem;
            background: #3498db;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 0.8rem;
        `;
        
        const pre = block.parentElement;
        pre.style.position = 'relative';
        pre.appendChild(button);
        
        button.addEventListener('click', function() {
            navigator.clipboard.writeText(block.textContent).then(() => {
                button.textContent = '已复制!';
                setTimeout(() => {
                    button.textContent = '复制';
                }, 2000);
            });
        });
    });
    
    const externalLinks = document.querySelectorAll('a[href^="http"]');
    externalLinks.forEach(link => {
        if (!link.hasAttribute('target')) {
            link.setAttribute('target', '_blank');
            link.setAttribute('rel', 'noopener noreferrer');
        }
    });
    
    if ('IntersectionObserver' in window) {
        const observerOptions = {
            root: null,
            rootMargin: '0px',
            threshold: 0.1
        };
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);
        
        const animatedElements = document.querySelectorAll('.feature-card, .task-card, .faq-item');
        animatedElements.forEach(element => {
            element.style.opacity = '0';
            element.style.transform = 'translateY(20px)';
            element.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            observer.observe(element);
        });
    }
    
    const keyboardShortcuts = {
        'Alt + S': () => {
            searchInput.focus();
        },
        'Alt + T': () => {
            backToTop.click();
        },
        'Escape': () => {
            if (sidebar.classList.contains('active')) {
                sidebar.classList.remove('active');
                navToggle.setAttribute('aria-expanded', 'false');
            }
        }
    };
    
    document.addEventListener('keydown', function(e) {
        const key = e.key;
        const altKey = e.altKey;
        
        if (altKey && key === 's') {
            e.preventDefault();
            keyboardShortcuts['Alt + S']();
        } else if (altKey && key === 't') {
            e.preventDefault();
            keyboardShortcuts['Alt + T']();
        } else if (key === 'Escape') {
            keyboardShortcuts['Escape']();
        }
    });
    
    const tableOfContents = document.createElement('div');
    tableOfContents.className = 'table-of-contents';
    tableOfContents.innerHTML = '<h4>本节目录</h4><ul></ul>';
    tableOfContents.style.cssText = `
        background: #f8f9fa;
        padding: 1rem;
        border-radius: 5px;
        margin-bottom: 1.5rem;
        border-left: 4px solid #3498db;
    `;
    
    const sections = document.querySelectorAll('.content-section');
    sections.forEach(section => {
        const sectionTOC = tableOfContents.cloneNode(true);
        const headings = section.querySelectorAll('h3, h4');
        
        if (headings.length > 0) {
            const tocList = sectionTOC.querySelector('ul');
            headings.forEach(heading => {
                const li = document.createElement('li');
                const a = document.createElement('a');
                a.href = `#${heading.id || heading.textContent.replace(/\s+/g, '-')}`;
                a.textContent = heading.textContent;
                a.style.cssText = `
                    color: #3498db;
                    text-decoration: none;
                    display: block;
                    padding: 0.25rem 0;
                    font-size: ${heading.tagName === 'H3' ? '1rem' : '0.9rem'};
                    margin-left: ${heading.tagName === 'H4' ? '1.5rem' : '0'};
                `;
                a.addEventListener('click', function(e) {
                    e.preventDefault();
                    heading.scrollIntoView({ behavior: 'smooth', block: 'start' });
                });
                li.appendChild(a);
                tocList.appendChild(li);
            });
            
            section.insertBefore(sectionTOC, section.firstChild);
        }
    });
    
    console.log('Hammerspoon 配置指南网站已加载完成！');
    console.log('快捷键提示：');
    console.log('- Alt + S: 聚焦搜索框');
    console.log('- Alt + T: 返回顶部');
    console.log('- Escape: 关闭移动端菜单');
});