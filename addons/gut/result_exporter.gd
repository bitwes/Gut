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
				"disabled":s.get_pending_count(),
				"failures":s.get_fail_count(),
			},
			"tests":_export_tests(s)
		}
	return scripts


# TODO
#	time
#	errors
func export_results(gut):
	var summary = gut.get_summary()
	var scripts = _export_scripts(summary)
	var totals = summary.get_totals()

	var result =  {
		'test_scripts':{
			"props":{
				"disabled":totals.pending,
				"failures":totals.failing,
				"name":"not_used",
				"tests":totals.tests,
			},
			"scripts":scripts
		}
	}
	return result