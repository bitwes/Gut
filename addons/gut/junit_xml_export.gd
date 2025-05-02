## Exposes functionality to export results of a test run in JUnit XML format.
##
## This class exposes two methods for exporting GUT test results to XML.
## One returns a string representing the XML, and the other writes it to
## a file.
# TODO: this class doesn't store any state and could be turned into only
# static members

# TODO: Someone should probably make GutStringUtils' methods static
var _strutils := GutStringUtils.new()
## @ignore
## _exporter is our way to get test results as easily accessible dictionaries.
var _exporter = GutUtils.ResultExporter.new()


## @ignore
## Wraps content in CDATA section because it may contain special characters
## e.g. str(null) becomes <null> and can break XML parsing.
func _wrap_cdata(content) -> String:
	return "<![CDATA[" + str(content) + "]]>"


## @ignore
## Returns a string of the form "<name>='<value>'".
func add_attr(name, value) -> String:
	return str(name, '="', value, '" ')


## @ignore
## Returns a String of xml data about the results for a single test in a test
## script. The schema for the Dictionary [code]script_result[/code] can be
## found in res://addons/gut/result_exporter.gd:_export_scripts.
func _export_test_result(test: Dictionary) -> String:
	var to_return := ''

	# Right now the pending and failure messages won't fit in the message
	# attribute because they can span multiple lines and need to be escaped.
	if(test.status == 'pending'):
		var skip_tag := str("<skipped message=\"pending\">", _wrap_cdata(test.pending[0]), "</skipped>")
		to_return += skip_tag
	elif(test.status == 'fail'):
		var fail_tag := str("<failure message=\"failed\">", _wrap_cdata(test.failing[0]), "</failure>")
		to_return += fail_tag

	return to_return


## @ignore
## Returns a String of xml data about the results for a single test script.
## The schema for the Dictionary [code]script_result[/code] can be found in
## res://addons/gut/result_exporter.gd:_export_scripts.
func _export_tests(script_result: Dictionary, classname: String) -> String:
	var to_return := ""

	for test_name: String in script_result.keys():
		var test: Dictionary = script_result[test_name]
		var assert_count = test.passing.size() + test.failing.size()
		to_return += "<testcase "
		to_return += add_attr("name", test_name)
		to_return += add_attr("assertions", assert_count)
		to_return += add_attr("status", test.status)
		to_return += add_attr("classname", classname.replace("res://", ""))
		to_return += add_attr("time", test.time_taken)
		to_return += ">\n"

		to_return += _export_test_result(test)

		to_return += "</testcase>\n"

	return to_return


## @ignore
## Returns the total amount of time taken by a suite of tests in one script.
func _sum_test_time(script_result: Dictionary) -> float:
	var to_return := 0.0

	for test: Dictionary in script_result.values():
		to_return += test.time_taken

	return to_return


## @ignore
## Returns a String of xml data about the results for a group of test scripts.
## The schema for the Dictionary [code]exp_results[/code] can be found in
## res://addons/gut/result_exporter.gd:_make_results_dict.
func _export_scripts(exp_results: Dictionary) -> String:
	var to_return := ""
	for script_path: String in exp_results.test_scripts.scripts.keys():
		var s: Dictionary = exp_results.test_scripts.scripts[script_path]
		to_return += "<testsuite "
		to_return += add_attr("name", script_path.replace("res://", ""))
		to_return += add_attr("tests", s.props.tests)
		to_return += add_attr("failures", s.props.failures)
		to_return += add_attr("skipped", s.props.pending)
		to_return += add_attr("time", _sum_test_time(s.tests))
		to_return += ">\n"

		to_return += _strutils.indent_text(_export_tests(s.tests, script_path), 1, "    ")

		to_return += "</testsuite>\n"

	return to_return


## Takes in an instance of [GutMain] and returns a string of XML representing
## the results of the run.
func get_results_xml(gut: GutMain) -> String:
	var exp_results: Dictionary = _exporter.get_results_dictionary(gut)
	var to_return := '<?xml version="1.0" encoding="UTF-8"?>' + "\n"
	to_return += '<testsuites '
	to_return += add_attr("name", 'GutTests')
	to_return += add_attr("failures", exp_results.test_scripts.props.failures)
	to_return += add_attr('tests', exp_results.test_scripts.props.tests)
	to_return += ">\n"

	to_return += _strutils.indent_text(_export_scripts(exp_results), 1, "  ")

	to_return += '</testsuites>'
	return to_return


## Takes in an instance of GutMain and writes test results to an XML file
## specified by [param path]. Return value is an error code forwarded from
## the call to [method FileAccess.open] to write to [param path].
func write_file(gut: GutMain, path: String) -> int:
	var xml := get_results_xml(gut)

	var f_result: int = GutUtils.write_file(path, xml)
	if(f_result != OK):
		var msg := str("Error:  ", f_result, ".  Could not create export file ", path)
		GutUtils.get_logger().error(msg)

	return f_result
