export default defineAppConfig({
  alpine: {
    title: 'Pedro P. Camellon - Blog',
    description: 'Personal blog for sharing my thoughts and projects.',
    image: {
      src: '/social-card-preview.png',
      alt: 'An image showcasing my project.',
      width: 500,
      height: 500
    },
    header: {
      position: 'right', // possible value are : | 'left' | 'center' | 'right'
      logo: {
        enabled: false, // possible value are : true | false
        path: '/logo.svg', // path of the logo
        pathDark: '/logo-dark.svg', // path of the logo in dark mode, leave this empty if you want to use the same logo
        alt: 'alpine' // alt of the logo
      }
    },
    footer: {
      credits: {
        enabled: false, // possible value are : true | false
        repository: 'https://www.github.com/nuxt-themes/alpine' // our github repository
      },
      navigation: true, // possible value are : true | false
      alignment: 'center', // possible value are : 'none' | 'left' | 'center' | 'right'
      message: 'Follow me on' // string that will be displayed in the footer (leave empty or delete to disable)
    },
    socials: {
      twitter: 'pedropcamellon',
      linkedin: {
        icon: 'uil:linkedin',
        label: 'LinkedIn',
        href: 'https://www.linkedin.com/in/pedro-pablo-camellon-328744234'
      }
    },
    form: {
      successMessage: 'Message sent. Thank you!'
    },
    // Disable back to top button: false
    backToTop: {
      text: 'Back to top',
      icon: 'material-symbols:arrow-upward'
    }
  }
})
