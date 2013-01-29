express = require 'express'
http = require 'http'
fs = require 'fs'

app = express()

# global lib
global._ = require 'lodash'
app.config = require './config'

# app helper
helper = require './libs/helper'
bundle_up = require 'bundle-up'

app.configure ->
  app.set 'env', process.env.NODE_ENV or 'development'
  app.set 'port', process.env.PORT or 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger 'dev'

  # bundle up
  console.log 'Waiting bundle-up build js/css files' if app.config.bundle_up.minify_js and app.config.bundle_up.bundle
  bundle_up app, __dirname + '/assets' ,
    staticRoot: __dirname + '/public/'
    staticUrlRoot: app.config.bundle_up.url_root
    bundle: app.config.bundle_up.bundle
    minifyCss: app.config.bundle_up.minify_css
    minifyJs: app.config.bundle_up.minify_js

  app.use helper.init
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router # defined router
  app.use express.static "#{__dirname}/public"


app.configure 'development', ->
  app.use express.errorHandler()

# load param
require('./libs/params')(app)

# loadding applications
for file in fs.readdirSync './apps'
  continue if file is 'util.coffee' or file.search(/\.bak|\.disabled|^\./) > -1
  require("./apps/#{file}")(app)
require("./apps/util")(app)

http.createServer(app).listen app.get('port'), ->
  console.log "Application '#{app.get('env')}' listening on port #{app.get('port')}"
  console.log "http://localhost:#{app.get('port')}"
