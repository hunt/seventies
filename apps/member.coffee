route = module.exports = (app) ->

  app.get '/login', (req, res) ->
    res.render 'member/login'

  app.get '/register', (req, res) ->
    res.render 'member/register'

  app.get '/forget', (req, res) ->
    res.render 'member/forget'