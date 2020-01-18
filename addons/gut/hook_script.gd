# ------------------------------------------------------------------------------
# This script is the base for custom scripts to be used in pre and post
# run hooks.
# ------------------------------------------------------------------------------

# This is the instance of GUT that is running the tests.  You can get
# information about the run from this object.  This is set by GUT when the
# script is instantiated.
var gut  = null

# Virtual method that will be called by GUT after instantiating
# this script.
func run():
	pass
