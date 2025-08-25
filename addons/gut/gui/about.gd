@tool
extends AcceptDialog

var GutEditorGlobals = load('res://addons/gut/gui/editor_globals.gd')

var _bbcode = \
"""
[center]GUT {gut_version}[/center]

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
	[&"Issues", &"https://github.com/bitwes/gut/issues"]
]

var _vscode_links = [
	["Repo", "https://github.com/bitwes/gut-extension"],
	["Market Place", "https://marketplace.visualstudio.com/items?itemName=bitwes.gut-extension"]
]

var _donate_link = "https://buymeacoffee.com/bitwes"

@onready var _logo = $Logo

func _ready():
	if(get_parent() is SubViewport):
		return
	
	$HBox/Scroll/VBox/RichTextLabel.text = _make_text()#formatted


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
	

func _make_text():
	var gut_link_table = _link_table(_gut_links)
	var vscode_link_table = _link_table(_vscode_links)
	
	var text = _bbcode.format({
		"gut_link_table":gut_link_table,
		"vscode_link_table":vscode_link_table,
		"donate_link":_color_link(str('[url]', _donate_link, '[/url]')),
		"gut_version":GutUtils.version_numbers.gut_version,
	})
	return text


#var interface = null
#func _do_editor_themeing():
	#theme = interface.get_editor_theme()
	#var settings = interface.get_editor_settings()
	#$ColorRect.color = settings.get_setting("interface/theme/base_color")


# -----------
# Events
# -----------
func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_mouse_entered() -> void:
	_logo.active = true


func _on_mouse_exited() -> void:
	_logo.active = false


func _on_rich_text_label_meta_hover_started(meta: Variant) -> void:
	if(meta == _gut_links[0][1]):
		_logo.eye_color(Color.DARK_RED)
	elif(meta.find("releases/tag/") > 0):
		_logo.eye_color(Color.DARK_GREEN)
	elif(meta == _gut_links[2][1]):
		_logo.eye_color(Color.PURPLE)
	elif(meta == _gut_links[3][1]):
		_logo.eye_scale(1)
		_logo.eye_color(Color.ORANGE, Color.BLUE)
	elif(meta == _vscode_links[0][1]):
		_logo.eye_scale(.5, .5)
	elif(meta == _vscode_links[1][1]):
		_logo.eye_scale(1.1, .7)
	elif(meta == _donate_link):
		_logo.eye_scale(1.3, 1.3)
		_logo.eye_color(Color.BLACK)


func _on_rich_text_label_meta_hover_ended(_meta: Variant) -> void:
	pass
