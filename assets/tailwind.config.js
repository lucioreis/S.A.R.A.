// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      colors: {
        highlight: '#981130',
        main: {100: "#00000", 200: "#222222"},
        second: {100: "#FFFFFF", 200: "#f2f2f2", 300: "#d9d9d9"},
        hovering: {100: "#eeeee4"}
      },
      fontFamily: {
        body: ["Nunito"],
        app_logo: ["Just Another Hand"]
      }
      
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require("daisyui")
  ]
}
