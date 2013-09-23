route = module.exports = (app) ->

  app.get '/', helper.checkAuth, (req, res) ->
    res.render 'index', { title: 'Home' }