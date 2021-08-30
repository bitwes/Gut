# ------------------------------------------------------------------------------
# Creates a structure that contains all the data about the results of running
# tests.  This was created to make an intermediate step organizing the result
# of a run and exporting it in a specific format.  This can also serve as a
# unofficial GUT export format.
# ------------------------------------------------------------------------------
var _utils = load('res://addons/gut/utils.gd').get_instance()

func _export_tests(summary_script):
	var to_return = {}
	var tests = summary_script.get_tests()
	for key in tests.keys():
		to_return[key] = {
			"status":tests[key].get_status(),
			"passing":tests[key].pass_texts,
			"failing":tests[key].fail_texts,
			"pending":tests[key].pending_texts
		}

	return to_return

# TODO
#	errors
func _export_scripts(summary):
	if(summary == null):
		return {}

	var scripts = {}

	for s in summary.get_scripts():
		scripts[s.name] = {
			'props':{
				"tests":s._tests.size(),
				"pending":s.get_pending_count(),
				"failures":s.get_fail_count(),
			},
			"tests":_export_tests(s)
		}
	return scripts


# TODO
#	time
#	errors
func get_results_dictionary(gut):
	var summary = gut.get_summary()
	var scripts = _export_scripts(summary)
	var totals = summary.get_totals()

	var result =  {
		'test_scripts':{
			"props":{
				"pending":totals.pending,
				"failures":totals.failing,
				"tests":totals.tests,
			},
			"scripts":scripts
		}
	}
	return result


func write_json_file(gut, path):
	var dict = get_results_dictionary(gut)
	var json = JSON.print(dict, ' ')

	var f_result = _utils.write_file(path, json)
	if(f_result != OK):
		var msg = str("Error:  ", f_result, ".  Could not create export file ", path)
		_utils.get_logger().error(msg)

	return f_result

