extends Node2D


onready var health = $Health setget set_health, get_health


func _on_Health_zero_hp() -> void:
	burst()


func set_health(node: Node) -> void:
	if health != null:
		health.queue_free()
	health = node


func get_health() -> Node:
	return health


func take_damage(amount: int) -> void:
	if amount < 0:
		amount = 0
	health.set_current_hp(health.get_current_hp() - amount)


func heal(amount: int) -> void:
	if amount < 0:
		amount = 0
	health.set_current_hp(health.get_current_hp() + amount)


func burst() -> void:
	queue_free()
