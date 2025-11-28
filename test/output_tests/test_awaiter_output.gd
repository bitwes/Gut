extends GutInternalTester

func before_each():
	wait_log_delay = 0.0


func test_wait_seconds():
	await wait_seconds(.1, 'this is the message')
	pass_test('passing')


func test_wait_1s():
	wait_log_delay = .9
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

func test_get_no_message_when_wait_is_less():
	wait_log_delay = 10
	await wait_idle_frames(1)
	await wait_physics_frames(1)
	await wait_seconds(.2)
	pass_test('passing')
