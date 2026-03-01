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
	_setup_http_request(HTTPRequest.new())


func _setup_http_request(request):
	_http_request = request
	add_child(_http_request)
	_http_request.timeout = 3.0
	_http_request.request_completed.connect(self._http_request_completed)


func _write_remote_file(data):
	GutUtils.write_file(REMOTE_FILE_PATH, JSON.stringify(data))


func _url_formatter(url, link_text):
	return str(link_text, ':  ', url)


#------------
# Events
#------------
# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var body_text = body.get_string_from_utf8()
	# print("---------\n", result, "\n--\n", response_code, "\n--\n", headers, "\n--\n", body_text, "\n----------")

	var json = JSON.new()
	var err = json.parse(body_text)
	if(err != OK):
		push_error("Invalid JSON: ", json.get_error_message(), '.  ', body_text)
		download_completed.emit()
		return

	var response = json.get_data()

	if(response_code == 200):
		parse_version_data(response)
		if(data_issues.size() == 0):
			_write_remote_file(response)
		else:
			push_error("Invalid version data:  ", data_issues)
			parsed_data = {}
			data_issues.clear()
	else:
		var msg = ''
		if(response != null and response.has('message')):
			msg = response.message
		push_error("Could not get version info, response code:  ", response_code, " (", msg, ")")

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

	if(!parsed_data.has('asset_library')):
		data_issues.append("asset_library entry missing")

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

	# if(data_issues.size() > 0):
	# 	data_issues.append(str("the data:  ", data))


func parse_file(path):
	var text = GutUtils.get_file_as_text(path)
	parse_version_data(text)


func fetch_remote_file():
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


func is_in_asset_library(gut_v):
	if(parsed_data.has('asset_library')):
		return parsed_data.asset_library == gut_v
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


func check_for_update_with_fetch():
	fetch_remote_file()
	await download_completed
	check_for_update()


func get_update_string(url_formatter:Callable=_url_formatter):
	var gut_v = GutUtils.version_numbers.gut_version
	var godot_v = GutUtils.godot_version_string()
	var version_info = 'You are on the current version.'

	var rec_ver = get_gut_version_for_godot_version(godot_v)
	var rec_ver_link = url_formatter.call(str("https://github.com/bitwes/Gut/releases/tag/v", rec_ver), str("GUT ",rec_ver))

	if(is_gut_version_valid(gut_v, godot_v)):
		if(rec_ver != gut_v):
			version_info = str('Version ', rec_ver_link, ' is now available!')
	else:
		if(rec_ver.find(".") == -1):
			version_info = str("GUT does not have a release for this version of Godot yet, but it does have ",
			"the branch '", rec_ver, "'.\n",
			"Check the readme for install links/instructions:  ", url_formatter.call('https://github.com/bitwes/Gut', 'https://github.com/bitwes/Gut'))
		else:
			version_info = str(
				'This version of GUT may not be compatible with Godot ', godot_v,
				'.  Consider changing to ', rec_ver_link)

	if(rec_ver != gut_v and is_in_asset_library(rec_ver)):
		version_info += str("\nYou can update to ", rec_ver, " through the Asset Library.")
	return version_info
