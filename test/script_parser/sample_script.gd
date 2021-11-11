extends "res://addons/gut/test.gd"

class FauxXY:
	extends "res://addons/gut/test.gd"
	var x: int
	var y: int
	
	func _init() -> void:
		x = 0
		y = 0
	
	func test_xy() -> void:
		assert_true(x == 0, "Testing X")
		assert_true(y == 0, "Testing Y")

var xy: FauxXY

func 	before_all		() -> void:
	xy = FauxXY.new()

func 	after_all		() -> void:
	xy.free()

func 	test_faux_xy	() -> void:
	assert_true(xy.x == 0, "Testing Initial X")
	assert_true(xy.y == 0, "Testing Initial Y")
	xy.x = 15
	xy.y = 15
	assert_true(xy.x == 15, "Testing Setting X")
	assert_true(xy.y == 15, "Testing Setting Y")
