extends Node
## -----------------------------------------------------------------------------
## Checks to see if there is a better version of GUT available for a version of
## Godot.  The data used to validate the GUT version includes lower and upper
## Godot versions
##
## There are 3 places where version information is located.
##	* LOCAL_FILE_PATH:  This is the version information that is packed with this
##	  release of GUT.  It serves as a fallback if remote data is not available.
##	  This is most useful in detecting that GUT is being used with an earlier
##	  release of Godot and remote data is not available.
##	* REMOTE_FILE_URL:  This is where the the version information exists outside
##	  of the local copy of GUT.  This data will be downlaoded to REMOTE_FILE_PATH
##	  whenever remote data is fetched.
##	* REMOTE_FILE_PATH: This is where REMOTE_FILE_URL is downloaded to.  When
##	  the file is downloaded, timetamp information is added to the data so that
##	  we can avoid downloading the file too often.  This file is used whenever
##	  it exists.  If it does not exist and we don't fetch it, LOCAL_FILE_PATH
##	  will be used.
##
## REMOTE_FILE_URL Location
## Currently this file points to a file on the main branch.  This is the same
## file that will be shipped with each version of GUT.  This allows the file to
## be updated and still be shipped with each version of GUT.
## -----------------------------------------------------------------------------
var Vnt = load("res://addons/gut/version_numbers.gd").VerNumTools


const REMOTE_FILE_URL = "https://api.github.com/repos/bitwes/gut/contents/addons/gut/versions.json"
const LOCAL_FILE_PATH = "res://addons/gut/versions.json"
const REMOTE_FILE_PATH = "user://gut_temp_directory/versions.json"


var _http_request : HTTPRequest


var data_issues = []
var parsed_data = {}
var min_fetch_wait = 60 * 60 # 1 hour

signal download_completed()
signal updated()


func _ready() -> void:
	_setup_http_request(HTTPRequest.new())


func _setup_http_request(request):
	_http_request = request
	add_child(_http_request)
	_http_request.timeout = 3.0
	_http_request.request_completed.connect(self._http_request_completed)


func _write_remote_file(data):
	data.fetch_timestamp = Time.get_unix_time_from_system()
	GutUtils.write_file(REMOTE_FILE_PATH, JSON.stringify(data))


func _url_formatter(url, link_text=null):
	if(link_text == null):
		return url
	else:
		return str(link_text, ':  ', url)


#------------
# Events
#------------
# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var body_text = body.get_string_from_utf8()

	if(response_code == 200):
		var json = JSON.new()
		var err = json.parse(body_text)
		if(err != OK):
			push_error("[GUT] Invalid JSON: ", json.get_error_message(), '.  ', body_text)
			download_completed.emit()
			return
		var response = json.get_data()

		parse_version_data(response)
		if(data_issues.size() == 0):
			_write_remote_file(response.duplicate(true))
		else:
			push_error("[GUT] Invalid version data:  ", data_issues)
			parsed_data = {}
			data_issues.clear()
	else:
		var json = JSON.new()
		var err = json.parse(body_text)
		var response = {}
		if(err == OK):
			response = json.get_data()

		var msg = ''
		if(response != null and response.has('message')):
			msg = str(" (", response.message, ")")
		push_error("[GUT] Could not get version info, response code:  ", response_code, msg)

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


func parse_file(path):
	if(FileAccess.file_exists(path)):
		var text = GutUtils.get_file_as_text(path)
		parse_version_data(text)
	else:
		parsed_data = {}


func fetch_remote_file():
	var headers : PackedStringArray = [
		"Accept: application/vnd.github.raw",
		"X-GitHub-Api-Version: 2022-11-28"
	]
	var error = _http_request.request(REMOTE_FILE_URL, headers)
	if error != OK:
		var errtxt = str("[GUT] An error occurred requesting version data:  ", error, ".")
		data_issues.append(errtxt)
		push_error(errtxt)
	return error


func get_gut_version_for_godot_version(godot_v=null):
	var to_return = "0.0.0"
	if(godot_v == null):
		godot_v = GutUtils.version_numbers.make_godot_version_string()

	for key in parsed_data.releases:
		var entry = parsed_data.releases[key]
		if(Vnt.is_version_gte(godot_v, entry.godot_min) and Vnt.is_version_lte(godot_v, entry.godot_max)):
			if(Vnt.is_version_gte(key, to_return)):
				to_return = key

	if(to_return == "0.0.0" and parsed_data.has('branches')):
		for key in parsed_data.branches:
			var entry = parsed_data.branches[key]
			if(Vnt.is_version_gte(godot_v, entry.godot_min) and Vnt.is_version_lte(godot_v, entry.godot_max)):
				to_return = key

	return to_return


func is_gut_version_valid(gut_v =null, godot_v=null):
	if(gut_v == null):
		gut_v =  GutUtils.version_numbers.gut_version
		godot_v =  GutUtils.version_numbers.make_godot_version_string()

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


func check_for_update():
	if(FileAccess.file_exists(REMOTE_FILE_PATH)):
		parse_file(REMOTE_FILE_PATH)
	else:
		parse_file(LOCAL_FILE_PATH)

	updated.emit.call_deferred()


func check_for_update_with_fetch(force=false):
	parse_file(REMOTE_FILE_PATH)
	var time_since_last_fetch = 60 * 60 * 24 * 10_000 # ten thousand days

	if(parsed_data.has("fetch_timestamp")):
		time_since_last_fetch = Time.get_unix_time_from_system() - parsed_data.fetch_timestamp

	if(force or time_since_last_fetch > min_fetch_wait):
		fetch_remote_file()
		await download_completed

	check_for_update()


func get_update_string(url_formatter:Callable=_url_formatter):
	var gut_v = GutUtils.version_numbers.gut_version
	var godot_v = GutUtils.godot_version_string()
	var version_info = str("GUT ", gut_v, " is the lastest version for Godot ", godot_v)

	var rec_ver = get_gut_version_for_godot_version(godot_v)
	var rec_ver_link = url_formatter.call(str("https://github.com/bitwes/Gut/releases/tag/v", rec_ver), str("GUT ",rec_ver))

	if(is_gut_version_valid(gut_v, godot_v)):
		if(rec_ver != gut_v):
			version_info = str(rec_ver_link, ' is now available!')
	else:
		if(rec_ver.find(".") == -1):
			version_info = str("GUT does not have a release for this version of Godot yet, but it does have ",
			"the branch '", rec_ver, "'.\n",
			"Check the readme for install links/instructions:  ", url_formatter.call('https://github.com/bitwes/Gut'))
		else:
			version_info = str('This version of GUT may not be compatible with Godot ', godot_v, '.  ')
			if(rec_ver == '0.0.0'):
				version_info += str("No release or branch exists for this version of Godot yet.  Check back soon.")
			else:
				version_info += str('Consider changing to ', rec_ver_link)

	if(rec_ver != gut_v and is_in_asset_library(rec_ver)):
		version_info += str("\nYou can update to ", rec_ver, " through the Asset Library.")
	return version_info


func get_summary_string():
	var gut_v = GutUtils.version_numbers.gut_version
	var godot_v = GutUtils.godot_version_string()

	return str("GUT:  ", gut_v, "\n",
		"Godot:  ", godot_v, "\n",
		"Valid:  ", is_gut_version_valid(gut_v, godot_v), "\n",
		"Latest:  ", get_gut_version_for_godot_version(godot_v))


func fetch_limit_wait_time():
	var remaining = -1
	if(parsed_data.has("fetch_timestamp")):
		var time_since_last_fetch = Time.get_unix_time_from_system() - parsed_data.fetch_timestamp
		return max(min_fetch_wait - time_since_last_fetch, 0.0)
	else:
		return -1


func get_days_since_last_fetch():
	var to_return = 99
	if(parsed_data.has("fetch_timestamp")):
		var time_since_last_fetch = Time.get_unix_time_from_system() - parsed_data.fetch_timestamp
		to_return = time_since_last_fetch / (60.0 * 60.0 * 24.0)
	return to_return
