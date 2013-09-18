# ENV
env = process.env.NODE_ENV || 'development'
process.env.NODE_ENV = env

config = 
  default: 
    site_name: 'Seventies'

  production:
    session_secret: 'app-on-production'
    host:
      self: process.env.SELF_URL or 'http://www.example.com'
    facebook:
      app_id: process.env.FACEBOOK_APP_ID or '598041656875799'
      secret: process.env.FACEBOOK_SECRET or '76a3a3424e4970399d13d099aa03c88d'
    google:
      app_id: process.env.GOOGLE_APP_ID or '179193246032.apps.googleusercontent.com'
      secret: process.env.GOOGLE_SECRET or '9deFSd82Lba7NhzNLQoiwY1F'
    mongodb: process.env.MONGO_URI or process.env.MONGOLAB_URI or 'mongodb://localhost:27017/norndo'
    redis:
      port: '10329'
      url: process.env.REDISTOGO_URL or process.env.REDIS_URL or 'redis://:@localhost:6379'
    bundle_up:
      bundle: true
      url_root: '/'
      minify_css: true
      minify_js: false
  
  development:
    session_secret: 'app-dev'
    host:
      self: 'http://localhost:3000' or "http://localhost:#{process.env.PORT}"
    facebook:
      app_id: process.env.FACEBOOK_APP_ID or '598041656875799'
      secret: process.env.FACEBOOK_SECRET or '76a3a3424e4970399d13d099aa03c88d'
    google:
      app_id: process.env.GOOGLE_APP_ID or '179193246032.apps.googleusercontent.com'
      secret: process.env.GOOGLE_SECRET or '9deFSd82Lba7NhzNLQoiwY1F'
    mongodb: process.env.MONGO_URI or process.env.MONGOLAB_URI or 'mongodb://localhost:27017/seventies'
    redis:
      url: process.env.REDIS_URL or 'redis://:@localhost:6379'
      option: {}
    bundle_up:
      bundle: false
      url_root: '/'
      minify_css: false
      minify_js: false
      
module.exports = _.merge config[env], config['default']
