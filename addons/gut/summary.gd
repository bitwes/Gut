# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class Test:
	var pass_texts = []
	var fail_texts = []
	var pending_texts = []

	func to_s():
		var pad = '     '
		var to_return = ''
		for i in range(fail_texts.size()):
			to_return += str(pad, 'FAILED:  ', fail_texts[i], "\n")
		for i in range(pending_texts.size()):
			to_return += str(pad, 'Pending:  ', pending_texts[i], "\n")
		return to_return

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class TestScript:
	var name = 'NOT_SET'
	var _tests = {}
	var _test_order = []

	func _init(script_name):
		name = script_name

	func get_pass_count():
		var count = 0
		for key in _tests:
			count += _tests[key].pass_texts.size()
		return count

	func get_fail_count():
		var count = 0
		for key in _tests:
			count += _tests[key].fail_texts.size()
		return count

	func get_pending_count():
		var count = 0
		for key in _tests:
			count += _tests[key].pending_texts.size()
		return count

	func get_test_obj(name):
		if(!_tests.has(name)):
			_tests[name] = Test.new()
			_test_order.append(name)
		return _tests[name]

	func add_pass(test_name, reason):
		var t = get_test_obj(test_name)
		t.pass_texts.append(reason)

	func add_fail(test_name, reason):
		var t = get_test_obj(test_name)
		t.fail_texts.append(reason)

	func add_pending(test_name, reason):
		var t = get_test_obj(test_name)
		t.pending_texts.append(reason)

# ------------------------------------------------------------------------------
# Main class
# ------------------------------------------------------------------------------
var _scripts = []

func add_script(name):
	_scripts.append(TestScript.new(name))

func get_scripts():
	return _scripts

func get_current_script():
	return _scripts[_scripts.size() - 1]

func add_test(test_name):
	get_current_script().get_test_obj(test_name)

func add_pass(test_name, reason = ''):
	get_current_script().add_pass(test_name, reason)

func add_fail(test_name, reason = ''):
	get_current_script().add_fail(test_name, reason)

func add_pending(test_name, reason = ''):
	get_current_script().add_pending(test_name, reason)

func get_test_text(test_name):
	return test_name + "\n" + get_current_script().get_test_obj(test_name).to_s()

# Gets the count of unique script names minus the .<Inner Class Name> at the
# end.  Used for displaying the number of scripts without including all the
# Inner Classes.
func get_non_inner_class_script_count():
	var count = 0
	var unique_scripts = {}
	for i in range(_scripts.size()):
		var ext_loc = _scripts[i].name.find_last('.gd.')
		if(ext_loc == -1):
			unique_scripts[_scripts[i].name] = 1
		else:
			unique_scripts[_scripts[i].name.substr(0, ext_loc + 3)] = 1
	return unique_scripts.keys().size()

func get_totals():
	var totals = {
		passing = 0,
		pending = 0,
		failing = 0,
		tests = 0,
		scripts = 0
	}

	for s in range(_scripts.size()):
		totals.passing += _scripts[s].get_pass_count()
		totals.pending += _scripts[s].get_pending_count()
		totals.failing += _scripts[s].get_fail_count()
		totals.tests += _scripts[s]._test_order.size()

	totals.scripts = get_non_inner_class_script_count()

	return totals

func get_summary_text():
	var _totals = get_totals()

	var to_return = ''
	for s in range(_scripts.size()):
		if(_scripts[s].get_fail_count() > 0 or _scripts[s].get_pending_count() > 0):
			to_return += _scripts[s].name + "\n"
		for t in range(_scripts[s]._test_order.size()):
			var tname = _scripts[s]._test_order[t]
			var test = _scripts[s].get_test_obj(tname)
			if(test.fail_texts.size() > 0 or test.pending_texts.size() > 0):
				to_return += str('  - ', tname, "\n", test.to_s())

	var header = "***  Totals  ***\n"
	header += str('  scripts:          ', get_non_inner_class_script_count(), "\n")
	header += str('  tests:            ', _totals.tests, "\n")
	header += str('  passing asserts:  ', _totals.passing, "\n")
	header += str('  failing asserts:  ',_totals.failing, "\n")
	header += str('  pending:          ', _totals.pending, "\n")

	return to_return + "\n" + header
