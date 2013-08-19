everyauth = require 'everyauth'
connect = require 'connect'
Member = mongoose.model 'Member'

module.exports = everyauth

helper =
  addUser: (data, callback) ->
    console.log "add user", data
    temp =
      id: data.id
      name: data.name
      link: data.link
      login: data.username or data.given_name
      avatar: data.picture or ""
      gender: data.gender or ""
      email: data.email or ""
      status: data.status or "true"

    Member.createData temp, (result) ->
      member = {}
      member.id = result
      member.data = temp
      console.log "id", result
      callback member

  updateUser: (data, callback) ->
    Member.updateData { id: data.id }, data, (result) ->
      member = {}
      member.id = result
      member.data = data
      callback member

  checkAuth: (id, callback) ->
    Member.findData { id: id }, (result) ->
      callback result.length

  loadData: (id, callback) ->
    Member.findData { id: id } , (result) ->
      callback result[0]

usersById = {}

everyauth.everymodule
  .findUserById (id, callback) ->
    callback null, usersById[id]

everyauth
  .facebook
    .appId(app.config.facebook.app_id)
    .appSecret(app.config.facebook.secret)
    .scope('email, user_about_me, publish_actions')
    .findOrCreateUser( (session, accessToken, accessTokenExtra, fbUserMetadata) ->
      helper.checkAuth fbUserMetadata.id, (result) ->
        if result == 1
          helper.updateUser fbUserMetadata, (result) ->
            helper.loadData fbUserMetadata.id, (result) ->
              usersById[fbUserMetadata.id] = result
        else
          helper.addUser fbUserMetadata, (result) ->
            usersById[result.id] = result.data
    )
    .redirectPath('/')

everyauth
  .google
    .appId(app.config.google.app_id)
    .appSecret(app.config.google.secret)
    .scope('https://www.googleapis.com/auth/userinfo.profile https://www.google.com/m8/feeds/')
    .findOrCreateUser( (session, token, extra, googleUser) ->
      console.log googleUser
      helper.checkAuth googleUser.id, (result) ->
        if result == 1
          helper.updateUser googleUser, (result) ->
            helper.loadData googleUser.id, (result) ->
              usersById[googleUser.id] = result
        else
          helper.addUser googleUser, (result) ->
            usersById[result.id] = result.data
    )
    .redirectPath('/')

everyauth.everymodule.logoutRedirectPath '/'
