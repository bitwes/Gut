extends GutTest


func test_can_make_one():
    var gc = _utils.GutConfig.new()
    assert_not_null(gc)

func test_double_strategy_defaults_to_include_super():
    var gc = _utils.GutConfig.new()
    assert_eq(gc.default_options.double_strategy, 'INCLUDE_SUPER')

func test_gut_gets_double_strategy_when_applied():
    var gc = _utils.GutConfig.new()
    var g = autofree(_utils.Gut.new())

    gc.options.double_strategy = GutUtils.DOUBLE_STRATEGY.SCRIPT_ONLY
    gc.apply_options(g)
    assert_eq(g.double_strategy, gc.options.double_strategy)

func test_gut_gets_default_when_value_invalid():
    var gc = _utils.GutConfig.new()
    var g = autofree(_utils.Gut.new())

    g.double_strategy = GutUtils.DOUBLE_STRATEGY.SCRIPT_ONLY
    gc.options.double_strategy = 'invalid value'
    gc.apply_options(g)
    assert_eq(g.double_strategy, GutUtils.DOUBLE_STRATEGY.INCLUDE_SUPER)

