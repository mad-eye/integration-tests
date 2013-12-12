LESS_SOURCE_DIR="apogee/client/styles"
HTML_SOURCE_DIR="apogee/private/pages"
PUBLIC_DIR="apogee/public"
isDevelopmentEnv = !!process.env.MADEYE_DEBUG

templateData =
  "googleAnalyticsId" : process.env.MADEYE_GOOGLE_ANALYTICS_ID
  "staticPrefix": ""

module.exports = (grunt) ->

  webTemplates = ['header', 'footer', 'home', 'get-started', 'tos', 'faq']
  renderTasks = {}
  for name in webTemplates
    renderTasks[name] =
      src: "#{HTML_SOURCE_DIR}/#{name}.html.hbs"
      dest: "/tmp/#{name}.html"
      options:
        data: templateData

  webFiles = {}
  for page in ['home', 'get-started', 'tos', 'faq']
    pages = ''
    pages = 'pages/' unless page in ['home', 'get-started']
    webFiles["#{PUBLIC_DIR}/#{pages}#{page}.html"] = ['/tmp/header.html', "/tmp/#{page}.html", '/tmp/footer.html']

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    less:
      static:
        options:
          cleancss: !isDevelopmentEnv
        files:
          "apogee/public/static/styles/home.css": ["#{LESS_SOURCE_DIR}/base.less", "#{LESS_SOURCE_DIR}/index.less", "#{LESS_SOURCE_DIR}/home.less"]

    renderer: renderTasks

    concat:
      html:
        files: webFiles


  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-renderer'
  grunt.loadNpmTasks 'grunt-contrib-concat'

  grunt.registerTask 'default', ['less', 'renderer', 'concat']
