extends GutInternalTester


var DialogScene = load("res://addons/gut/gui/ShellOutOptions.tscn")

func test_can_make_one():
	var inst = DialogScene.instantiate()
	assert_not_null(inst)
	inst.free()

var split_param = ParameterFactory.named_parameters(
	['args', 'result'],
	[
		['--a', ['--a']],
		['   -b     -x    ', ['-b', '-x']],
		['-r "hello world"', ['-r', '"hello', 'world"']]
	]
)
func test_arg_splitting(p = use_parameters(split_param)):
	var inst = autofree(DialogScene.instantiate())
	inst.additional_arguments = p.args
	var packed_results = PackedStringArray(p.result)
	assert_eq(inst.get_additional_arguments_array(), packed_results)


var invalid_args = ParameterFactory.named_parameters(
	['args', 'valid_blocking', 'valid_non_blocking'],
	[
		['-d', false, false], ['--debug', false , false],
		['-s', false, false], ['--script', false, false],
		['--headless', false, true]
	]
)
func test_invalid_arguments(p = use_parameters(invalid_args)):
	var inst = autofree(DialogScene.instantiate())
	inst.additional_arguments = p.args
	inst.run_mode = inst.RUN_MODE_BLOCKING
	assert_eq(inst.validate_arguments(), p.valid_blocking, str('"',p.args, '" is valid for blocking'))
	inst.run_mode = inst.RUN_MODE_NON_BLOCKING
	assert_eq(inst.validate_arguments(), p.valid_non_blocking, str('"', p.args, '" is valid for non-blocking'))
