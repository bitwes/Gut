extends GutInternalTester

# Constants?

var SingletonParser = GutUtils.SingletonParser

func test_can_make_one():
	var sp = SingletonParser.new()
	assert_not_null(sp)


func test_can_make_parsed_script():
	var ps = SingletonParser.ParsedSingleton.new(OS)
	assert_not_null(ps)


func test_parsed_singleton_populates_methods():
	var ps = SingletonParser.ParsedSingleton.new(Time)
	assert_ne(ps.methods_by_name.size(), 0)


func test_parsed_singleton_does_not_include_object_methods():
	var ps = SingletonParser.ParsedSingleton.new(Time)
	assert_does_not_have(ps.methods_by_name, 'free')


func test_parsed_singleton_has_enums():
	var ps = SingletonParser.ParsedSingleton.new(Time)
	assert_eq(ps.enums["WEEKDAY_SUNDAY"], 0)


func test_parsed_singleton_enum_values_match_class_enum_values():
	var ps = SingletonParser.ParsedSingleton.new(Time)
	assert_eq(ps.enums["MONTH_JANUARY"], 1)


func test_parsed_singleton_does_not_have_object_enums():
	var ps = SingletonParser.ParsedSingleton.new(Time)
	assert_does_not_have(ps.enums, "CONNECT_DEFERRED")


func test_parsed_singleton_contains_properties():
	var ps = SingletonParser.ParsedSingleton.new(OS)
	assert_has(ps.properties, "delta_smoothing")


func test_parsed_singleton_properties_have_singleton_values():
	var ps = SingletonParser.ParsedSingleton.new(OS)
	assert_eq(ps.properties["low_processor_usage_mode_sleep_usec"], OS.low_processor_usage_mode_sleep_usec)


func test_parsed_singleton_has_signals():
	var ps = SingletonParser.ParsedSingleton.new(AudioServer)
	assert_has(ps.signals, 'bus_layout_changed')


func test_can_parse_all_singletons(p = use_parameters(GutUtils.all_singletons)):
	var ps = SingletonParser.ParsedSingleton.new(p)
	assert_not_null(ps)

func test_constants_are_added_as_enums():
	var ps = SingletonParser.ParsedSingleton.new(DisplayServer)
	assert_has(ps.enums, "INVALID_SCREEN")

func test_get_signal_text():
	var ps = SingletonParser.ParsedSingleton.new(AudioServer)
	var signal_meta = ps.signals['bus_renamed']
	var text = ps.get_signal_text(signal_meta)
	assert_eq(text, 'signal bus_renamed(bus_index, old_name, new_name)')

func test_get_all_signal_text():
	var ps = SingletonParser.ParsedSingleton.new(AudioServer)
	var text = ps.get_all_signal_text()
	assert_string_contains(text, 'signal bus_renamed(bus_index, old_name, new_name)')
	assert_string_contains(text, 'signal bus_layout_changed()')