extends "res://addons/gut/test.gd"

var the_script: Script
var parser: ScriptParser

func before_all() -> void:
	the_script = load("res://test/script_parser/sample_script.gd")
	parser = ScriptParser.new()
	parser.parse(the_script.get_source_code())
	gut.p("Script Tree:")
	gut.p(JSON.print(parser.code_tree,"\t"))

func after_all() -> void:
	parser.free()

func test_initial_parse() -> void:
	assert_true(parser.code_tree.hash() != {}.hash(), "Not an Empty Dictionary")

func test_key_parse() -> void:
	assert_has(parser.code_tree, "self", "Has base functions associated with script.")
	assert_has(parser.code_tree, "FauxXY", "Has FauxXY Function")

func test_func_parse() -> void:
	assert_has(parser.code_tree["self"], "before_all", "Has before_all")
	assert_has(parser.code_tree["self"], "after_all", "Has after_all")
	assert_has(parser.code_tree["self"], "test_faux_xy", "Has test_faux_xy")
	assert_does_not_have(parser.code_tree["FauxXY"], "before_all", "FauxXY does not have before_all")
	assert_does_not_have(parser.code_tree["FauxXY"], "after_all", "FauxXY does not have after_all")
	assert_has(parser.code_tree["FauxXY"], "test_xy", "FauxXY has test_xy")

func test_line_numbers() -> void:
	assert_eq(parser.code_tree["self"]["before_all"], 18, "before_all on line 18")
	assert_eq(parser.code_tree["self"]["after_all"], 21, "after_all on line 21")
	assert_eq(parser.code_tree["self"]["test_faux_xy"], 24, "test_faux_xy on line 24")
	assert_eq(parser.code_tree["FauxXY"]["test_xy"], 12, "FauxXY#test_xy on line 12")
