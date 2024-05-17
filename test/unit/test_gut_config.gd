extends GutTest

var starting_log_level = 99
func before_all():
    starting_log_level = gut.log_level

func after_each():
    gut.log_level = starting_log_level
    gut.p(str('log level = ', gut.log_level))

func after_all():
    gut.log_level = starting_log_level

func test_can_make_one():
    var gc = GutUtils.GutConfig.new()
    assert_not_null(gc)

func test_double_strategy_defaults_to_include_native():
    var gc = GutUtils.GutConfig.new()
    assert_eq(gc.default_options.double_strategy, 'SCRIPT_ONLY')

func test_gut_gets_double_strategy_when_applied():
    var gc = GutUtils.GutConfig.new()
    var g = autofree(GutUtils.Gut.new())
    g.log_level = gut.log_level

    gc.options.double_strategy = GutUtils.DOUBLE_STRATEGY.SCRIPT_ONLY
    gc.apply_options(g)
    assert_eq(g.double_strategy, gc.options.double_strategy)

func test_gut_gets_default_when_value_invalid():
    var gc = GutUtils.GutConfig.new()
    var g = autofree(GutUtils.Gut.new())
    g.log_level = gut.log_level

    g.double_strategy = GutUtils.DOUBLE_STRATEGY.SCRIPT_ONLY
    gc.options.double_strategy = 'invalid value'
    gc.apply_options(g)
    assert_eq(g.double_strategy, GutUtils.DOUBLE_STRATEGY.SCRIPT_ONLY)

func test_another_thing():
    assert_true(true)