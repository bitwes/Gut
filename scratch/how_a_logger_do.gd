extends SceneTree

var GutGodotLogger = load("res://addons/gut/gut_godot_logger.gd")
var lgr = GutGodotLogger.new()


func add_em_up(a, b, c):
	return a + b / c


func assert_these_two_things_are_equal(a, b):
	assert(a == b, str(a, ' == ', b))


func whatever_man():
	lgr.start_test("this is a test")
	add_em_up(10, "asdf", Node)
	add_em_up(10, "asdf", Node)
	add_em_up(10, "asdf", Node)

	lgr.end_test()
	add_em_up(Node2D, "asdf", 44)

	lgr.start_test("another_test")
	add_em_up("asdf", Label, 44)


func whatever_asserts():
	assert_these_two_things_are_equal(1, 1)
	assert_these_two_things_are_equal(1, 2)

func whatever_push_error():
	push_error("something")

func summary():
	print("----------------")
	print(lgr.test_errors.to_s())
	print("----------------")


func _init():
	var max_iter := 20
	var iter := 0
	while(Engine.get_main_loop() == null and iter < max_iter):
		await create_timer(.01).timeout
		iter += 1

	print("main loop = ", Engine.get_main_loop())

	OS.add_logger(lgr)

	whatever_man()
	whatever_push_error()
	whatever_asserts()

	summary()
	OS.remove_logger(lgr)
	await create_timer(.01).timeout

	quit()