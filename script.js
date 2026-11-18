const toggle = document.querySelector('.nav-toggle');
const links = document.querySelector('.nav-links');

toggle.addEventListener('click', () => {
  const open = links.classList.toggle('open');
  toggle.setAttribute('aria-expanded', String(open));
});

links.querySelectorAll('a').forEach((link) => {
  link.addEventListener('click', () => {
    links.classList.remove('open');
    toggle.setAttribute('aria-expanded', 'false');
    links.querySelectorAll('a').forEach((a) => a.classList.remove('active'));
    link.classList.add('active');
  });
});

const revealGroups = [
  { selector: '.hero-content > *', step: 120 },
  { selector: '.entry-points .light-title, .entry-points .light-lead', step: 130 },
  { selector: '.tree-root', step: 0 },
  { selector: '.tree-card', step: 110 },
  { selector: '.entry-points .mono-note', step: 0 },
  { selector: '.two-up .section-heading h2, .two-up .lead-muted', step: 130 },
  { selector: '.app-card', step: 170 },
  { selector: '.connector-arrow', step: 0 },
  { selector: '.two-up .mono-note', step: 0 },
  { selector: '.goal-title, .goal-lead', step: 130 },
  { selector: '.goal-phone', step: 0 },
  { selector: '.goal-card', step: 100 },
  { selector: '.cta-copy > *', step: 120 },
  { selector: '.cta-bottom', step: 0 }
];

const revealTargets = [];
revealGroups.forEach(({ selector, step }) => {
  document.querySelectorAll(selector).forEach((el, index) => {
    el.style.setProperty('--d', `${index * step}ms`);
    revealTargets.push(el);
  });
});

const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

if (revealTargets.length && 'IntersectionObserver' in window && !prefersReduced) {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });

  revealTargets.forEach((el) => observer.observe(el));
} else {
  revealTargets.forEach((el) => el.classList.add('is-visible'));
}

const tree = document.querySelector('.tree');
if (tree && 'IntersectionObserver' in window && !prefersReduced) {
  const treeObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('branches-in');
        treeObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.25 });
  treeObserver.observe(tree);
} else if (tree) {
  tree.classList.add('branches-in');
}

const sphere = document.getElementById('particle-sphere');
if (sphere && !prefersReduced) {
  const ctx = sphere.getContext('2d');
  const section = sphere.closest('.cta-section');
  const count = 260;
  const points = [];
  const edges = [];
  let width = 0;
  let height = 0;
  let radius = 0;
  let rotX = 0;
  let rotY = 0;
  let targetX = 0;
  let targetY = 0;

  for (let i = 0; i < count; i += 1) {
    const y = 1 - (i / (count - 1)) * 2;
    const ring = Math.sqrt(1 - y * y);
    const theta = Math.PI * (3 - Math.sqrt(5)) * i;
    points.push({
      x: Math.cos(theta) * ring,
      y,
      z: Math.sin(theta) * ring,
      size: i % 9 === 0 ? 2 : 1.2,
      px: 0,
      py: 0,
      depth: 0
    });
  }

  for (let i = 0; i < count; i += 1) {
    for (let j = i + 1; j < count; j += 1) {
      const dx = points[i].x - points[j].x;
      const dy = points[i].y - points[j].y;
      const dz = points[i].z - points[j].z;
      if (dx * dx + dy * dy + dz * dz < 0.09) edges.push([i, j]);
    }
  }

  function resizeSphere() {
    const rect = sphere.getBoundingClientRect();
    const ratio = Math.min(window.devicePixelRatio || 1, 2);
    width = rect.width;
    height = rect.height;
    sphere.width = Math.round(width * ratio);
    sphere.height = Math.round(height * ratio);
    ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
    radius = Math.min(width, height) * 0.43;
  }

  resizeSphere();
  window.addEventListener('resize', resizeSphere);

  section.addEventListener('mousemove', (event) => {
    const rect = section.getBoundingClientRect();
    targetY = ((event.clientX - rect.left) / rect.width - 0.5) * 0.9;
    targetX = ((event.clientY - rect.top) / rect.height - 0.5) * -0.5;
  });
  section.addEventListener('mouseleave', () => {
    targetX = 0;
    targetY = 0;
  });

  function drawSphere() {
    ctx.clearRect(0, 0, width, height);
    rotY += 0.0024 + (targetY - rotY) * 0.035;
    rotX += (targetX - rotX) * 0.035;
    const cosY = Math.cos(rotY);
    const sinY = Math.sin(rotY);
    const cosX = Math.cos(rotX);
    const sinX = Math.sin(rotX);
    const cx = width / 2;
    const cy = height / 2;

    points.forEach((point) => {
      const x1 = point.x * cosY - point.z * sinY;
      const z1 = point.x * sinY + point.z * cosY;
      const y2 = point.y * cosX - z1 * sinX;
      const z2 = point.y * sinX + z1 * cosX;
      point.depth = (z2 + 1) / 2;
      point.px = cx + x1 * radius;
      point.py = cy + y2 * radius;
    });

    edges.forEach(([a, b]) => {
      const first = points[a];
      const second = points[b];
      const depth = (first.depth + second.depth) / 2;
      ctx.beginPath();
      ctx.moveTo(first.px, first.py);
      ctx.lineTo(second.px, second.py);
      ctx.strokeStyle = `rgba(216, 223, 214, ${0.1 + depth * 0.34})`;
      ctx.lineWidth = 0.7;
      ctx.stroke();
    });

    points.forEach((point) => {
      const alpha = 0.22 + point.depth * 0.68;
      ctx.beginPath();
      ctx.arc(point.px, point.py, point.size * (0.65 + point.depth * 0.6), 0, Math.PI * 2);
      ctx.fillStyle = `rgba(232, 237, 229, ${alpha})`;
      ctx.fill();
    });

    requestAnimationFrame(drawSphere);
  }

  drawSphere();
}
