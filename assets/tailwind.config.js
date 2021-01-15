module.exports = {
  purge: [
    "../**/*.html.eex",
    "../**/*.html.leex",
    "../**/views/**/*.ex",
    "../**/live/**/*.ex",
    "./js/**/*.js",
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    fontFamily: {
      sans: ['Ubuntu'],
      mono: ['Ubuntu\\ Mono'],
    },
    extend: {},
  },
  variants: {
    extend: {
      backgroundColor: ['responsive', 'dark', 'group-hover', 'focus-within', 'hover', 'focus', 'odd', 'even'],
    },
  },
  plugins: [
    require('@tailwindcss/forms'),    
  ],
};