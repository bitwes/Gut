@tool
extends AcceptDialog

var update_detector = null
var should_continue = false

signal closed

func _ready():
	update_detector = $CheckForUpdate.update_detector
	add_cancel_button("Cancel Loading GUT")
	
	
func should_show():
	return update_detector.is_gut_version_valid()


func _on_confirmed() -> void:
	should_continue = true
	closed.emit.call_deferred()


func _on_canceled() -> void:
	should_continue = false
	closed.emit.call_deferred()


func _on_close_requested() -> void:
	should_continue = false
	closed.emit.call_deferred()
