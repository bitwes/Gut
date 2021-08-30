var _utils = load('res://addons/gut/utils.gd').get_instance()

var _exporter = _utils.ResultExporter.new()

func indent(s, ind):
	var to_return = ind + s
	to_return = to_return.replace("\n", "\n" + ind)
	return to_return


func add_attr(name, value):
	return str(name, '="', value, '" ')

func _export_test_result(test):
	var to_return = ''

	if(test.status == 'pending'):
		to_return += str('<skipped>', test.pending[0], '</skipped>')
	elif(test.status == 'fail'):
		to_return += str('<failure>', test.failing[0], '</failure>')

	return to_return


func _export_tests(script_result, classname):
	var to_return = ""

	for key in script_result.keys():
		var test = script_result[key]
		var assert_count = test.passing.size() + test.failing.size()
		to_return += "<testcase "
		to_return += add_attr("name", key)
		to_return += add_attr("assertions", assert_count)
		to_return += add_attr("status", test.status)
		to_return += add_attr("classname", classname)
		to_return += ">\n"

		to_return += _export_test_result(test)

		to_return += "</testcase>\n"

	return to_return

func _export_scripts(exp_results):
	var to_return = ""
	for key in exp_results.test_scripts.scripts.keys():
		var s = exp_results.test_scripts.scripts[key]
		to_return += "<testsuite "
		to_return += add_attr("name", key)
		to_return += add_attr("tests", s.props.tests)
		to_return += add_attr("disabled", s.props.disabled)
		to_return += add_attr("failures", s.props.failures)
		to_return += ">\n"

		to_return += indent(_export_tests(s.tests, key), "    ")

		to_return += "</testsuite>\n"

	return to_return


func export_results(gut):
	var exp_results = _exporter.export_results(gut)
	_utils.pretty_print(exp_results)
	var to_return = '<?xml version="1.0" encoding="UTF-8"?>' + "\n"
	to_return += '<testsuites '
	to_return += str('name="', exp_results.test_scripts.props.name, '" ')
	to_return += str('disabled="', exp_results.test_scripts.props.disabled, '" ')
	to_return += str('failures="', exp_results.test_scripts.props.failures, '" ')
	to_return += str('tests="', exp_results.test_scripts.props.tests, '" ')
	to_return += ">\n"

	to_return += _export_scripts(exp_results)

	to_return += '</testsuites>'
	return to_return
