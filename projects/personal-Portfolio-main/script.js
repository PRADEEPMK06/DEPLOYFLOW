/**
 * Portfolio Website - Main JavaScript
 * Author: Pradeep M K
 * Features: Theme toggle, smooth scrolling, scroll animations, mobile menu
 */

document.addEventListener('DOMContentLoaded', () => {
  // ============================================
  // Theme Toggle (Dark/Light Mode)
  // ============================================
  const themeToggle = document.getElementById('themeToggle');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');
  
  // Get stored theme or use system preference
  const getStoredTheme = () => localStorage.getItem('theme');
  const setStoredTheme = (theme) => localStorage.setItem('theme', theme);
  
  // Apply theme to document
  const applyTheme = (theme) => {
    document.documentElement.setAttribute('data-theme', theme);
  };
  
  // Initialize theme
  const initTheme = () => {
    const storedTheme = getStoredTheme();
    if (storedTheme) {
      applyTheme(storedTheme);
    } else if (prefersDark.matches) {
      applyTheme('dark');
    } else {
      applyTheme('light');
    }
  };
  
  // Toggle theme on button click
  if (themeToggle) {
    themeToggle.addEventListener('click', () => {
      const currentTheme = document.documentElement.getAttribute('data-theme');
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      applyTheme(newTheme);
      setStoredTheme(newTheme);
    });
  }
  
  // Listen for system theme changes
  prefersDark.addEventListener('change', (e) => {
    if (!getStoredTheme()) {
      applyTheme(e.matches ? 'dark' : 'light');
    }
  });
  
  // Initialize theme on load
  initTheme();

  // ============================================
  // Mobile Menu Toggle
  // ============================================
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  const navLinks = document.querySelector('.nav-links');
  
  if (mobileMenuBtn && navLinks) {
    mobileMenuBtn.addEventListener('click', () => {
      mobileMenuBtn.classList.toggle('active');
      navLinks.classList.toggle('active');
    });
    
    // Close menu when clicking on a link
    navLinks.querySelectorAll('.nav-link').forEach(link => {
      link.addEventListener('click', () => {
        mobileMenuBtn.classList.remove('active');
        navLinks.classList.remove('active');
      });
    });
    
    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
      if (!navLinks.contains(e.target) && !mobileMenuBtn.contains(e.target)) {
        mobileMenuBtn.classList.remove('active');
        navLinks.classList.remove('active');
      }
    });
  }

  // ============================================
  // Scroll Animations (Intersection Observer)
  // ============================================
  const animatedElements = document.querySelectorAll('.animate-on-scroll');
  
  const observerOptions = {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
  };
  
  const observerCallback = (entries, observer) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        // Optional: Unobserve after animation
        // observer.unobserve(entry.target);
      }
    });
  };
  
  const scrollObserver = new IntersectionObserver(observerCallback, observerOptions);
  
  animatedElements.forEach(element => {
    scrollObserver.observe(element);
  });

  // ============================================
  // Smooth Scroll for Anchor Links
  // ============================================
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      const href = this.getAttribute('href');
      
      // Skip if it's just "#" or empty
      if (href === '#' || href === '') return;
      
      const target = document.querySelector(href);
      
      if (target) {
        e.preventDefault();
        const headerHeight = document.querySelector('.header')?.offsetHeight || 72;
        const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - headerHeight;
        
        window.scrollTo({
          top: targetPosition,
          behavior: 'smooth'
        });
      }
    });
  });

  // ============================================
  // Header Scroll Effect
  // ============================================
  const header = document.querySelector('.header');
  let lastScrollY = window.scrollY;
  
  if (header) {
    window.addEventListener('scroll', () => {
      const currentScrollY = window.scrollY;
      
      // Add shadow when scrolled
      if (currentScrollY > 10) {
        header.style.boxShadow = '0 2px 20px var(--color-shadow)';
      } else {
        header.style.boxShadow = 'none';
      }
      
      lastScrollY = currentScrollY;
    });
  }

  // ============================================
  // Active Navigation Link
  // ============================================
  const sections = document.querySelectorAll('section[id]');
  
  const highlightNavLink = () => {
    const scrollY = window.scrollY;
    
    sections.forEach(section => {
      const sectionHeight = section.offsetHeight;
      const sectionTop = section.offsetTop - 100;
      const sectionId = section.getAttribute('id');
      const navLink = document.querySelector(`.nav-link[href="#${sectionId}"]`);
      
      if (navLink) {
        if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
          navLink.classList.add('active');
        } else {
          navLink.classList.remove('active');
        }
      }
    });
  };
  
  window.addEventListener('scroll', highlightNavLink);

  // ============================================
  // Form Handling (for contact page) - Web3Forms
  // ============================================
  const contactForm = document.getElementById('contactForm');
  
  if (contactForm) {
    contactForm.addEventListener('submit', async function(e) {
      e.preventDefault();
      
      const submitBtn = document.getElementById('submitBtn');
      const formStatus = document.getElementById('formStatus');
      const originalText = submitBtn.textContent;
      
      // Show loading state
      submitBtn.textContent = 'Sending...';
      submitBtn.disabled = true;
      formStatus.textContent = '';
      formStatus.className = 'form-status';
      
      try {
        const formData = new FormData(this);
        const response = await fetch('https://api.web3forms.com/submit', {
          method: 'POST',
          body: formData
        });
        
        const result = await response.json();
        
        if (result.success) {
          // Success
          submitBtn.textContent = '✓ Message Sent!';
          submitBtn.style.backgroundColor = '#22c55e';
          formStatus.textContent = 'Thank you! Your message has been sent successfully.';
          formStatus.className = 'form-status success';
          this.reset();
          
          // Reset button after 3 seconds
          setTimeout(() => {
            submitBtn.textContent = originalText;
            submitBtn.style.backgroundColor = '';
            submitBtn.disabled = false;
          }, 3000);
        } else {
          throw new Error(result.message || 'Something went wrong');
        }
      } catch (error) {
        // Error
        submitBtn.textContent = 'Failed to Send';
        submitBtn.style.backgroundColor = '#ef4444';
        formStatus.textContent = 'Oops! Something went wrong. Please try again or email directly.';
        formStatus.className = 'form-status error';
        
        setTimeout(() => {
          submitBtn.textContent = originalText;
          submitBtn.style.backgroundColor = '';
          submitBtn.disabled = false;
        }, 3000);
      }
    });
  }

  // ============================================
  // Typing Effect for Hero (Optional Enhancement)
  // ============================================
  const createTypingEffect = (element, texts, speed = 100, pause = 2000) => {
    if (!element) return;
    
    let textIndex = 0;
    let charIndex = 0;
    let isDeleting = false;
    
    const type = () => {
      const currentText = texts[textIndex];
      
      if (isDeleting) {
        element.textContent = currentText.substring(0, charIndex - 1);
        charIndex--;
      } else {
        element.textContent = currentText.substring(0, charIndex + 1);
        charIndex++;
      }
      
      let timeout = isDeleting ? speed / 2 : speed;
      
      if (!isDeleting && charIndex === currentText.length) {
        timeout = pause;
        isDeleting = true;
      } else if (isDeleting && charIndex === 0) {
        isDeleting = false;
        textIndex = (textIndex + 1) % texts.length;
      }
      
      setTimeout(type, timeout);
    };
    
    type();
  };
  
  // Uncomment to enable typing effect on hero title
  // const heroTitle = document.querySelector('.hero-title');
  // if (heroTitle) {
  //   createTypingEffect(heroTitle, [
  //     'Web Developer & IT Engineering Student',
  //     'React & Node.js Specialist',
  //     'Building Impactful Applications'
  //   ]);
  // }

  // ============================================
  // Parallax Effect on Hero (Subtle)
  // ============================================
  const hero = document.querySelector('.hero');
  
  if (hero) {
    window.addEventListener('scroll', () => {
      const scrollY = window.scrollY;
      if (scrollY < window.innerHeight) {
        hero.style.transform = `translateY(${scrollY * 0.3}px)`;
        hero.style.opacity = 1 - (scrollY * 0.001);
      }
    });
  }

  // ============================================
  // Lazy Loading Images
  // ============================================
  const lazyImages = document.querySelectorAll('img[data-src]');
  
  if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          img.src = img.dataset.src;
          img.removeAttribute('data-src');
          observer.unobserve(img);
        }
      });
    });
    
    lazyImages.forEach(img => imageObserver.observe(img));
  }

  // Console message
  console.log('%c🚀 Portfolio loaded successfully!', 'color: #2563eb; font-size: 14px; font-weight: bold;');
  console.log('%cBuilt by Pradeep M K', 'color: #666; font-size: 12px;');
});
