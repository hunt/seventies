memberSchema = new Schema
  name:     { type: String }
  email:    { type: String, index: true }
  fbid:     { type: String, index: true }
  facebook: { type: Schema.Types.Mixed }
  googleid: { type: String, index: true }
  google:   { type: Schema.Types.Mixed }
  role:     { type: String, default: 'member' }
  status:   { type: String, default: "active"}
  updated:  { type: Date, default: Date.now }
  created:  { type: Date, default: Date.now }
, #option
  versionKey: false

memberSchema.statics.createData = (data, callback) ->
  obj = new Member data
  obj.save callback

memberSchema.statics.updateData = (query, data, callback) ->
  Member.findOne query, (err, member)->
    data.updated = new Date()
    Member.update query, data, callback

memberSchema.statics.findByAnyId = (id, callback) ->
  this
    .findOne()
    .or( [ {fbid: id}, {googleid: id} ] )
    .exec callback

memberSchema.statics.findByEmail = (email, callback) ->
  this
    .findOne()
    .where('email', email)
    .exec callback

memberSchema.statics.findData = (query, callback) ->
  Member.find query, (err, member) ->
    if err?
      callback err
    else
      callback member

Member = mongoose.model 'Member', memberSchema