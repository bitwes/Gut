@tool
extends AcceptDialog

static var _update_check_count = 0

var GutEditorGlobals = load('res://addons/gut/gui/editor_globals.gd')
var update_detector = null

var _bbcode = \
"""
[center]GUT {gut_version}[/center]
[center]{version_info}[/center]


[center][b]GUT Links[/b]
{gut_link_table}[/center]

[center][b]VSCode Extension Links[/b]
{vscode_link_table}[/center]

[center]You can support GUT development at
{donate_link}

Thanks for using GUT!
[/center]
"""

var _gut_links = [
	[&"Documentation", &"https://gut.readthedocs.io"],
	[&"What's New", &"https://github.com/bitwes/Gut/releases/tag/v{gut_version}"],
	[&"Repo", &"https://github.com/bitwes/gut"],
	[&"Report Bugs", &"https://github.com/bitwes/gut/issues"]
]

var _vscode_links = [
	["Repo", "https://github.com/bitwes/gut-extension"],
	["Market Place", "https://marketplace.visualstudio.com/items?itemName=bitwes.gut-extension"]
]

var _donate_link = "https://buymeacoffee.com/bitwes"
var _update_button = null
@onready var _logo = $Logo
@onready var rtl = $HBox/Scroll/RichTextLabel


func _ready():
	if(get_parent() is SubViewport):
		return

	_update_button = add_button("Check for update")
	_update_button.pressed.connect(_on_update_button_pressed)

	update_detector = GutUtils.UpdateDetector.new()
	add_child(update_detector)
	update_detector.updated.connect(_on_update_detector_updated)
	update_detector.check_for_update()
	# update_detector.check_for_update_with_fetch()

	_vert_center_logo()
	_logo.disabled = true
	rtl.text = _make_text()

	_enable_check_for_update_button(true)


func _color_link(link_text):
	return str("[color=ROYAL_BLUE]", link_text, "[/color]")


func _link_table(entries):
	var text = ''
	for entry in entries:
		text += str("[cell][right]", entry[0], "[/right][/cell]")
		var link = str("[url]", entry[1], "[/url]")
		if(entry[1].length() > 60):
			link = str("[url=", entry[1], "]", entry[1].substr(0, 50), "...[/url]")

		text += str("[cell][left]", _color_link(link), "[/left][/cell]\n")
	return str('[table=2]', text, '[/table]')


func url_bbcode(url, link_text=null):
	if(link_text == null):
		link_text = url
	var text = str("[url=", url, "]", link_text, "[/url]")
	return _color_link(text)



func _version_info():
	return update_detector.get_update_string(url_bbcode)


func _make_text():
	var gut_link_table = _link_table(_gut_links)
	var vscode_link_table = _link_table(_vscode_links)
	var gutv = GutUtils.version_numbers.gut_version
	var version_info = _version_info()

	var text = _bbcode.format({
		"gut_link_table":gut_link_table,
		"vscode_link_table":vscode_link_table,
		"donate_link":_color_link(str('[url]', _donate_link, '[/url]')),
		"gut_version":gutv,
		"version_info":version_info,
	})
	return text


func _vert_center_logo():
	_logo.position.y = size.y / 2.0


func _enable_check_for_update_button(should):
	if(should):
		if(_update_check_count >= 2):
			_update_button.text = "That's enough of that for now"
			_update_button.disabled = true
		else:
			_update_button.text = "Check for Update"
			_update_button.disabled = false
	else:
		_update_button.text = "Checking..."
		_update_button.disabled = true



# -----------
# Events
# -----------
func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_mouse_entered() -> void:
	pass#_logo.active = true


func _on_mouse_exited() -> void:
	pass#_logo.active = false


var _odd_ball_eyes_l = 1.1
var _odd_ball_eyes_r = .7
func _on_rich_text_label_meta_hover_started(meta: Variant) -> void:
	if(meta == _gut_links[0][1]):
		_logo.set_eye_color(Color.RED)
	elif(meta.find("releases/tag/") > 0):
		_logo.set_eye_color(Color.GREEN)
	elif(meta == _gut_links[2][1]):
		_logo.set_eye_color(Color.PURPLE)
	elif(meta == _gut_links[3][1]):
		_logo.set_eye_scale(1.2)
	elif(meta == _vscode_links[0][1]):
		_logo.set_eye_scale(.5, .5)
	elif(meta == _vscode_links[1][1]):
		_logo.set_eye_scale(_odd_ball_eyes_l, _odd_ball_eyes_r)
		var temp = _odd_ball_eyes_l
		_odd_ball_eyes_l = _odd_ball_eyes_r
		_odd_ball_eyes_r = temp
	elif(meta == _donate_link):
		_logo.active = false


func _on_rich_text_label_meta_hover_ended(meta: Variant) -> void:
	if(meta == _donate_link):
		_logo.active = true


func _on_logo_pressed() -> void:
	_logo.disabled = !_logo.disabled


func _on_update_button_pressed():
	_update_check_count += 1
	_enable_check_for_update_button(false)
	update_detector.check_for_update_with_fetch(true)


func _on_update_detector_updated():
	_enable_check_for_update_button(true)
	rtl.text = _make_text()
