extends GutInternalTester

var _gut = null

	
func before_each():
	_gut = add_child_autofree(new_gut(verbose))


func test_wait_1_expect_eq_0():
	var s = autofree(DynamicGutTest.new())
	s.add_source("""
    func test_wait_1_expect_eq_0():
        await wait_seconds(1)
        assert_elapsed_time_eq(0)
	""")
	var t = await s.run_tests_in_gut_await(_gut)
	assert_eq(t.failing, 1, 'one failing')
	assert_eq(t.passing, 0, 'zero passing')


func test_wait_1_expect_almost_eq_0():
	var s = autofree(DynamicGutTest.new())
	s.add_source("""
    func test_wait_1_expect_almost_eq_0():
        await wait_seconds(1)
        assert_elapsed_time_almost_eq(0, 0.1)
	""")
	var t = await s.run_tests_in_gut_await(_gut)
	assert_eq(t.failing, 1, 'one failing')
	assert_eq(t.passing, 0, 'zero passing')

	
func test_wait_1_expect_almost_eq_1():
	var s = autofree(DynamicGutTest.new())
	s.add_source("""
    func test_wait_1_expect_almost_eq_1():
        await wait_seconds(1)
        assert_elapsed_time_almost_eq(1, 0.1)
	""")
	var t = await s.run_tests_in_gut_await(_gut)
	assert_eq(t.failing, 0, 'zero failing')
	assert_eq(t.passing, 1, 'one passing')


func test_wait_2_expect_almost_eq_1():
	var s = autofree(DynamicGutTest.new())
	s.add_source("""
    func test_wait_2_expect_almost_eq_1():
        await wait_seconds(2)
        assert_elapsed_time_almost_eq(1, 0.1)
	""")
	var t = await s.run_tests_in_gut_await(_gut)
	assert_eq(t.failing, 1, 'one failing')
	assert_eq(t.passing, 0, 'zero passing')


func test_wait_0_expect_lt_1():
	var s = autofree(DynamicGutTest.new())
	s.add_source("""
    func test_wait_0_expect_lt_1():
        assert_elapsed_time_lt(1)
	""")
	var t = await s.run_tests_in_gut_await(_gut)
	assert_eq(t.failing, 0, 'zero failing')
	assert_eq(t.passing, 1, 'one passing')


func test_wait_2_expect_lt_1():
	var s = autofree(DynamicGutTest.new())
	s.add_source("""
    func test_wait_2_expect_lt_1():
        await wait_seconds(2)
        assert_elapsed_time_lt(1)
	""")
	var t = await s.run_tests_in_gut_await(_gut)
	assert_eq(t.failing, 1, 'one failing')
	assert_eq(t.passing, 0, 'zero passing')


func test_wait_0_expect_gt_1():
	var s = autofree(DynamicGutTest.new())
	s.add_source("""
    func test_wait_0_expect_gt_1():
        assert_elapsed_time_gt(1)
	""")
	var t = await s.run_tests_in_gut_await(_gut)
	assert_eq(t.failing, 1, 'one failing')
	assert_eq(t.passing, 0, 'zero passing')


func test_wait_2_expect_gt_1():
	var s = autofree(DynamicGutTest.new())
	s.add_source("""
    func test_wait_2_expect_gt_1():
        await wait_seconds(2)
        assert_elapsed_time_gt(1)
	""")
	var t = await s.run_tests_in_gut_await(_gut)
	assert_eq(t.failing, 0, 'zero failing')
	assert_eq(t.passing, 1, 'one passing')
