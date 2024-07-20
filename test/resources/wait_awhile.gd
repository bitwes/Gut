extends GutTest

var seconds_to_wait = 10
# This is used with running tests so that you can wait a bit and then move on
# to other tests.
func test_this_waits_for_a_bit(p = run_x_times(seconds_to_wait)):
	gut.p(seconds_to_wait - p)
	await wait_seconds(1)
	pass_test("This passes because it just waits")