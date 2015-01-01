################################################################################
#All the magic happens with this extends.  This gets you access to all the gut 
#asserts and the overridable setup and teardown methods.
#
#The path to this script is passed to an instance of the gut script when calling
#test_script
#
#WARNING
#	DO NOT assign anything to the gut variable.  This is set at runtime by the gut
#	script.  Setting it to something will cause everything to go crazy go nuts.
################################################################################
extends "res://scripts/gut.gd".Tests

func setup():
	print("ran setup")

func teardown():
	print("ran teardown")

func prerun_setup():
	print("ran run setup")

func postrun_teardown():
	print("ran run teardown")

func test_assert_eq_number_not_equal():
	gut.assert_eq(1, 2, "Should fail.  1 != 2")
	
func test_assert_eq_number_equal():
	gut.assert_eq('asdf', 'asdf', "Should pass")

func test_assert_true_with_true():
	gut.assert_true(true, "Should pass, true is true")

func test_assert_true_with_false():
	gut.assert_true(false, "Should fail")

func test_something_else():
	gut.assert_true(false, "didn't work")

func test_show_a_gut_print():
	#This is what you should use to print out stuff if
	#you want to see it in context of the test that it
	#ran in.
	gut.p("HELLO WORLD")
	gut.p("indented", 1)