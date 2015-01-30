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

	###Events事件对象###
	Events = Backbone.Events = 
		#绑定事件
		on: (name,callback, context)->

		#仅绑定一次事件
		once: (name, callback, context)->

		#解除事件
		off: (name, callback, context)->

		#触发事件
		trigger: (name)->

		#停止监听事件
		stopListening: (obj, name, callback)->

	###事件拆分器-正则###	
	eventSplitter = /\s+/

	###
	???为啥返回bool值？

	事件绑定关键函数,将事件跟对象自身的事件处理程序关联起来
	1.对同一个元素同时绑定多个事件监听
	2.实现类似jQuery 的事件json格式映射方式
	#obj - 
	#action - 
	#name - 
	#rest - 
	###
	eventsApi = (obj, action, name, rest)->
		return true if !name
		#处理事件映射 {change: action}
		if typeof name is 'object'
			obj[action]
				.apply obj, [key, name[key].contcat rest] for key of name
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
		


		



  


	

	Backbone
)