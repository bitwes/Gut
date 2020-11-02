extends Node


export(int) var field = 0
export(int) var field_with_setter_getter = 0 setget set_field_with_setter_getter, get_field_with_setter_getter
var field_with_setter = "" setget set_field_with_setter


func set_field_with_setter(value: String) -> void:
	field_with_setter = value.strip_escapes()


func set_field_with_setter_getter(value: int) -> void:
	field_with_setter_getter = clamp(value, 0, field)


func get_field_with_setter_getter() -> int:
	return field_with_setter_getter

func set_field(value: int) -> void:
	if value < 0:
		value = 0
	field = value


func get_field() -> int:
	return field
