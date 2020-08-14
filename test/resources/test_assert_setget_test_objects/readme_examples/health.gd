extends Node


export(int) var max_hp = 0
export(int) var current_hp = 0 setget set_current_hp, get_current_hp


func set_max_hp(value: int) -> void:
	if value < 0:
		value = 0
	max_hp = value


func get_max_hp() -> int:
	return max_hp


func set_current_hp(value: int) -> void:
	current_hp = clamp(value, 0, max_hp)


func get_current_hp() -> int:
	return current_hp
