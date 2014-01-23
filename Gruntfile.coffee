SASS_SOURCE_DIR="apogee/private/styles"
HTML_SOURCE_DIR="apogee/private/pages"
PUBLIC_DIR="apogee/public"
isDevelopmentEnv = !!process.env.MADEYE_DEBUG

templateData =
  "googleAnalyticsId" : process.env.MADEYE_GOOGLE_ANALYTICS_ID
  "mixPanelToken" : process.env.MADEYE_MIXPANEL_TOKEN
  "staticPrefix": ""

module.exports = (grunt) ->

  webTemplates = ['header', 'footer', 'home', 'tos', 'faq']
  renderTasks = {}
  for name in webTemplates
    renderTasks[name] =
      src: "#{HTML_SOURCE_DIR}/#{name}.html.hbs"
      dest: "/tmp/#{name}.html"
      options:
        data: templateData

  webFiles = {}
  for page in ['home', 'get-started', 'tos', 'faq']
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
        src: ["#{PUBLIC_DIR}/static/styles/main.css"]
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
