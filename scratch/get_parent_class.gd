extends SceneTree

const INNER_CLASSES_PATH = 'res://test/resources/doubler_test_objects/inner_classes.gd'
var InnerClasses = load(INNER_CLASSES_PATH)



func test_someting():
    var ic = InnerClasses.new()
    var ic_ia = InnerClasses.InnerA.new()

    var dict = {}
    dict[InnerClasses.InnerA] = 'poop'
    dict[InnerClasses] = 'foobar'
    dict[InnerClasses.AnotherInnerA] = 'bar -> foo'

    print(ic_ia, ' is InnerClasses ', ic_ia is InnerClasses)
    print(ic_ia.get_class())
    print(ic_ia.get_script())
    print(dict[ic_ia.get_script()])


func _init():
    print(InnerClasses)
    print(InnerClasses.InnerA)
    test_someting()
    quit();