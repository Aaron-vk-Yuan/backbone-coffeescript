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

	Backbone
)