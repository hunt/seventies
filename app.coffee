express = require 'express'
http = require 'http'
fs = require 'fs'
global.app = express()
global.mongoose = require 'mongoose'
global.Schema = mongoose.Schema
global.moment = require 'moment'
moment.lang 'th'
moment().zone("07:00")

# global lib
global._ = require 'lodash'
app.config = require './config'

rtg = app.config.redis.url
if rtg?
  rtg = require("url").parse rtg
  redis_password = rtg.auth.split(':')[1]
  global.redis = require("redis").createClient rtg.port, rtg.hostname

redis.on 'error', (err) ->
  console.log 'REDIS: ', err

# loading models
for file in fs.readdirSync './models'
  continue if file.search(/\.bak|\.disabled|^\./) > -1
  if file.search(/\.coffee/) < -1
    for file_sub in fs.readdirSync './models/' + file
      continue if file_sub.search(/\.bak|\.disabled|^\./) > -1
      require("./models/#{file}/#{file_sub}")
  else
    require("./models/#{file}")

# require "./models/#{file}" for file in fs.readdirSync './models'

# app helper
helper = require './libs/helper'
bundle_up = require 'bundle-up2'
everyauth = require './libs/auth'

app.configure ->
  app.set 'env', process.env.NODE_ENV or 'development'
  app.set 'port', process.env.PORT or 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use helper.init

  mongo = mongoose.connect app.config.mongodb
  mongoose.connection.on 'error', (err) ->
    console.log 'Mongoose error:', err
  mongoose.set 'debug', true
  everyauth.debug = true

  # bundle up
  console.log 'Waiting bundle-up build js/css files' if app.config.bundle_up.minify_js and app.config.bundle_up.bundle
  bundle_up app, __dirname + '/assets' ,
    staticRoot: __dirname + '/public/'
    staticUrlRoot: app.config.bundle_up.url_root
    bundle: app.config.bundle_up.bundle
    minifyCss: app.config.bundle_up.minify_css
    minifyJs: app.config.bundle_up.minify_js

  # for authentication support
  app.use express.cookieParser() # parse cookie header
  if redis? # if set redis server
    RedisStore = require('connect-redis')(express)
    app.use express.session
      store: new RedisStore
        host: rtg.hostname
        port: rtg.port
        prefix: "chs-sess"
        pass: redis_password
      secret: app.config.session_secret
      cookie:
        maxAge: 30 * 24 * 60 * 60 * 1000 # 1month
  else
    app.use express.session secret: app.config.session_secret
  app.use everyauth.middleware(app)
    
  # end of auth related

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
  continue if file.search(/\.bak|\.disabled|^\./) > -1
  if file.search(/\.coffee/) < -1
    for file_sub in fs.readdirSync './apps/' + file
      continue if file_sub.search(/\.bak|\.disabled|^\./) > -1
      require("./apps/#{file}/#{file_sub}")(app)
  else
    require("./apps/#{file}")(app)

http.createServer(app).listen app.get('port'), ->
  console.log "Application '#{app.get('env')}' listening on port #{app.get('port')}"
  console.log "http://localhost:#{app.get('port')}"
