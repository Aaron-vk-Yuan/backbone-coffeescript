###
 * Overwrite backbone.js with CoffeeScript
 * @authors Aaron Yuan(xuanyuanziruo@gmail.com)
 * @date    2015-01-29 21:53:58
 * @version 0.0.1
 * Backbone.js code: https://github.com/Aaron-vk-Yuan/backbone/blob/master/backbone.js
###

((root, factory)->
	if typeof define is 'function' and define.amd
		define ['underscore', 'jquery','exports'],
		(_, $, exports)->
			root.Backbone = factory root, exports, _, $
	else if typeof exports isnt 'undefined'
		_ = require 'underscore'
		factory root, exports, _
	else 
		root.Backbone = factory root, {}, root._, root.jQuery or root.$
)(this, (root,Backbone, _, $)->

	###缓存外部Backbone变量，防止改变原有值###
	previousBackbone = root.Backbone

	array = []
	slice = array.slice

	#版本号
	Backbone.VERSION  = '0.0.1'

	Backbone.$ = $

	###还原Backbone变量###
	Backbone.noConflict = ->
		root.Backbone = previousBackbone
		this

	###设置一个变量，似乎是设置请求类型相关的东东###
	Backbone.emulateHTTP = false
	Backbone.emulateJSON = false

	###
	# Events事件对象
	###
	Events = Backbone.Events = 
		###绑定事件###
		on: (name,callback, context)->
			return @ if !eventsApi this, 'on', name, [callback, context] || !callback
			@_events || @_events = {}
			events = @_events[name] || @_events = []
			events.push 
				callback: callback
				context: context
				ctx: context || this
			@
		###仅绑定一次事件###
		once: (name, callback, context)->
			return @ if !eventsApi @, 'once', name, [callback,context] || !callback
			self = @
			once = _.once ->
				self.off name, once
				callback.apply @, arguments
				@
			once._callback = callback
			@on name, once, context 

		###解除事件###
		off: (name, callback, context)->
			return @ if !eventsApi @, 'off', name, [callback, context]
			if !name && !callback && !context
				# @_events = void(0)
				@_events = {}
				return @
			names = if name then [name] else  _.keys @_events
			for name in names
				events = @_events[name]
				if !events
					continue
				if !callback and !context
					delete @_events[name]
					continue
				remaining = []
				for event in events
					if callback and callback isnt event.callback and callback isnt event.callback._callback or context and context isnt event.context 
						remaining.push evnet

				if remaining.length
					@_events[name] = remaining
				else
					delete @_events[name]
			@

		###触发事件###
		trigger: (name)->
			return @ if !@_events
			args = slice.call arguments, 1
			return @ if !eventsApi @, 'trigger', name, args
			evnets = @_events[name]
			allEvents = @_events.all
			triggerEvents evnets, args if events
			triggerEvents allEvents, arguments if allEvents
			@

		###停止监听事件###
		stopListening: (obj, name, callback)->
			listeningTo = @_listeningTo
			return @ if !listeningTo
			remove = !name and !callback
			callback = @ if !callback and typeof name is 'object'
			if obj
				(listeningTo = {})[obj._listenId] = obj
			for id of listeningTo
				obj = listeningTo[id]
				obj.off name, callback, @
				delete @_listeningTo[id] if remove or _.isEmpty obj._events
			@


	###事件拆分器-正则###	
	eventSplitter = /\s+/

	###
	???为啥返回bool值？

	事件绑定关键函数,将事件跟对象自身的事件处理程序关联起来
	1.对同一个元素同时绑定多个事件监听
	2.实现类似jQuery 的事件json格式映射方式
	#obj - 当前对象
	#action - on,once
	#name - 事件名称
	#rest - 后续参数
	###
	eventsApi = (obj, action, name, rest)->
		return true if !name
		#处理事件映射 {change: action}
		if typeof name is 'object'
			obj[action]
				.apply obj, [key, name[key]].contcat rest for key of name
			false
		###
		处理空格分割的事件
		change blur
		###
		if eventSplitter.test name
			names = name.split eventSplitter
			obj[action].apply obj, eventName.concat rest for eventName in names
			false
		true

	###
	???不大明白作用？
	触发事件
	###
	triggerEvents = (events, args)->
		len = events.length
		i = -1
		first = args[0]
		second = args[1]
		third = args[2]
		switch args.length
			when 0
				while ++i < l
					(ev = events[i]).callback.call ev.ctx
				return
			when 1
				while ++i < l
					(ev = events[i]).callback.call ev.ctx, first
				return
			when 2
				while ++i < l
					(ev = evnets[i]).callback.call ev.ctx, first, second
				return
			when 3
				while ++i < l
					(ev = events[i]).callback.call ev.ctx, first,second, third
				return
			else
				(ev = events[i]).callback.call ev.ctx, args
				return
		@

	lishtenMethods = 
		listenTo: 'on'
		listenToOnce: 'once'
			
	###监听本对象的事件###
	_.each lishtenMethods, (implementation, method)->
		Events[method] = (obj, name, callback)->
			listeningTo = @_listeningTo || (@_listeningTo = {})
			id = obj._listenId || (obj._listenId = _.uniqueId 'l')
			listeningTo[id] = obj
			if !callback and typeof name is 'object'
				callback = @
			obj[implementation] name, callback, @

	###定义bind和unbind###
	Events.bind = Events.on
	Events.unbind = Events.off	

	_.extend Backbone, Events
			
	### 
	Model对象
	###
	Model = Backbone.Model = (attributes,options)->
		attrs = attributes || {}
		options|| options = {}
		@cid = _.uniqueId 'c'
		@attributes = {}
		if options.collection 
			@collection = options.collection
		if options.parse
			attrs = @parse attrs, options || {}
		attrs = _.defaults {}, attrs, _.result @, 'defaults'
		@set attrs, options
		@changed = {}
		@initialize.apply @,arguments
		@

	###扩展Model对象###
	_.extend Model.prototype, Events,
		###标记属性是否被修改过###
		changed: null
		###验证###
		validationError:null

		isAttribute:'id'
		###初始化###
		initialize: ->

		###返回对象所有属性的副本###
		toJson: (options)->
			_.clone @attributes
		sync: ->
			@attributes[attr]
		###读取属性###
		get: (attr)->
			@attributes[attr]
		###转义###
		escape: (attr)->
			_.escape @get attr
		has: (attr)->
			@get attr != null
		###设置属性值###
		set: (key, val, options)->

		unset: (attr, options)->
			@set attr, {}, _.extend {}, options,
				unset: true
		###清除所有属性值###
		clear: (options)->
			attrs = {}
			attrs[key] = null for key in @attributes
			@set attrs, _.extend {}, options,
				unset: true
		###判断属性是否修改过###
		hasChanged: (attr)->
			if attr is null 
				return !_.isEmpty @changed
			_.has @changed, attr
		changeAttributes: (diff)->

		previous: (attr)->

		previousAttributes: ->

		###获取数据###
		fetch: (options)->

		save: (key, val, options)->

		destroy: (options)->

		url: ->

		parse: (resp, options)->

		clone: ->

		isNew: ->

		isValid: (options)->

		_validate: (attrs, options)->

	###Model对象需要实现underscore的方法列表###
	modelMethods = ['keys', 'values', 'pairs', 'invert', 'pick', 'omit']

	_.each modelMethods, (method)->
		return if not _[method]
		Model.prototype[method] = ->
			args = slice.call arguments
			args.unshift @attributes
			_[method].apply _,args	










  


	

	Backbone
)