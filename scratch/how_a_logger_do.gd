extends SceneTree

var GutGodotLogger = load("res://addons/gut/gut_godot_logger.gd")
var lgr = GutGodotLogger.new()


func add_em_up(a, b, c):
	return a + b / c


func _init():
	var max_iter := 20
	var iter := 0
	while(Engine.get_main_loop() == null and iter < max_iter):
		await create_timer(.01).timeout
		iter += 1

	print("main loop = ", Engine.get_main_loop())

	OS.add_logger(lgr)
	lgr.start_test("this is a test")
	add_em_up(10, "asdf", Node)
	add_em_up(10, "asdf", Node)
	add_em_up(10, "asdf", Node)

	lgr.end_test()
	add_em_up(Node2D, "asdf", 44)

	lgr.start_test("another_test")
	add_em_up("asdf", Label, 44)

	print("----------------")
	print(lgr.test_errors.to_s())
	print("----------------")

	OS.remove_logger(lgr)

	# await create_timer(.25).timeout
	quit()