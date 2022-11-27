extends GutTest


const DEFAULT_PARAMS_PATH = 'res://test/resources/doubler_test_objects/double_default_parameters.gd'

func test_for_warnings():
    var Dbl = partial_double(load(DEFAULT_PARAMS_PATH))
    var inst = Dbl.new()
    var start_warn_count = gut.logger.get_warnings().size()

    stub(inst, 'call_me').param_defaults([null, 'bar'])
    print('******** asserting *************')
    assert_eq(inst.call_call_me('foo'), 'called with foo, bar')
    assert_eq(gut.logger.get_warnings().size(), start_warn_count, 'no warnings')
