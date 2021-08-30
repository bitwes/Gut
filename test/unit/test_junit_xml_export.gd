extends 'res://addons/gut/test.gd'

var Gut = load('res://addons/gut/gut.gd')
var JunitExporter = _utils.JunitExporter
var Logger = _utils.Logger

var _test_gut = null

func pretty_print(dict):
	print(str(JSON.print(dict, ' ')))

# Returns a new gut object, all setup for testing.
func get_a_gut():
	var g = Gut.new()
	g.set_yield_between_tests(false)
	g.set_log_level(g.LOG_LEVEL_ALL_ASSERTS)
	g.set_logger(_utils.Logger.new())
	g.get_logger().disable_printer('terminal', true)
	g.get_logger().disable_printer('gui', true)
	g.get_logger().disable_printer('console', true)
	return g


func run_scripts(g, one_or_more):
	var scripts = one_or_more
	if(typeof(scripts) != TYPE_ARRAY):
		scripts = [scripts]
	for s in scripts:
		g.add_script(export_script(s))
	g.test_scripts()


func assert_is_valid_xml(s):
	var pba = s.to_utf8()
	var parser = XMLParser.new()
	var result = parser.open_buffer(pba)
	while(result == OK):
		result = parser.read()
		if(parser.get_node_type() == parser.NODE_ELEMENT):
			print(parser.get_node_name())
	assert_eq(result, ERR_FILE_EOF, 'Parsing xml should reach EOF')
	return parser

func export_script(name):
	return str('res://test/resources/exporter_test_files/', name)

func before_all():
	_utils._test_mode = true

func before_each():
	_test_gut = get_a_gut()
	add_child_autoqfree(_test_gut)


func test_can_make_one():
	assert_not_null(JunitExporter.new())

func test_no_tests_returns_valid_xml():
	_test_gut.test_scripts()
	var re = JunitExporter.new()
	var result = re.export_results(_test_gut)
	assert_is_valid_xml(result)
	print(result)

func test_spot_check():
	run_scripts(_test_gut, ['test_simple_2.gd', 'test_simple.gd', 'test_with_inner_classes.gd'])
	var re = JunitExporter.new()
	var result = re.export_results(_test_gut)
	assert_is_valid_xml(result)
	print(result)

