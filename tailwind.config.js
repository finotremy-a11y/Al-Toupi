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
        // Design System Al Toupi - Palette Terroir Premium
        'al-primary': '#3A5F3A',      // Vert profond - titres, accents primaires
        'al-primary-medium': '#4F7A4F', // Vert moyen - interactions
        'al-primary-light': '#7FAF7F',  // Vert clair - hover states, backgrounds
        'al-secondary': '#8B5E3C',    // Marron chaud - accents, sous-titres
        'al-secondary-dark': '#6B4226', // Marron foncé - borders, accents forts
        'al-bg-light': '#F5E9D3',     // Beige clair - sections, cards backgrounds
        'al-bg-medium': '#E8D4B8',    // Beige moyen - accents, borders
        'al-text-dark': '#1A1A1A',    // Noir - texte principal
        'al-text': '#2E2E2E',         // Anthracite - texte secondaire
        'al-bg': '#FAF7F2',           // Blanc cassé - fond global
      },
      fontFamily: {
        'display': ['Playfair Display', 'serif'],
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
