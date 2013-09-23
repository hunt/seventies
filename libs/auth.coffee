everyauth = require 'everyauth'
connect = require 'connect'
Member = mongoose.model 'Member'

module.exports = everyauth

helper =
  updateFacebookUser: (metadata, callback) ->
    metadata.avatar = "http://graph.facebook.com/#{metadata.id}/picture"
    temp =
      fbid: metadata.id
      name: metadata.name
      email: metadata.email or null
      facebook: metadata
    Member.updateData {fbid: metadata.id}, temp, (err, data) ->
      if err?
        console.log 'update error'
      else
        callback err, data

  updateGoogleUser: (metadata, callback) ->
    metadata.avatar = "http://graph.facebook.com/#{metadata.id}/picture"
    temp =
      fbid: metadata.id
      name: metadata.name
      email: metadata.email or null
      google: metadata
    Member.updateData {googleid: metadata.id}, temp, callback    

everyauth.everymodule
  .findUserById (id, callback) ->
    callback null, null

everyauth
  .facebook
    .appId(app.config.facebook.app_id)
    .appSecret(app.config.facebook.secret)
    .scope('email, user_about_me, publish_actions')
    .handleAuthCallbackError( (req, res) -> res.redirect '/') # user denies your app
    .findOrCreateUser( (session, accessToken, accessTokenExtra, fbUserMetadata) ->
      metadata = fbUserMetadata
      Member.findByAnyId fbUserMetadata.id, (err, member) ->
        if member?
          helper.updateFacebookUser metadata, (err, result) ->
        else
          temp = 
            fbid: metadata.id
            name: metadata.name
            email: metadata.email or null
          Member.createData temp, (err, member) ->
            helper.updateFacebookUser metadata, (err, result) ->
              if err?
                console.log 'created fb error', err
              else
                console.log 'Created fb user'
    )
    .redirectPath('/')

everyauth
  .google
    .appId(app.config.google.app_id)
    .appSecret(app.config.google.secret)
    .scope('https://www.googleapis.com/auth/userinfo.profile https://www.google.com/m8/feeds/')
    .authQueryParam({ approval_prompt:'auto' }) # not always ask permission
    .handleAuthCallbackError( (req, res) -> res.redirect '/') # user denies your app
    .findOrCreateUser( (session, accessToken, accessTokenExtra, googleUserMetadata) ->
      metadata = googleUserMetadata
      Member.findByAnyId metadata.id, (err, member) ->
        if member?
          helper.updateGoogleUser metadata, (err, result) ->
        else
          temp = 
            googleid: metadata.id
            name: metadata.name
            email: metadata.email or null
          Member.createData temp, (err, member) ->
            console.log 'Created google user'
            helper.updateGoogleUser metadata, (err, result) ->
    )
    .redirectPath('/')

everyauth.everymodule.logoutRedirectPath '/'
