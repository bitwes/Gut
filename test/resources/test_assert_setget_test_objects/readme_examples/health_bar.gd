extends Control

const Health = preload("res://test/resources/test_assert_setget_test_objects/health.gd")
var health: Health = null setget set_health

onready var progress_bar = $ProgressBar
onready var label = $Label


func set_health(node: Health) -> void:
	health = node


func update() -> void:
	if health != null:
		label.text = "%s / %s" %[health.current_hp, health.max_hp]
		progress_bar.max_value = health.max_hp
		progress_bar.value = health.current_hp
