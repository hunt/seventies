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
    bundle_up:
      bundle: true
      url_root: '/'
      minify_css: true
      minify_js: false
  
  development:
    session_secret: 'app-dev'
    host:
      self: 'http://localhost:3000' or "http://localhost:#{process.env.PORT}"
    bundle_up:
      bundle: false
      url_root: '/'
      minify_css: false
      minify_js: false
      
module.exports = _.merge config[env], config['default']
