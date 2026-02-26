extends Node

var Vnt = load("res://addons/gut/version_numbers.gd").VerNumTools


const REMOTE_FILE_URL = "https://api.github.com/repos/bitwes/gut/contents/addons/gut/versions.json?ref=update_detection"
const LOCAL_FILE_PATH = "res://addons/gut/versions.json"
const REMOTE_FILE_PATH = "user://gut_temp_directory/versions.json"


var _http_request : HTTPRequest


var data_issues = []
var parsed_data = {}


signal download_completed()


func _ready() -> void:
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.timeout = 3.0
	_http_request.request_completed.connect(self._http_request_completed)


func _write_remote_file(data):
	GutUtils.write_file(REMOTE_FILE_PATH, JSON.stringify(data))


#------------
# Events
#------------
# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var body_text = body.get_string_from_utf8()
	# print("---------\n", result, "\n--\n", response_code, "\n--\n", headers, "\n--\n", body_text, "\n----------")

	var json = JSON.new()
	json.parse(body_text)
	var response = json.get_data()

	if(response_code == 200):
		_write_remote_file(response)
		parse_version_data(response)
	else:
		var msg = ''
		if(response != null and response.has('message')):
			msg = response.message
		push_error("Response code:  ", response_code, " (", msg, ")")

	download_completed.emit()


#------------
# Public
#------------
func parse_version_data(data):
	data_issues.clear()
	parsed_data = {}
	if(typeof(data) == TYPE_STRING):
		parsed_data = JSON.parse_string(data)
	elif(typeof(data) == TYPE_DICTIONARY):
		parsed_data = data

	if(parsed_data.has('releases')):
		for key in parsed_data.releases:
			var entry = parsed_data.releases[key]
			if(!entry.has('godot_min')):
				data_issues.append(str(key, ' missing godot_min'))
			if(!entry.has('godot_max')):
				data_issues.append(str(key, ' missing godot_max'))
	else:
		data_issues.append('missing releases entry')

	if(parsed_data.has('branches')):
		for key in parsed_data.branches:
			var entry = parsed_data.branches[key]
			if(!entry.has('godot_min')):
				data_issues.append(str(key, ' missing godot_min'))
			if(!entry.has('godot_max')):
				data_issues.append(str(key, ' missing godot_max'))
	else:
		data_issues.append('missing branches entry')


func parse_file(path):
	var text = GutUtils.get_file_as_text(path)
	parse_version_data(text)


func fetch_remote_file():
	# Perform a GET request. The URL below returns JSON as of writing.
	var headers : PackedStringArray = [
		"Accept: application/vnd.github.raw",
		"X-GitHub-Api-Version: 2022-11-28"
	]
	var error = _http_request.request(REMOTE_FILE_URL, headers)
	if error != OK:
		push_error("An error occurred requesting version data:  ", error, ".")
	return error


func get_gut_version_for_godot_version(godot_v):
	var to_return = "0.0.0"

	for key in parsed_data.releases:
		var entry = parsed_data.releases[key]
		if(Vnt.is_version_gte(godot_v, entry.godot_min) and Vnt.is_version_lte(godot_v, entry.godot_max)):
			return key
			to_return = key

	if(to_return == "0.0.0" and parsed_data.has('branches')):
		for key in parsed_data.branches:
			var entry = parsed_data.branches[key]
			if(Vnt.is_version_gte(godot_v, entry.godot_min) and Vnt.is_version_lte(godot_v, entry.godot_max)):
				return key
				to_return = key

	return to_return


func is_gut_version_valid(gut_v, godot_v):
	if(parsed_data.releases.has(gut_v)):
		var entry = parsed_data.releases[gut_v]
		return Vnt.is_version_gte(godot_v, entry.godot_min) and Vnt.is_version_lte(godot_v, entry.godot_max)
	else:
		return false


func check_for_update(force=false):
	if(FileAccess.file_exists(REMOTE_FILE_PATH)):
		parse_file(REMOTE_FILE_PATH)
	else:
		parse_file(LOCAL_FILE_PATH)

	"""
	* if parsed data is empty
		* if remote file dne, download it
		* parse remote file
		* If it's been long enough, or force is true, download remote file again
			* parse that file

	* return true if recommended version does not equal current, false if they
	  are the same
	"""
