const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  enabled: process.env.NODE_ENV === "production",
  content: ["../lib/**/*.{ex,eex,heex,sface}", "./js/**/*.js"],
  theme: {
    fontFamily: {
      sans: ["'Ubuntu'", ...defaultTheme.fontFamily.sans],
      mono: ["'Ubuntu Mono'", ...defaultTheme.fontFamily.mono],
    },
  },
  plugins: [require("@tailwindcss/forms"), require("@tailwindcss/typography")],
};
