module.exports = 
  
  init: (req,res,next) ->
    res.setHeader 'x-powered-by', 'Seventies'
    res.setHeader "Cache-Control", "public, max-age=0"
    res.locals.current_path = req.path
    res.locals.site_name = req.app.config.site_name
    global.req_ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress
    next()