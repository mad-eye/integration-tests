fs = require 'fs'
Handlebars = require 'handlebars'
contexts = require './contexts'

source = fs.readFileSync 'config.xml.hbs', 'utf-8'
template = Handlebars.compile source
Handlebars.registerHelper 'csv', (list) ->
  list.join ", "

fs.mkdirSync "jenkins_templates" unless fs.existsSync "jenkins_templates"
for job, context of contexts
  output = template(context)
  dir = "jenkins_templates/#{job}"
  fs.mkdirSync dir unless fs.existsSync dir
  fs.writeFileSync "#{dir}/config.xml", output