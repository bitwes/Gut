extends GutTest

class UsesTime:
	# Must have a reference to Engine Singleton that we can
	# inject our double into.
	var time := Time

	var _start_time = -1
	func start():
		_start_time = time.get_ticks_msec()

	func end():
		var monday_extra = 0
		if(time.get_date_dict_from_system().weekday == time.WEEKDAY_MONDAY):
			monday_extra = 10
		return time.get_ticks_msec() - _start_time + monday_extra


# Fun fact, this test will fail if ran on any Monday.  I wrote this on a
# Wednesday, so it passes.  This is a doozy of a flakey test.
func test_calling_end_returns_elapsed_time_using_msecs():
	var dbl_time = partial_double_singleton(Time).new()
	var inst = UsesTime.new()
	inst.time = dbl_time

	stub(dbl_time.get_ticks_msec).to_return(0)
	inst.start()
	stub(dbl_time.get_ticks_msec).to_return(10)
	assert_eq(inst.end(), 10)


# Illustrate that enums are included in singleton doubles.
func test_on_mondays_elapsed_time_is_longer_because_time_moves_slower_on_mondays():
	var dbl_time = double_singleton(Time).new()
	var inst = UsesTime.new()

	inst.time = dbl_time
	stub(dbl_time.get_date_dict_from_system)\
		.to_return({
			"year": 2025,
			"month": 1,
			"day": 1,
			"weekday": Time.WEEKDAY_MONDAY})

	stub(dbl_time.get_ticks_msec).to_return(0)
	inst.start()
	stub(dbl_time.get_ticks_msec).to_return(10)
	assert_eq(inst.end(), 20)
