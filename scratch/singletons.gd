extends SceneTree

var ObjectInspector = load("res://scratch/object_inspector.gd")

func _init() -> void:
    var oi = ObjectInspector.new()
    oi.print_method_signatures(Time)
    quit()

