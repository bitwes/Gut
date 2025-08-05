extends GutInternalTester

func test_can_make_one():
	var gte = GutTrackedError.new()
	assert_not_null(gte)


func test_contains_text_true_when_code_contains_text():
	var gte = GutTrackedError.new()
	gte.code = 'look here'
	assert_true(gte.contains_text('ok he'))


func test_contains_text_true_when_rationale_has_text():
	var gte = GutTrackedError.new()
	gte.rationale = 'ok, I looked'
	assert_true(gte.contains_text(', i '))
