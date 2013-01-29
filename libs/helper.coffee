module.exports = 
  init: (req,res,next) ->
    console.log req.app.config
    res.setHeader 'x-powered-by', 'Seventies'
    res.locals.current_path = req.path
    res.locals.site_name = req.app.config.site_name
    next()