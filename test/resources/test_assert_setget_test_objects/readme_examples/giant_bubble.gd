extends "res://test/resources/test_assert_setget_test_objects/bubble.gd"


func set_health(node: Node) -> void:
	.set_health(node)
	_add_random_bonus_hp()


func _add_random_bonus_hp() -> void:
	var bonus = randi() % 10
	health.max_hp += bonus
	heal(bonus)
