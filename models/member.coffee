memberSchema = new Schema
  
  id:
    type: String

  name:
    type: String

  link:
    type: String

  login:
    type: String

  password:
    type: String

  gender:
    type: String

  avatar:
    type: String

  email:
    type: String

  roles: 
    type: String

  status:
    type: String
    default: "active"

  updated:
    type: Date
    default: Date.now

  created:
    type: Date
    default: Date.now

memberSchema.statics.createData = (data, callback) ->
  obj = new Member data

  obj.save (err, member) ->
    if err?
      callback err
    else
      callback member._id

memberSchema.statics.updateData = (query, data, callback) ->
  Member.findOne query, (err, member)->
    data.updated = new Date()
    Member.update query, data, (err, member) ->
      if err?
        callback err
      else
        callback "Member updated"

memberSchema.statics.findData = (query, callback) ->
  Member.find query, (err, member) ->
    if err?
      callback err
    else
      callback member

Member = mongoose.model 'Member', memberSchema