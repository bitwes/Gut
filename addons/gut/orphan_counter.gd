# ------------------------------------------------------------------------------
# This is a utility for tracking changes in the orphan count.  Each time
# add_counter is called it adds/resets the value in the dictionary to the
# current number of orphans.  Each call to get_counter will return the change
# in orphans since add_counter was last called.
# ------------------------------------------------------------------------------
var _counters = {}

func orphan_count():
	return Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)

func add_counter(name):
	_counters[name] = orphan_count()

# Returns the number of orphans created since add_counter was last called for
# the name.  Returns -1 to avoid blowing up with an invalid name but still
# be somewhat visible that we've done something wrong.
func get_counter(name):
	return orphan_count() - _counters[name] if _counters.has(name) else -1

func print_orphans(name, lgr):
	var count = get_counter(name)

	if(count > 0):
		var o = 'orphan'
		if(count > 1):
			o = 'orphans'
		lgr.orphan(str(count, ' new ', o, '(', name, ').'))
