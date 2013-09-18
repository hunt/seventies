route = module.exports = (app) ->
  
  app.get '/forget', (req, res) ->
    res.render 'member/forget'