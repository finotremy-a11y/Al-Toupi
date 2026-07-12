/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './app/views/**/*.{erb,haml}',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        // Design System Al Toupi - Palette Bleu / Marron (test client)
        'al-primary': '#007F92',      // Bleu principal encore plus vif
        'al-primary-medium': '#00A3BC', // Bleu interactions accentué
        'al-primary-light': '#66D8E6',  // Bleu clair lumineux
        'al-secondary': '#6A4A32',    // Marron principal demandé
        'al-secondary-dark': '#4F3725', // Marron foncé
        'al-accent': '#FF8F7A',       // Accent saumon plus intense
        'al-bg-light': '#F9DDBE',     // Beige clair plus lumineux
        'al-bg-medium': '#F0BF8E',    // Beige moyen plus dense
        'al-text-dark': '#1A1A1A',    // Noir - texte principal
        'al-text': '#2E2E2E',         // Anthracite - texte secondaire
        'al-bg': '#FAF7F2',           // Blanc cassé - fond global
      },
      fontFamily: {
        'display': ['Cormorant Garamond', 'serif'],
        'sans': ['Inter', 'system-ui', 'sans-serif'],
      },
      fontSize: {
        'h1': ['3rem', { lineHeight: '1.1', fontWeight: '700' }],
        'h2': ['2.25rem', { lineHeight: '1.2', fontWeight: '700' }],
        'h3': ['1.875rem', { lineHeight: '1.3', fontWeight: '600' }],
        'h4': ['1.5rem', { lineHeight: '1.4', fontWeight: '600' }],
        'h5': ['1.25rem', { lineHeight: '1.5', fontWeight: '600' }],
        'h6': ['1rem', { lineHeight: '1.5', fontWeight: '600' }],
      },
      spacing: {
        'section': '3rem',
        'section-lg': '5rem',
      },
      boxShadow: {
        'al-soft': '0 2px 8px rgba(26, 26, 26, 0.08)',
        'al-medium': '0 4px 16px rgba(26, 26, 26, 0.12)',
        'al-strong': '0 8px 24px rgba(26, 26, 26, 0.15)',
      },
      borderRadius: {
        'al': '0.75rem',
        'al-lg': '1rem',
      },
    },
  },
  plugins: [],
}
