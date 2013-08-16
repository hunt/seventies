everyauth = require 'everyauth'
connect = require 'connect'
Member = mongoose.model 'Member'

module.exports = everyauth

usersById = {}
usersByFbId = {}

everyauth.everymodule
  .findUserById (id, callback) ->
    callback null, usersById[id]

everyauth
  .facebook
    .appId(app.config.facebook.app_id)
    .appSecret(app.config.facebook.secret)
    .scope('email, user_birthday, user_likes, user_work_history, user_about_me, user_relationships, user_hometown, publish_actions, user_education_history, user_interests, user_subscriptions, user_status, user_location, user_groups')
    .findOrCreateUser( (session, accessToken, accessTokenExtra, fbUserMetadata) ->
      # console.log fbUserMetadata
      usersByFbId[fbUserMetadata.id] = fbUserMetadata
    )
    .redirectPath('/')

everyauth
  .google
    .appId(app.config.google.app_id)
    .appSecret(app.config.google.secret)
    .scope('https://www.googleapis.com/auth/userinfo.profile https://www.google.com/m8/feeds/')
    .findOrCreateUser( (session, token, extra, googleUser) ->
      console.log googleUser
      return googleUser
    )
    .redirectPath('/')

everyauth.github
  .appId(app.config.github.app_id)
  .appSecret(app.config.github.secret)
  .scope('repo')
  .findOrCreateUser( (session, accessToken, accessTokenExtra, githubUserMetadata) ->
    console.log githubUserMetadata
    return githubUserMetadata
  )
  .redirectPath('/')

everyauth.password
  .loginWith('email')
  .getLoginPath('/authlogin')
  .postLoginPath('/login')
  .loginView('login')
  .loginLocals( (req, res, done) ->
    setTimeout () ->
      done null, { title: 'Async login'}
    , 200
  )
  .authenticate( (login, password) ->
    errors = []
    if !login then errors.push 'Missing login'
    if !password then errors.push 'Missing password'
    if errors.length
      return errors

    promise = this.Promise();
    Member.findOne { email: login }, (err, user) ->
      if err?
        errors.push err.message || err
      if !user?
        errors.push 'User with login ' + login + ' does not exist.'
      if user.password != password
        errors.push "Wrong password."
      if errors.length
        promise.fulfill errors
      else
        usersById[user._id] = user
        promise.fulfill user
    return promise
  )
  .getRegisterPath('/authregister')
  .postRegisterPath('/register')
  .registerLocals( (req, res, done) ->
    setTimeout () ->
      done null, { title: 'Async Register' }
    , 200
  )
  .validateRegistration( (newUserAttrs, errors) ->
    promise = this.Promise()
    Member.findOne { email: newUserAttrs.email }, (err, member) ->
      if member?
        errors.push 'Email already taken'
        promise.fulfill errors
      else
        promise.fulfill member
    return promise
  )
  .registerUser( (newUserAttrs) ->
    promise = this.Promise()
    obj = new Member newUserAttrs

    obj.save (err, member) ->
      if err?
        return promise.fail err
      else
        usersById[member._id] = member
      return promise.fulfill member
    return promise
  )
  .loginSuccessRedirect('/')
  .registerSuccessRedirect('/')

everyauth.everymodule.logoutRedirectPath '/beta'
