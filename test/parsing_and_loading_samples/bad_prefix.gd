extends "res://addons/gut/test.gd"

func setup():
	gut.p("ran setup", 2)

func test_assert_eq_number_not_equal():
	gut.assert_eq(1, 2, "Should fail.  1 != 2")
