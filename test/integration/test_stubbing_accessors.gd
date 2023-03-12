extends GutTest

var Stubber = load('res://addons/gut/stubber.gd')
var Doubler = load('res://addons/gut/doubler.gd')
var StubParams = load('res://addons/gut/stub_params.gd')


class HasAccessors:
    var string_normal_accessors = 'default' :
        get: return string_normal_accessors
        set(val):  string_normal_accessors = val

    var string_accessor_method = 'default' :
        get = _get_string_accessor_method,
        set = _set_string_accessor_method

    func _get_string_accessor_method():
        return string_accessor_method

    func _set_string_accessor_method(val):
        string_accessor_method = val

    func this_is_a_normal_method():
        print('you called this normal method')


var doubler = null
var stubber = null


func before_each():
    doubler = Doubler.new(_utils.DOUBLE_STRATEGY.INCLUDE_SUPER)
    doubler.inner_class_registry.register(self.get_script())
    # doubler.print_source = true
    stubber = _utils.Stubber.new()
    doubler.set_stubber(stubber)


func test_can_double_scripts_with_accessors():
    var DoubleHasAccessors = doubler.double(HasAccessors)
    var inst = DoubleHasAccessors.new()
    assert_not_null(inst)

func test_normal_get_accessor_not_stubbed():
    var DoubleHasAccessors = doubler.double(HasAccessors)
    var dbl_ha = DoubleHasAccessors.new()
    assert_eq(dbl_ha.string_normal_accessors, 'default')

func test_normal_set_accessor_not_stubbed():
    var DoubleHasAccessors = doubler.double(HasAccessors)
    var dbl_ha = DoubleHasAccessors.new()
    dbl_ha.string_normal_accessors = 'foo'
    assert_eq(dbl_ha.string_normal_accessors, 'foo')

func test_get_accessor_method_is_stubbed_to_do_nothing():
    var dbl_ha = doubler.double(HasAccessors).new()
    assert_null(dbl_ha.string_accessor_method)

func test_set_accessor_method_is_stubbed_to_do_nothing():
    var dbl_ha = doubler.double(HasAccessors).new()
    var sp1 = StubParams.new(dbl_ha, '_get_string_accessor_method').to_call_super()
    stubber.add_stub(sp1)
    dbl_ha.string_accessor_method = 'bar'
    assert_eq(dbl_ha.string_accessor_method, 'default')

func test_partial_double_works():
    var dbl_ha = doubler.partial_double(HasAccessors).new()
    dbl_ha.string_normal_accessors = 'foo'
    dbl_ha.string_accessor_method = 'bar'
    assert_eq(dbl_ha.string_normal_accessors, 'foo')
    assert_eq(dbl_ha.string_accessor_method, 'bar')

func test_print_methods():
    var ha = HasAccessors.new()
    _utils.pp(ha.get_method_list())
    _utils.pp(ha.get_property_list())