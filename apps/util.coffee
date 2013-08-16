route = module.exports = (app) ->

  app.get '/ping', (req, res) ->
    now = Math.round (new Date()).getTime() / 1000
    res.json {timestamp: now}

  app.get '/debug/session', (req, res) ->
    req.session.count++
    data =
      session: req.session
      ip: req_ip
    res.json data