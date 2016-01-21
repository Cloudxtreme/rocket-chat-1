Meteor.methods
	getUserId: (username) ->
		user = RocketChat.models.Users.findOne(username: username)
		if user
			return user._id
		else
			throw new (Meteor.Error)('user-not-found', username + ' not found in users collection.')
		return
