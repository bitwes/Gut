extends SceneTree

var _utils = load('res://addons/gut/utils.gd').get_instance()
const INNER_CLASSES_PATH = 'res://test/resources/doubler_test_objects/inner_classes.gd'
var InnerClasses = load(INNER_CLASSES_PATH)


class BaseClass:
    var foo = 'bar'

class ILevelOne:
    extends BaseClass

class ILevelTwo:
    extends ILevelOne

var the_hash = make_class_db_hash()


func test_someting():
    var ic = InnerClasses.new()
    var ic_ia = InnerClasses.InnerA.new()

    var dict = {}
    dict[InnerClasses.InnerA] = 'poop'
    dict[InnerClasses] = 'foobar'
    dict[InnerClasses.AnotherInnerA] = 'bar -> foo'

    print(ic_ia, ' is InnerClasses ', is_instance_of(ic_ia, InnerClasses))
    print(ic_ia.get_class())
    print(ic_ia.get_script())
    print(dict[ic_ia.get_script()])


func print_stuff(thing):
    var s = thing.get_script()
    print(thing)
    print('  -', s)
    print('  -', s.get_instance_base_type())
    print('  -', s.get_base_script())
    print('  -', s.get_name())
    print('  -', s.resource_name)
    print('  -', s.get_rid())

    # print(thing.get_class())
    # print(thing.get_class().get_instance_base_type())

func find_top_of_inheritance(thing):
    var p = thing.get_script()
    var last_p = null
    while(p != null):
        last_p = p
        p = p.get_base_script()

    # last_p = ClassDB.get_class(last_p.get_class())

    print('top parent = ', last_p)
    print(the_hash[last_p.get_instance_base_type()])


func test_something_else():
    var b = BaseClass.new()
    var one = ILevelOne.new()
    var two = ILevelTwo.new()

    print_stuff(b)
    print_stuff(one)
    print_stuff(two)

    print('RefCounted = ', RefCounted)
    print('top should be ', BaseClass)
    find_top_of_inheritance(two)


func make_class_db_hash_text():
    var text = "var all_classes = {\n"
    var class_list = ClassDB.get_class_list()
    class_list.sort()
    for classname in class_list:
        if(ClassDB.can_instantiate(classname)):
            text += str('    "', classname, '": ', classname, ", \n")
        else:
            text += str('    # ', classname, "\n")
    text += "}"
    print(_utils.add_line_numbers(text))
    return text


func make_class_db_hash():
    var source = make_class_db_hash_text()
    return _utils.create_script_from_source(source).new().all_classes


func _init():
    # test_something_else()
    find_top_of_inheritance(Input)
    quit();