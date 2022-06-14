// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
    './lib/*_web/**/*.heex'
  ],
  theme: {
    extend: {
      colors: {
        hovering: {DEFAULT: '#eeeee4', dark: 'BCBCB2'},
        primary: {light: '#aaaa00', DEFAULT: '#F2f2f2', dark: '#bfbfbf'},
        secundary: {dark: '#00000', DEFAULT: '#000', light: '#494949'},
        highlight: {light: '#ce4959', DEFAULT: '#981130', dark: '#630008' },
        base: {100: '#ffffff', 200: '#fafafa', 300: '#eeeeee', 400: '#e0e0e0', 500: '#dfdfdf', 600: '#bdbdbd', 700: '#9b9b9b', 800: '#787878', 900: '#565656' },
        
      },
      fontFamily: {
        body: ['Poppins'],
        app_logo: ['Just Another Hand']
      }
      
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('daisyui')
  ],
  daisyui: {
    styled: true,
    themes: true,
    base: true,
    utils: true,
    logs: true,
    rtl: false,
    prefix: "",
    darkTheme: "dark",
  },
}
