Blaze.registerHelper 'pathFor', (path, kw) ->
	return FlowRouter.path path, kw.hash

BlazeLayout.setRoot 'body'


FlowRouter.subscriptions = ->
	Tracker.autorun =>
		RoomManager.init()
		@register 'userData', Meteor.subscribe('userData')
		@register 'activeUsers', Meteor.subscribe('activeUsers')
		@register 'admin-settings', Meteor.subscribe('admin-settings')


FlowRouter.route '/',
	name: 'index'

	triggersEnter: [ (context, redirect) ->
		console.log '--------------------------------------------------'
		console.log 'Rocket chat router: Received request for route \'/\'. Query params: ', context.queryParams
		if context.queryParams and context.queryParams.token
			Meteor.loginWithToken context.queryParams.token, (error) ->
				if error
				  console.log 'Invalid token. Error: ', error.message
				else
				  console.log 'Valid token. Logged in!'
				console.log '--------------------------------------------------'
				return
		else
			console.log 'No token received.'
			console.log '--------------------------------------------------'
		return
	]

	action: ->
		BlazeLayout.render 'main', {center: 'loading'}
		if not Meteor.userId()
			return FlowRouter.go 'home'

		Tracker.autorun (c) ->
			if FlowRouter.subsReady() is true
				Meteor.defer ->
					if Meteor.user().defaultRoom?
						room = Meteor.user().defaultRoom.split('/')
						FlowRouter.go room[0], {name: room[1]}
					else
						FlowRouter.go 'home'
				c.stop()


FlowRouter.route '/login',
	name: 'login'

	action: ->
		FlowRouter.go 'home'


FlowRouter.route '/home',
	name: 'home'

	action: ->
		RocketChat.TabBar.reset()
		BlazeLayout.render 'main', {center: 'home'}
		KonchatNotification.getDesktopPermission()


FlowRouter.route '/changeavatar',
	name: 'changeAvatar'

	action: ->
		BlazeLayout.render 'main', {center: 'avatarPrompt'}

FlowRouter.route '/account/:group?',
	name: 'account'

	action: (params) ->
		RocketChat.TabBar.closeFlex()
		RocketChat.TabBar.resetButtons()

		unless params.group
			params.group = 'Preferences'
		params.group = _.capitalize params.group, true
		BlazeLayout.render 'main', { center: "account#{params.group}" }


FlowRouter.route '/history/private',
	name: 'privateHistory'

	subscriptions: (params, queryParams) ->
		@register 'privateHistory', Meteor.subscribe('privateHistory')

	action: ->
		Session.setDefault('historyFilter', '')
		BlazeLayout.render 'main', {center: 'privateHistory'}


FlowRouter.route '/terms-of-service',
	name: 'terms-of-service'

	action: ->
		Session.set 'cmsPage', 'Layout_Terms_of_Service'
		BlazeLayout.render 'cmsPage'

FlowRouter.route '/privacy-policy',
	name: 'privacy-policy'

	action: ->
		Session.set 'cmsPage', 'Layout_Privacy_Policy'
		BlazeLayout.render 'cmsPage'

FlowRouter.route '/room-not-found/:type/:name',
	name: 'room-not-found'

	action: (params) ->
		Session.set 'roomNotFound', {type: params.type, name: params.name}
		BlazeLayout.render 'main', {center: 'roomNotFound'}
