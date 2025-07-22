extends Logger
class_name GutErrorTracker

class GodotError:
	var backtrace = []
	# appears to be the description
	var code = "none"
	# I don't know what this is.
	var rationale = "none"
	# Logger.ErrorType enum value, maybe 999 becomes a gut error?
	var error_type = -1
	# Unknown
	var editor_notify = false

	var file = "none"
	var function = "none"
	var line = -1


	func _to_string() -> String:
		return str("CODE:", code, " TYPE:", error_type, " RATIONALE:", rationale, "\n",
			file, '->', function, '@', line, "\n",
			backtrace, "\n")


	func is_push_error():
		return false


	func is_assert():
		return false


	func is_engine_error():
		return false


	func is_gut_error():
		return false



# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
enum GUT_ERRORS_CAUSE {
	NOTHING,
	FAILURE,
	RISKY
}

var _current_test_id = "no_test"
var _error_count = 0
var _mutex = Mutex.new()

var gut = null
var logger = GutUtils.get_logger()
var test_errors = GutUtils.OneToMany.new()
var treat_errors_as : GUT_ERRORS_CAUSE = GUT_ERRORS_CAUSE.NOTHING
var treat_asserts_as : GUT_ERRORS_CAUSE = GUT_ERRORS_CAUSE.NOTHING


func start_test(test_id):
	_current_test_id = test_id


func end_test():
	_current_test_id = "none"


func did_test_error(test_id=_current_test_id):
	return test_errors.size(test_id) > 0


# This should look through all the errors for a test and see if a failure
# should happen based off of flags.
func should_test_fail_from_error(test_id = _current_test_id):
	return false


# Returns null or a string for errors that occurred during the test that should
# cause failure based on this class' flags.
func get_fail_text_for_errors(test_id=_current_test_id):
	return null



func add_error(function: String, file: String, line: int,
	code: String, rationale: String, editor_notify: bool,
	error_type: int, script_backtraces: Array) -> void:

		_mutex.lock()

		_error_count += 1
		var err = GodotError.new()

		err.backtrace = script_backtraces
		err.code = code
		err.rationale = rationale
		err.error_type = error_type
		err.editor_notify = editor_notify

		err.file = file
		err.function = function
		err.line = line

		test_errors.add(_current_test_id, err)

		_mutex.unlock()


# Godot's Logger virtual method for errors
func _log_error(function: String, file: String, line: int,
	code: String, rationale: String, editor_notify: bool,
	error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:

		add_error(function, file, line,
			code, rationale, editor_notify,
			error_type, script_backtraces)

# func _log_message(message: String, error: bool) -> void:
# 	pass
