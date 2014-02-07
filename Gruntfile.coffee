SASS_SOURCE_DIR="apogee/private/styles"
HTML_SOURCE_DIR="apogee/private/pages"
PUBLIC_DIR="apogee/public"
isDevelopmentEnv = !!process.env.MADEYE_DEBUG

templateData =
  googleAnalyticsId : process.env.MADEYE_GOOGLE_ANALYTICS_ID
  mixPanelToken : process.env.MADEYE_MIXPANEL_TOKEN
  apiUrl : process.env.MADEYE_API_URL || "/api"
  staticPrefix: ""

console.log "Using templateData", templateData

module.exports = (grunt) ->

  webTemplates = ['header', 'footer', 'home', 'tos', 'faq', 'docs']
  renderTasks = {}
  for name in webTemplates
    renderTasks[name] =
      src: "#{HTML_SOURCE_DIR}/#{name}.html.hbs"
      dest: "/tmp/#{name}.html"
      options:
        data: templateData

  webFiles = {}
  for page in ['home', 'tos', 'faq', 'docs']
    webFiles["#{PUBLIC_DIR}/pages/#{page}.html"] = ['/tmp/header.html', "/tmp/#{page}.html", '/tmp/footer.html']

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    sass:
      dist:
        files:
          "apogee/public/static/styles/main.css": "#{SASS_SOURCE_DIR}/main.scss"

    renderer: renderTasks

    concat:
      html:
        files: webFiles

    hashres:
      options:
        encoding: 'utf8',
        fileNameFormat: '${name}.${ext}?${hash}',
        renameFiles: false
      html:
        src: ["#{PUBLIC_DIR}/static/styles/main.css", "#{PUBLIC_DIR}/static/js/index-slider.js", "#{PUBLIC_DIR}/static/js/bootstrap.min.js", "#{PUBLIC_DIR}/static/js/theme.js"]
        dest: "#{PUBLIC_DIR}/pages/*.html"

    watch:
      scripts:
        files: ["#{HTML_SOURCE_DIR}/*.html.hbs", "#{SASS_SOURCE_DIR}/*scss"]
        tasks: ['default']
        options:
          spawn: false

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-hashres'
  grunt.loadNpmTasks 'grunt-renderer'
  grunt.loadNpmTasks 'grunt-contrib-concat'

  grunt.registerTask 'default', ['sass', 'renderer', 'concat', 'hashres']
