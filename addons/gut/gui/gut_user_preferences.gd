class_name GutUserPreferences

static var gut_pref_prefix = 'gut/'


class GutEditorPref:
	var pname = '__not_set__'
	var default = null
	var value = '__not_set__'
	var _settings = null

	func _init(n, d, s):
		pname = n
		default = d
		_settings = s
		load_it()

	func _prefstr():
		return str(GutUserPreferences.gut_pref_prefix + pname)

	func save_it():
		_settings.set_setting(_prefstr(), value)

	func load_it():
		if(_settings.has_setting(_prefstr())):
			value = _settings.get_setting(_prefstr())
		else:
			value = default



# ------------------------------------------------------------------
var font_name = null
var font_size = null
var output_font_name = null
var output_font_size = null
var hide_result_tree = null
var hide_output_text = null
var hide_settings = null
var use_colors = null


func _init(editor_settings):
	font_name = GutEditorPref.new('font_name', 'CourierPrime', editor_settings)
	font_size = GutEditorPref.new('font_size', 16, editor_settings)
	output_font_name = GutEditorPref.new('output_font_name', 'CourierPrime', editor_settings)
	output_font_size = GutEditorPref.new('output_font_size', 30, editor_settings)
	hide_result_tree = GutEditorPref.new('hide_result_tree', false, editor_settings)
	hide_output_text = GutEditorPref.new('hide_output_text', false, editor_settings)
	hide_settings = GutEditorPref.new('hide_settings', false, editor_settings)
	use_colors = GutEditorPref.new('use_colors', true, editor_settings)


func save_it():
	for prop in get_property_list():
		var val = get(prop.name)
		if(val is GutEditorPref):
			val.save_it()

func load_it():
	for prop in get_property_list():
		var val = get(prop.name)
		if(val is GutEditorPref):
			val.load_it()



# @export var shortcuts = {
#     run_all = null,
# 	run_current_script = null,
# 	run_current_inner = null,
# 	run_current_test = null,
# 	panel_button = null,
# }
