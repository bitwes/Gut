var Logger = load('res://addons/gut/logger.gd')
var Stubber = load('res://addons/gut/stubber.gd')
var Doubler = load('res://addons/gut/doubler.gd')
var Spy = load('res://addons/gut/spy.gd')

enum DOUBLE_STRATEGY{
	FULL,
	PARTIAL
}

# ------------------------------------------------------------------------------
# Everything should get a logger through this.
#
# Eventually I want to make this get a single instance of a logger but I'm not
# sure how to do that without everything having to be in the tree which I
# DO NOT want to to do.  I'm thinking of writings some instance ids to a file
# and loading them in the _init for this.
# ------------------------------------------------------------------------------
func get_logger():
	return Logger.new()
