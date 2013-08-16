memberSchema = new Schema
  
  username:
    type: String

  password:
    type: String

  email:
    type: String
    index: true
    required: true
    validate: [ 
      /\S+@\S+\.\S/
      'Email is not valid'
    ]

  roles: 
    type: String

  status:
    type: String
    default: "published"

  updated:
    type: Date
    default: Date.now

  created:
    type: Date
    default: Date.now

Member = mongoose.model 'Member', memberSchema