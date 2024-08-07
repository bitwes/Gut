extends RigidBody2D

@onready var sprite = $Sprite2D

func _on_mouse_entered():
	sprite.modulate = Color(2, 2, 2)


func _on_mouse_exited():
	sprite.modulate = Color(1, 1, 1)
