var _counters = {}

func _orphan_count():
	return Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)

func add_counter(name):
	_counters[name] = _orphan_count()

func get_counter(name):
	return _orphan_count() - _counters[name]

func print_orphans(name, lgr):
	var count = get_counter(name)

	if(count > 0):
		var o = 'orphan'
		if(count > 1):
			o = 'orphans'
		lgr.log(str(count, ' new ', o, '(', name, ').'), lgr.fmts.yellow)
