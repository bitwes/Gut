extends Logger

class GodotError:
	var index = 0
	var backtrace = []
	var code = "none"
	var rationale = "none"

	func _to_string() -> String:
		return str("[", index, "] ", code, ": ", rationale, "\n", backtrace)


var test_errors = GutUtils.OneToMany.new()
var _current_test_id = "none"
var _error_count = 0


func start_test(test_id):
	_current_test_id = test_id


func end_test():
	_current_test_id = "none"


func did_test_error(test_id):
	return test_errors.size(test_id) > 0


func _log_error(_function: String, _file: String, _line: int,
	code: String, rationale: String, _editor_notify: bool,
	_error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
		_error_count += 1
		var err = GodotError.new()
		err.index = _error_count
		err.backtrace = script_backtraces
		err.code = code
		err.rationale = rationale
		test_errors.add(_current_test_id, err)


# func _log_message(message: String, error: bool) -> void:
# 	pass
