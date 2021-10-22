extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var count = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ShortcutButton_changed():
	print('Shortcut changed to ', $ShortcutButton.to_s())
	$Button.shortcut = $ShortcutButton.get_shortcut()


func _on_Button_pressed():
	print('hello world ', count)
	count += 1
