var _to_free = []
var _to_queue_free = []

func add_free(thing):
	if(typeof(thing) == TYPE_OBJECT):
		if(!thing is Reference):
			_to_free.append(thing)

func add_queue_free(thing):
	_to_queue_free.append(thing)

func get_queue_free_count():
	return _to_queue_free.size()

func get_free_count():
	return _to_free.size()

func free_all():
	for i in range(_to_free.size()):
		if(is_instance_valid(_to_free[i])):
			_to_free[i].free()
	_to_free.clear()

	for i in range(_to_queue_free.size()):
		if(is_instance_valid(_to_queue_free[i])):
			_to_queue_free[i].queue_free()
	_to_queue_free.clear()


