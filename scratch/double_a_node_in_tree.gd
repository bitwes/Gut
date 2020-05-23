extends SceneTree


var _utils = load('res://addons/gut/utils.gd').get_instance()

class TestNode2D:
    extends Node2D

    var value = 1

    func print_something():
        print('something')


func _on_entered_tree():
    print('hello world')

func make_node():
    var field = TestNode2D.new()
    var player1 = TestNode2D.new()
    var sword = TestNode2D.new()

    get_root().add_child(field)
    field.set_name('Field')

    field.add_child(player1)
    player1.set_name('Player1')
    player1.add_child(sword)
    sword.set_name('Sword')

    sword.connect('tree_entered', self, '_on_entered_tree')

    return field


func get_sword():
    return get_root().get_node('Field/Player1/Sword')


func replace_node(parent_node, path, with_this):
    var to_replace_parent = parent_node.get_node(path).get_parent()
    var to_replace = parent_node.get_node(path)
    var replace_name = to_replace.get_name()

    to_replace_parent.remove_child(to_replace)
    to_replace_parent.add_child(with_this)
    with_this.set_name(replace_name)
    with_this.set_owner(to_replace_parent)

    to_replace.queue_free()


func _init():
    var node = make_node()
    var sword = get_sword()

    print(sword.get_incoming_connections())
    print(get_incoming_connections())
    var other_sword = TestNode2D.new()

    replace_node(get_root(), 'Field/Player1/Sword', other_sword)


    if(other_sword == get_sword()):
        print('we did it')
    else:
        print('not quite yet')

    node.free()

    quit()
