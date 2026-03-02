extends Control

var update_detector = null
@onready var rtl = $ScrollContainer/Output
var _log_entries = []
var _verbose = false
var _mouse_down_duration = 0.0
var _mouse_down = false


func _ready():
	update_detector = GutUtils.UpdateDetector.new()
	add_child(update_detector)
	update_detector.updated.connect(_on_update_detector_updated)
	update_detector.download_completed.connect(_on_update_detector_download)
	
	_check_for_update(false, false)
	_populate_text()


func _process(delta: float) -> void:
	if(_mouse_down_duration < 2.0 and _mouse_down):
		_mouse_down_duration += delta
		if(_mouse_down_duration >= 2.0):
			_verbose = true
			rtl.append_text("\nVERBOSE ENABLED\n")


# ----------------
# Private
# ----------------

func _log(text):
	if(_verbose):
		_log_entries.append(str(text))


func _log_file(path):
	if(_verbose):
		var file_text = FileAccess.get_file_as_string(path)
		if(file_text == ""):
			file_text = "--Missing or empty file--"
		_log(str(path, ":\n[code]", file_text, "[/code]"))


func _get_check_for_update_link():
	return _url_bbcode("_check_for_update", "Check for Update", "ORANGE")


func _check_for_update(use_fetch, force=false):
	_log_entries.clear()
	rtl.text = ""
	if(use_fetch):
		rtl.text = "Checking..."
		_log("fetching remote file " + update_detector.REMOTE_FILE_URL)
		update_detector.check_for_update_with_fetch(force)
	else:
		_log("local check")
		update_detector.check_for_update()


func _populate_text():
	var txt = ""
	if(update_detector.parsed_data != {}):
		txt = update_detector.get_update_string(_url_bbcode)
	if(_verbose):
		txt = txt + "\n\n" + "\n".join(_log_entries)
	rtl.text = txt + "\n" + _get_check_for_update_link()


func _url_bbcode(url, link_text=null, color_name="ROYAL_BLUE"):
	if(link_text == null):
		link_text = url
	var text = str("[url=", url, "]", link_text, "[/url]")
	return str("[color=", color_name, "]", text, "[/color]")


# -----------------
# Events
# -----------------
func _on_update_detector_updated():
	_log_file(update_detector.REMOTE_FILE_PATH)
	_log_file(update_detector.LOCAL_FILE_PATH)
	_log(str("parsed:\n[code]", JSON.stringify(update_detector.parsed_data, "  "), "[/code]"))
	_log(str("Issues:\n", update_detector.data_issues))
	_log(update_detector.get_summary_string())
	_populate_text()


func _on_btn_check_button_up() -> void:
	_check_for_update(true, true)
	
	
func _on_update_detector_download():
	_log("Download completed")


func _on_output_meta_clicked(meta: Variant) -> void:
	if(meta == "_check_for_update"):
		_check_for_update(true, true)
	else:
		OS.shell_open(str(meta))


func _on_output_gui_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		if(event.pressed):
			_mouse_down = true
		else:
			_mouse_down = false
			_mouse_down_duration
