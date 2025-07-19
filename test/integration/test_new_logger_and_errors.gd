extends GutTest


func before_all():
	_lgr.godot_errors_cause_failures = true


func after_all():
	_lgr.godot_errors_cause_failures = false



func test_pushing_an_error_causes_failure():
	push_error("This is an error")
	pass_test("Other than the error, this should be passing.")

func test_causing_an_error_fails_a_test():
	var vals = []
	var b = vals[30]
	pass_test("This passes if it does not error")


