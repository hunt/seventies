route = module.exports = (app) ->

  app.get '/ping', (req, res) ->
    now = Math.round (new Date()).getTime() / 1000
    res.json {timestamp: now}