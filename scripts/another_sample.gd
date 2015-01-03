extends "res://scripts/gut.gd".Tests

func test_one():
	gut.assert_ne("five", "five", "This should fail")
