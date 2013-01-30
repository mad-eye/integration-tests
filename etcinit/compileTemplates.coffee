fs = require 'fs'
_ = require 'underscore'
Handlebars = require 'handlebars'
contexts = require './contexts'

source = fs.readFileSync 'app.conf.hbs', 'utf-8'
template = Handlebars.compile source

for environment in ['staging', 'production']
  fs.mkdirSync environment unless fs.existsSync environment
  for app in ['apogee', 'azkaban', 'bolide']
    context = _.extend(contexts[environment], contexts[app])
    output = template context
    fs.writeFileSync "#{environment}/#{app}.conf", output
