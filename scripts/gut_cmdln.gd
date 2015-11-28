extends SceneTree

var Gut = load("res://scripts/gut.gd")
var _tester = null
var _opts = []
var options = {
	should_exit = false
}

func find_option(name, start_at=0):
	var found = false
	var idx = start_at
	
	while(idx < _opts.size() and !found):
		if(_opts[idx].find(name) == 0):
			found = true
		else:
			idx += 1
			
	if(found):
		return idx
	else:
		return -1

func get_option_value(full_option):
	var split = full_option.split('=')

	if(split.size() > 1):
		return split[1]
	else:
		return null

func parse_tests():
	var opt_loc = find_option('-gtest')
	while(opt_loc != -1):
		var script = get_option_value(_opts[opt_loc])
		if(script != null):
			print('adding script:  ' + script)
			_tester.add_script(script)
		_opts.remove(opt_loc)
		
		opt_loc = find_option('-gtest')
		
func parse_options():
	for i in range(OS.get_cmdline_args().size()):
		_opts.append(OS.get_cmdline_args().get(i))
	print(_opts)
	
	parse_tests()
	
	# exit option
	var e_loc = _opts.find('-exit')
	if(e_loc != -1):
		options.should_exit = true
		_opts.remove(e_loc)

func _init():
	_tester = Gut.new()
	get_root().add_child(_tester)
	_tester.connect('tests_finished', self, '_on_tests_finished')
	#_tester.add_script('res://scripts/sample_tests.gd')
	_tester.set_yield_between_tests(true)
	_tester.show()
	
	parse_options()
	
	_tester.test_scripts()
	

func _on_tests_finished():
	if(options.should_exit):
		quit()