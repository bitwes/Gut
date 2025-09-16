extends GutTest


func test_with_push_error():
	push_error('this is a push error')
	assert_true(true, 'passing assert')