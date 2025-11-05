extends GutInternalTester

# Constants?
# Signals?


var SingletonParser = GutUtils.SingletonParser

func test_can_make_one():
	var sp = SingletonParser.new()
	assert_not_null(sp)


func test_can_make_parsed_script():
	var ps = SingletonParser.ParsedScript.new(OS)
	assert_not_null(ps)


func test_parsed_singleton_populates_methods():
	var ps = SingletonParser.ParsedScript.new(Time)
	assert_ne(ps.methods_by_name.size(), 0)


func test_parsed_singleton_does_not_include_object_methods():
	var ps = SingletonParser.ParsedScript.new(Time)
	assert_does_not_have(ps.methods_by_name, 'free')


func test_parsed_singleton_has_enums():
	var ps = SingletonParser.ParsedScript.new(Time)
	assert_eq(ps.enums["WEEKDAY_SUNDAY"], 0)


func test_parsed_singleton_enum_values_match_class_enum_values():
	var ps = SingletonParser.ParsedScript.new(Time)
	assert_eq(ps.enums["MONTH_JANUARY"], 1)


func test_parsed_singleton_does_not_have_object_enums():
	var ps = SingletonParser.ParsedScript.new(Time)
	assert_does_not_have(ps.enums, "CONNECT_DEFERRED")


func test_parsed_singleton_contains_properties():
	var ps = SingletonParser.ParsedScript.new(OS)
	assert_has(ps.properties, "delta_smoothing")


func test_parsed_singleton_properties_have_singleton_values():
	var ps = SingletonParser.ParsedScript.new(OS)
	assert_eq(ps.properties["low_processor_usage_mode_sleep_usec"], OS.low_processor_usage_mode_sleep_usec)


func test_parsed_singleton_has_signals():
	var ps = SingletonParser.ParsedScript.new(AudioServer)
	assert_has(ps.signals, 'bus_layout_changed')


func test_can_parse_all_singletons(p = use_parameters(GutUtils.all_singletons)):
	var ps = SingletonParser.ParsedScript.new(p)
	assert_not_null(ps)