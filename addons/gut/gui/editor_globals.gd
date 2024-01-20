@tool
class_name GutEditorGlobals

# ----------------------------------------------------
# IDK if I like this get/set setup, but it seems a lot better than having to
# do path_join everywhere I use them.
# ----------------------------------------------------
static var temp_directory = 'user://gut_temp_directory'

# RUNNER_JSON_PATH
static var editor_run_gut_config_path = 'gut_editor_config.json':
	get: return temp_directory.path_join(editor_run_gut_config_path)

# RESULT_FILE
static var editor_run_bbcode_results_path = 'gut_editor.bbcode':
	get: return temp_directory.path_join(editor_run_bbcode_results_path)

# RESULT_JSON
static var editor_run_json_results_path = 'gut_editor.json':
	get: return temp_directory.path_join(editor_run_json_results_path)

static var _user_prefs = null
static var user_prefs = _user_prefs :
	get:
		if(_user_prefs == null and Engine.is_editor_hint()):
			_user_prefs = GutUserPreferences.new(EditorInterface.get_editor_settings())
		return _user_prefs

static func create_temp_directory():
	DirAccess.make_dir_recursive_absolute(temp_directory)
