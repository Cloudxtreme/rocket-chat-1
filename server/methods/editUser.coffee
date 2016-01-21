Meteor.methods
  editUser: (userId, options) ->
    # edit username
    if options.username
      result = Accounts.findUserByUsername(options.username)
      if result
        if result._id != userId
          # username already exists
          throw new (Meteor.Error)('username-exists', 'Username already exists')
      else
        # No user exists with this username. Safe to edit.
        Accounts.setUsername userId, options.username
    else
      # username is empty
      throw new (Meteor.Error)('username-empty', 'Username cannot be empty')
    # edit password
    if options.password
      Accounts.setPassword userId, options.password
    # edit email
    if options.email
      user = Meteor.users.findOne(userId)
      emails = user and user.emails or []
      # remove existing emails so that only one email is stored for each user
      emails.forEach (email) ->
        Accounts.removeEmail userId, email.address
        return
      # add new email
      Accounts.addEmail userId, options.email
    return true
