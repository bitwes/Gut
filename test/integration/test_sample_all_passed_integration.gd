#A sample script for illustrating multiple scripts and what it looks like
#when all tests pass.
extends "res://addons/gut/test.gd"

func test_works():
	gut.assert_true(true, 'This is true')

func test_two():
	gut.assert_eq("two", "two", "This is also true")

func test_3():
	gut.assert_ne("one", "two", "This is yet again true")
