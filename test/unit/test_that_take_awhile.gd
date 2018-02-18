extends "res://addons/gut/test.gd"


func test_count_to_1000000():
	for i in range(1000000):
		pass
	assert_true(true)

func test_count_to_2000000():
	for i in range(2000000):
		pass
	assert_true(true)

func test_count_to_3000000():
	for i in range(3000000):
		pass
	assert_true(true)
