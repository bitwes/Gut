extends "res://addons/gut/test.gd"

func before_each():
	gut.file_touch('user://some_test_file')

func after_each():
	gut.file_delete('user://some_test_file')

func test_assert_file_exists():
	gut.p('-- passing --')
	assert_file_exists('res://addons/gut/gut.gd') # PASS
	assert_file_exists('user://some_test_file') # PASS

	gut.p('-- failing --')
	assert_file_exists('user://file_does_not.exist') # FAIL
	assert_file_exists('res://some_dir/another_dir/file_does_not.exist') # FAIL

func test_assert_file_does_not_exist():
	gut.p('-- passing --')
	assert_file_does_not_exist('user://file_does_not.exist') # PASS
	assert_file_does_not_exist('res://some_dir/another_dir/file_does_not.exist') # PASS

	gut.p('-- failing --')
	assert_file_does_not_exist('res://addons/gut/gut.gd') # FAIL

func test_assert_file_empty():
	gut.p('-- passing --')
	assert_file_empty('user://some_test_file') # PASS

	gut.p('-- failing --')
	assert_file_empty('res://addons/gut/gut.gd')

func test_assert_file_not_empty():
	gut.p('-- passing --')
	assert_file_not_empty('res://addons/gut/gut.gd') # PASS

	gut.p('-- failing --')
	assert_file_not_empty('user://some_test_file') # FAIL


# ------------------------------------------------------------------------------
class ExportClass:
	@export var some_number = 5
	@export var some_scene: PackedScene
	var some_variable = 1

func test_assert_exports():
	var obj = ExportClass.new()

	gut.p('-- passing --')
	assert_exports(obj, "some_number", TYPE_INT)
	assert_exports(obj, "some_scene", TYPE_OBJECT)

	gut.p('-- failing --')
	assert_exports(obj, 'some_number', TYPE_VECTOR2)
	assert_exports(obj, 'some_scene', TYPE_AABB)
	assert_exports(obj, 'some_variable', TYPE_INT)


# ------------------------------------------------------------------------------
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_assert_signal_emitted():
	var obj = SignalObject.new()

	watch_signals(obj)
	obj.emit_signal('some_signal')

	gut.p('-- passing --')
	assert_signal_emitted(obj, 'some_signal')

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_emitted(obj, 'signal_does_not_exist')
	# Fails because the object passed is not being watched
	assert_signal_emitted(SignalObject.new(), 'some_signal')
	# Fails because the signal was not emitted
	assert_signal_emitted(obj, 'other_signal')

func test_assert_signal_not_emitted():
	var obj = SignalObject.new()

	watch_signals(obj)
	obj.emit_signal('some_signal')

	gut.p('-- passing --')
	assert_signal_not_emitted(obj, 'other_signal')

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_not_emitted(obj, 'signal_does_not_exist')
	# Fails because the object passed is not being watched
	assert_signal_not_emitted(SignalObject.new(), 'some_signal')
	# Fails because the signal was emitted
	assert_signal_not_emitted(obj, 'some_signal')

func test_assert_signal_emitted_with_parameters():
	var obj = SignalObject.new()

	watch_signals(obj)
	# emit the signal 3 times to illustrate how the index works in
	# assert_signal_emitted_with_parameters
	obj.emit_signal('some_signal', 1, 2, 3)
	obj.emit_signal('some_signal', 'a', 'b', 'c')
	obj.emit_signal('some_signal', 'one', 'two', 'three')

	gut.p('-- passing --')
	# Passes b/c the default parameters to check are the last emission of
	# the signal
	assert_signal_emitted_with_parameters(obj, 'some_signal', ['one', 'two', 'three'])
	# Passes because the parameters match the specified emission based on index.
	assert_signal_emitted_with_parameters(obj, 'some_signal', [1, 2, 3], 0)

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_emitted_with_parameters(obj, 'signal_does_not_exist', [])
	# Fails because the object passed is not being watched
	assert_signal_emitted_with_parameters(SignalObject.new(), 'some_signal', [])
	# Fails because parameters do not match latest emission
	assert_signal_emitted_with_parameters(obj, 'some_signal', [1, 2, 3])
	# Fails because the parameters for the specified index do not match
	assert_signal_emitted_with_parameters(obj, 'some_signal', [1, 2, 3], 1)

func test_assert_signal_emit_count():
	var obj_a = SignalObject.new()
	var obj_b = SignalObject.new()

	watch_signals(obj_a)
	watch_signals(obj_b)
	obj_a.emit_signal('some_signal')
	obj_a.emit_signal('some_signal')

	obj_b.emit_signal('some_signal')
	obj_b.emit_signal('other_signal')

	gut.p('-- passing --')
	assert_signal_emit_count(obj_a, 'some_signal', 2)
	assert_signal_emit_count(obj_a, 'other_signal', 0)

	assert_signal_emit_count(obj_b, 'other_signal', 1)

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_emit_count(obj_a, 'signal_does_not_exist', 99)
	# Fails because the object passed is not being watched
	assert_signal_emit_count(SignalObject.new(), 'some_signal', 99)
	# The following fail for obvious reasons
	assert_signal_emit_count(obj_a, 'some_signal', 0)
	assert_signal_emit_count(obj_b, 'other_signal', 283)

func test_assert_has_signal():
	var obj = SignalObject.new()

	gut.p('-- passing --')
	assert_has_signal(obj, 'some_signal')
	assert_has_signal(obj, 'other_signal')

	gut.p('-- failing --')
	assert_has_signal(obj, 'not_a real SIGNAL')
	assert_has_signal(obj, 'yea, this one doesn\'t exist either')
	# Fails because the signal is not a user signal.  Node2D does have the
	# specified signal but it can't be checked this way.  It could be watched
	# and asserted that it fired though.
	assert_has_signal(Node2D.new(), 'exit_tree')

func test_get_signal_parameters():
	var obj = SignalObject.new()
	watch_signals(obj)
	obj.emit_signal('some_signal', 1, 2, 3)
	obj.emit_signal('some_signal', 'a', 'b', 'c')

	gut.p('-- passing --')
	# passes because get_signal_parameters returns the most recent emission
	# by default
	assert_eq(get_signal_parameters(obj, 'some_signal'), ['a', 'b', 'c'])
	assert_eq(get_signal_parameters(obj, 'some_signal', 0), [1, 2, 3])
	# if the signal was not fired null is returned
	assert_eq(get_signal_parameters(obj, 'other_signal'), null)
	# if the signal does not exist or isn't being watched null is returned
	assert_eq(get_signal_parameters(obj, 'signal_dne'), null)

	gut.p('-- failing --')
	assert_eq(get_signal_parameters(obj, 'some_signal'), [1, 2, 3])
	assert_eq(get_signal_parameters(obj, 'some_signal', 0), ['a', 'b', 'c'])

# ------------------------------------------------------------------------------
class Signaler:
	signal the_signal

class Connector:
	func connect_this():
		pass
	func  other_method():
		pass

func test_assert_connected():
	var signaler = Signaler.new()
	var connector  = Connector.new()
	signaler.connect('the_signal',Callable(connector,'connect_this'))

	# Passing
	assert_connected(signaler, connector, 'the_signal')
	assert_connected(signaler, connector, 'the_signal', 'connect_this')

	# Failing
	var foo = Connector.new()
	assert_connected(signaler,  connector, 'the_signal', 'other_method')
	assert_connected(signaler, connector, 'other_signal')
	assert_connected(signaler, foo, 'the_signal')
