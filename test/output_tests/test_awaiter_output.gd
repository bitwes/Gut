extends GutInternalTester

func before_each():
	_awaiter._await_logger.log_initial_message_delay = 0.0


func test_wait_seconds():
	await wait_seconds(.1, 'this is the message')
	pass_test('passing')


func test_wait_1s():
	_awaiter._await_logger.log_initial_message_delay = .9
	await wait_seconds(1, 'this is the message')
	pass_test('passing')


func test_wait_idle_frames():
	await wait_idle_frames(10, 'this is the message')
	pass_test('passing')


func test_wait_physics_frames():
	await wait_physics_frames(10, 'this is the message')
	pass_test('passing')


func test_wait_until():
	var f = func(): return true
	await wait_until(f, 5, 'this is the message')
	pass_test('passing')


func test_wait_while():
	var f = func(): return false
	await wait_while(f, 5, 'this is the message')
	pass_test('passing')


signal some_signal
func test_wait_for_signal():
	await wait_for_signal(some_signal, .5, 'this is the message')
	pass_test('passing')