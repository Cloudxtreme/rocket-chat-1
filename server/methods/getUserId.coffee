Meteor.methods
	getUserId: (username) ->
		user = RocketChat.models.Users.findOne {username: username}
		return user and user._id
