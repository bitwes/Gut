################################################################################
#All the magic happens with the extends.  This gets you access to all the gut
#asserts and the overridable setup and teardown methods.
#
#The path to this script is passed to an instance of the gut script when calling
#test_script
#
#WARNING
#	DO NOT assign anything to the gut variable.  This is set at runtime by the gut
#	script.  Setting it to something will cause everything to go crazy go nuts.
################################################################################
extends "res://addons/gut/test.gd"

func setup():
	gut.p("ran setup", 2)

func teardown():
	gut.p("ran teardown", 2)

func prerun_setup():
	gut.p("ran run setup", 2)

func postrun_teardown():
	gut.p("ran run teardown", 2)

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
	#display different info based on log level.  Default
	#level is 0, which means it will always show up.
	#Notice, that since this prints something at level 0
	#it will always be printed even when the log level
	#is set to print only failures.
	gut.p("log 0", 0)
	gut.p("log 1", 1)
	gut.p("log 2", 2)
