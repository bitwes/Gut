var _utils = load('res://addons/gut/utils.gd').get_instance()

func  _init(thing=null):
	if(thing is _utils.ArrayDiff):
		different_indexes = thing.get_different_indexes()
		summary = thing.summarize()
		are_equal = thing.are_equal()


var are_equal = null
var summary = null
var different_keys = null
var different_indexes = null
