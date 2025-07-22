extends Logger
class_name GutErrorTracker

const NO_TEST := 'NONE'
const GUT_ERROR_TYPE = 999

enum TREAT_AS {
	NOTHING,
	FAILURE,
}


class TrackedError:
	var backtrace = []
	# appears to be the description
	var code = NO_TEST
	# I don't know what this is.
	var rationale = NO_TEST
	# Logger.ErrorType enum value, maybe 999 becomes a gut error?
	var error_type = -1
	# Unknown
	var editor_notify = false

	var file = NO_TEST
	var function = NO_TEST
	var line = -1


	func to_s() -> String:
		return str("CODE:", code, " TYPE:", error_type, " RATIONALE:", rationale, "\n",
			file, '->', function, '@', line, "\n",
			backtrace, "\n")


	func is_push_error():
		return error_type != GUT_ERROR_TYPE and function == "push_error"


	func is_engine_error():
		return error_type != GUT_ERROR_TYPE


	func is_gut_error():
		return error_type == GUT_ERROR_TYPE


	# this might not work in other languages, and is flakey at best.
	# func is_assert():
	# 	return error_type == Logger.ERROR_TYPE_SCRIPT and \
	# 		(code.find("Assertion failed.") == 0 or \
	# 			code.find("Assertion failed:") == 0)




# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
var _current_test_id = NO_TEST
var _mutex = Mutex.new()

var errors = GutUtils.OneToMany.new()

var treat_gut_errors_as : TREAT_AS = TREAT_AS.NOTHING
var treat_engine_errors_as : TREAT_AS = TREAT_AS.NOTHING
var treat_push_error_as : TREAT_AS = TREAT_AS.NOTHING


func _get_stack_data(current_test_name):
	var test_entry = {}
	var stackTrace = get_stack()

	if(stackTrace!=null):
		var index = 0
		while(index < stackTrace.size() and test_entry == {}):
			var line = stackTrace[index]
			var function = line.get("function")
			if function == current_test_name:
				test_entry = stackTrace[index]
			else:
				index += 1

		for i in range(index):
			stackTrace.remove_at(0)

	return {
		"test_entry" = test_entry,
		"full_stack" = stackTrace
	}


func _is_error_failable(error : TrackedError):
	var is_it = false
	if(error.is_gut_error()):
		if(treat_gut_errors_as == TREAT_AS.FAILURE):
			is_it = true
	elif(error.is_push_error()):
		if(treat_push_error_as == TREAT_AS.FAILURE):
			is_it = true
	elif(error.is_engine_error()):
		if(treat_engine_errors_as == TREAT_AS.FAILURE):
			is_it = true
	return is_it


# Godot's Logger virtual method for errors
func _log_error(function: String, file: String, line: int,
	code: String, rationale: String, editor_notify: bool,
	error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:

		add_error(function, file, line,
			code, rationale, editor_notify,
			error_type, script_backtraces)

# Godot's Logger virtual method for any output?
# func _log_message(message: String, error: bool) -> void:
# 	pass


func start_test(test_id):
	_current_test_id = test_id


func end_test():
	_current_test_id = NO_TEST


func did_test_error(test_id=_current_test_id):
	return errors.size(test_id) > 0


# This should look through all the errors for a test and see if a failure
# should happen based off of flags.
func should_test_fail_from_errors(test_id = _current_test_id):
	var to_return = false
	if(errors.items.has(test_id)):
		var errs = errors.items[test_id]
		var index = 0
		while(index < errs.size() and !to_return):
			var error = errs[index]
			to_return = _is_error_failable(error)
			index += 1
	return to_return


# Returns emtpy string or text for errors that occurred during the test that
# should cause failure based on this class' flags.
func get_fail_text_for_errors(test_id=_current_test_id) -> String:
	var error_texts = []

	if(errors.items.has(test_id)):
		for error in errors.items[test_id]:
			if(_is_error_failable(error)):
				error_texts.append(error.code)

	var to_return = ""
	for i in error_texts.size():
		if(to_return != ""):
			to_return += "\n"
		to_return += str("[", i + 1, "] ", error_texts[i])

	return to_return


func add_gut_error(text) -> TrackedError:
	if(_current_test_id != NO_TEST):
		var data = _get_stack_data(_current_test_id)
		if(data.test_entry != {}):
			return add_error(_current_test_id, data.test_entry.source, data.test_entry.line,
				text, '', false,
				GUT_ERROR_TYPE, data.full_stack)

	return add_error(_current_test_id, "unknown", -1,
		text, '', false,
		GUT_ERROR_TYPE, get_stack())


func add_error(function: String, file: String, line: int,
	code: String, rationale: String, editor_notify: bool,
	error_type: int, script_backtraces: Array) -> TrackedError:

		_mutex.lock()

		var err := TrackedError.new()

		err.backtrace = script_backtraces
		err.code = code
		err.rationale = rationale
		err.error_type = error_type
		err.editor_notify = editor_notify

		err.file = file
		err.function = function
		err.line = line

		errors.add(_current_test_id, err)

		_mutex.unlock()

		return err
