extends "res://addons/gut/test.gd"

func setup():
	gut.file_touch('user://some_test_file')

func teardown():
	gut.file_delete('user://some_test_file')


func test_pending():
	pending('This test is not implemented yet')
	pending()

func test_equals():
	var one = 1
	var node1 = Node.new()
	var node2 = node1

	assert_eq(one, 1, 'one should equal one') # PASS
	assert_eq('racecar', 'racecar') # PASS
	assert_eq(node2, node1) # PASS

	gut.p('-- failing --')
	assert_eq(1, 2) # FAIL
	assert_eq('hello', 'world') # FAIL
	assert_eq(self, node1) # FAIL

func test_not_equal():
	var two = 2
	var node1 = Node.new()

	gut.p('-- passing --')
	assert_ne(two, 1, 'Two should not equal one.')  # PASS
	assert_ne('hello', 'world') # PASS
	assert_ne(self, node1) # PASS

	gut.p('-- failing --')
	assert_ne(two, 2) # FAIL
	assert_ne('one', 'one') # FAIL
	assert_ne('2', 2) # FAIL

func test_greater_than():
	var bigger = 5
	var smaller = 0

	gut.p('-- passing --')
	assert_gt(bigger, smaller, 'Bigger should be greater than smaller') # PASS
	assert_gt('b', 'a') # PASS
	assert_gt('a', 'A') # PASS
	assert_gt(1.1, 1) # PASS

	gut.p('-- failing --')
	assert_gt('a', 'a') # FAIL
	assert_gt(1.0, 1) # FAIL
	assert_gt(smaller, bigger) # FAIL

func test_less_than():
	var bigger = 5
	var smaller = 0
	gut.p('-- passing --')
	assert_lt(smaller, bigger, 'Smaller should be less than bigger') # PASS
	assert_lt('a', 'b') # PASS

	gut.p('-- failing --')
	assert_lt('z', 'x') # FAIL
	assert_lt(-5, -5) # FAIL

func test_true():
	gut.p('-- passing --')
	assert_true(true, 'True should be true') # PASS
	assert_true(5 == 5, 'That expressions should be true') # PASS

	gut.p('-- failing --')
	assert_true(false) # FAIL
	assert_true('a' == 'b') # FAIL

func test_false():
	gut.p('-- passing --')
	assert_false(false, 'False is false') # PASS
	assert_false(1 == 2) # PASS
	assert_false('a' == 'z') # PASS
	assert_false(self.has_user_signal('nope')) # PASS

	gut.p('-- failing --')
	assert_false(true) # FAIL
	assert_false('ABC' == 'ABC') # FAIL


func test_assert_between():
	gut.p('-- passing --')
	assert_between(5, 0, 10, 'Five should be between 0 and 10') # PASS
	assert_between(10, 0, 10) # PASS
	assert_between(0, 0, 10) # PASS
	assert_between(2.25, 2, 4.0) # PASS

	gut.p('-- failing --')
	assert_between('a', 'b', 'c') # FAIL
	assert_between(1, 5, 10) # FAIL


func test_has():
	var an_array = [1, 2, 3, 'four', 'five']
	var a_hash = { 'one':1, 'two':2, '3':'three'}

	gut.p('-- passing --')
	assert_has(an_array, 'four') # PASS
	assert_has(an_array, 2) # PASS
	# the hash's has method checkes indexes not values
	assert_has(a_hash, 'one') # PASS
	assert_has(a_hash, '3') # PASS

	gut.p('-- failing --')
	assert_has(an_array, 5) # FAIL
	assert_has(an_array, self) # FAIL
	assert_has(a_hash, 3) # FAIL
	assert_has(a_hash, 'three') # FAIL

func test_does_not_have():
	var an_array = [1, 2, 3, 'four', 'five']
	var a_hash = { 'one':1, 'two':2, '3':'three'}

	gut.p('-- passing --')
	assert_does_not_have(an_array, 5) # PASS
	assert_does_not_have(an_array, self) # PASS
	assert_does_not_have(a_hash, 3) # PASS
	assert_does_not_have(a_hash, 'three')

	gut.p('-- failing --')
	assert_does_not_have(an_array, 'four') # FAIL
	assert_does_not_have(an_array, 2) # FAIL
	# the hash's has method checkes indexes not values
	assert_does_not_have(a_hash, 'one') # FAIL
	assert_does_not_have(a_hash, '3') # FAIL

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

class SomeClass:
	var _count = 0

	func get_count():
		return _count
	func set_count(number):
		_count = number

	func get_nothing():
		pass
	func set_nothing(val):
		pass

func test_assert_get_set_methods():
	var some_class = SomeClass.new()
	gut.p('-- passing --')
	assert_get_set_methods(some_class, 'count', 0, 20) # 4 PASSING

	gut.p('-- failing --')
	# 1 FAILING, 3 PASSING
	assert_get_set_methods(some_class, 'count', 'not_default', 20)
	# 2 FAILING, 2 PASSING
	assert_get_set_methods(some_class, 'nothing', 'hello', 22)
	# 2 FAILING
	assert_get_set_methods(some_class, 'does_not_exist', 'does_not', 'matter')

class MovingNode:
	extends Node2D
	var _speed = 2

	func _ready():
		set_process(true)

	func _process(delta):
		set_pos(get_pos() + Vector2(_speed * delta, 0))

func test_illustrate_yield():
	var moving_node = MovingNode.new()
	add_child(moving_node)
	moving_node.set_pos(Vector2(0, 0))

	# While the yield happens, the node should move
	yield(yield_for(2), YIELD)
	assert_gt(moving_node.get_pos().x, 0)
	assert_between(moving_node.get_pos().x, 3.9, 4, 'it should move almost 4 whatevers at speed 2')

func test_illustrate_end_test():
	yield(yield_for(1), YIELD)
	# we don't have anything to test yet, or at all.  So we
	# call end_test so that Gut knows all the yielding has
	# finished.
	end_test()

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
	assert_has_signal(obj, 'yea, this one doesnt exist either')
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

class BaseClass:
	var a = 1
class SubClass:
	extends BaseClass


func test_assert_extends():
	gut.p('-- passing --')
	assert_extends(Node2D.new(), Node2D)
	assert_extends(Label.new(), CanvasItem)
	assert_extends(SubClass.new(), BaseClass)
	# Since this is a test script that inherits from test.gd, so
	# this passes.  It's not obvious w/o seeing the whole script
	# so I'm telling you.  You'll just have to trust me.
	assert_extends(self, load('res://addons/gut/test.gd'))

	var Gut = load('res://addons/gut/gut.gd')
	var a_gut = Gut.new()
	assert_extends(a_gut, Gut)

	gut.p('-- failing --')
	assert_extends(Node2D.new(), Node2D.new())
	assert_extends(BaseClass.new(), SubClass)
	assert_extends('a', 'b')
	assert_extends([], Node)
