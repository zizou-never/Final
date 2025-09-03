#!/usr/bin/env bash
set -euo pipefail

echo "==> Fixing Tailwind/Next CSS setup..."

# 0) Helpers
backup() {
  local f="$1"
  if [ -f "$f" ]; then
    cp -a "$f" "$f.bak.$(date +%s)"
    echo "   Backed up $f -> $f.bak.*"
  fi
}

mkdir -p src/app

# 1) Ensure PostCSS config (CommonJS)
if [ -f "postcss.config.mjs" ]; then
  echo "   Converting postcss.config.mjs to postcss.config.js"
  backup postcss.config.mjs
  rm -f postcss.config.js
  mv postcss.config.mjs postcss.config.js
fi

cat > postcss.config.js <<'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOF
echo "   Wrote postcss.config.js"

# 2) Tailwind config (covers ./src/**/* and keeps your theme)
backup tailwind.config.js
cat > tailwind.config.js <<'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
        secondary: {
          50: '#f5f3ff',
          100: '#ede9fe',
          200: '#ddd6fe',
          300: '#c4b5fd',
          400: '#a78bfa',
          500: '#8b5cf6',
          600: '#7c3aed',
          700: '#6d28d9',
          800: '#5b21b6',
          900: '#4c1d95',
        },
        accent: {
          50: '#fdf2f8',
          100: '#fce7f3',
          200: '#fbcfe8',
          300: '#f9a8d4',
          400: '#f472b6',
          500: '#ec4899',
          600: '#db2777',
          700: '#be185d',
          800: '#9d174d',
          900: '#831843',
        },
        dark: {
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          300: '#cbd5e1',
          400: '#94a3b8',
          500: '#64748b',
          600: '#475569',
          700: '#334155',
          800: '#1e293b',
          900: '#0f172a',
        },
        ring: '#0ea5e9',
        background: '#ffffff',
        foreground: '#171717',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
      boxShadow: {
        soft: '0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06)',
        medium: '0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05)',
        hard: '0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04)',
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'bounce-subtle': 'bounceSubtle 0.6s ease-in-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        bounceSubtle: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-5px)' },
        },
      },
    },
  },
  plugins: [],
};
EOF
echo "   Wrote tailwind.config.js"

# 3) globals.css (remove @reference and ensure Tailwind directives exist)
#    Overwrite with your intended content (without @reference).
backup src/app/globals.css
cat > src/app/globals.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');

@layer base {
  body {
    @apply bg-white text-gray-900;
    font-feature-settings: "rlig" 1, "calt" 1;
  }
}

@layer components {
  .btn {
    @apply inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none ring-offset-background;
  }
  .btn-primary { @apply btn bg-primary-600 hover:bg-primary-700 text-white; }
  .btn-secondary { @apply btn bg-secondary-600 hover:bg-secondary-700 text-white; }
  .btn-outline { @apply btn border border-gray-300 bg-transparent hover:bg-gray-50 text-gray-700; }
  .btn-ghost { @apply btn hover:bg-gray-100 text-gray-700; }
  .btn-sm { @apply btn h-8 px-3 text-xs; }
  .btn-md { @apply btn h-9 px-4 py-2; }
  .btn-lg { @apply btn h-10 px-6; }

  .input {
    @apply flex h-9 w-full rounded-md border border-gray-300 bg-transparent px-3 py-1 text-sm shadow-sm transition-colors file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50;
  }

  .card { @apply rounded-lg border border-gray-200 bg-white shadow-sm; }
  .card-header { @apply flex flex-col space-y-1.5 p-6; }
  .card-title { @apply text-lg font-semibold leading-none tracking-tight; }
  .card-description { @apply text-sm text-gray-500; }
  .card-content { @apply p-6 pt-0; }
  .card-footer { @apply flex items-center p-6 pt-0; }

  .badge { @apply inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium; }
  .badge-primary { @apply badge bg-primary-100 text-primary-800; }
  .badge-secondary { @apply badge bg-secondary-100 text-secondary-800; }
  .badge-accent { @apply badge bg-accent-100 text-accent-800; }
  .badge-outline { @apply badge border border-gray-200 bg-white text-gray-700; }

  .avatar { @apply relative flex h-8 w-8 shrink-0 overflow-hidden rounded-full; }
  .avatar-sm { @apply avatar h-6 w-6; }
  .avatar-md { @apply avatar h-8 w-8; }
  .avatar-lg { @apply avatar h-10 w-10; }
  .avatar-xl { @apply avatar h-12 w-12; }
}

@layer utilities {
  .text-balance { text-wrap: balance; }
}
EOF
echo "   Wrote src/app/globals.css"

# 4) Ensure deps
echo "==> Ensuring dependencies (tailwindcss, postcss, autoprefixer)..."
npm i -D tailwindcss postcss autoprefixer >/dev/null 2>&1 || true

# 5) Clean Next build cache
rm -rf .next

echo "==> Done!"
echo "Run: npm run dev"
echo "Tip: أضف مؤقتاً <div className=\"bg-red-500 text-white p-3\">Tailwind OK</div> للتاكد."