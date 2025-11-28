extends GutInternalTester

func should_skip_script():
	return EngineDebugger.is_active()

func test_can_make_one():
	var gf = GutUtils.GutFonts.new()
	assert_not_null(gf)


func test_can_get_regular_font():
	var gf = GutUtils.GutFonts.new()
	var f = gf.get_font("AnonymousPro", gf.FONT_TYPES.REGULAR)
	assert_not_null(f)


func test_all_custom_fonts_are_populated():
	var gf = GutUtils.GutFonts.new()
	for font_name in gf.fonts:
		for font_type in gf.FONT_TYPES:
			var type_name = gf.FONT_TYPES[font_type]
			var f = gf.get_font(font_name, type_name)
			assert_not_null(f, str(font_name, ':', type_name))


func test_default_font_returned_for_invalid_font_name():
	var gf = GutUtils.GutFonts.new()
	var default = gf.get_font("Default")
	var bad_font = gf.get_font('_bad_')
	assert_eq(bad_font, default)
	assert_push_error("Invalid font name '_bad_'")


func test_default_font_returned_for_invalid_font_type():
	var gf = GutUtils.GutFonts.new()
	var default = gf.get_font("Default")
	var bad_font = gf.get_font('AnonymousPro', '_bad_')
	assert_eq(bad_font, default)
	assert_push_error("Invalid font type '_bad_'")


func test_when_file_does_not_exist_default_is_returned():
	var gf = GutUtils.GutFonts.new()
	gf.custom_font_path = "res://folder_does_not_exist/"
	var default = gf.get_font("Default")
	var bad_font = gf.get_font('AnonymousPro')
	assert_eq(bad_font, default)
	assert_push_error("Missing custom font")


var font_mappings = ParameterFactory.named_parameters(
	['theme_font_name', 'custom_font_type'],
	[
		['font', GutUtils.GutFonts.FONT_TYPES.REGULAR],
		['normal_font', GutUtils.GutFonts.FONT_TYPES.REGULAR],
		['bold_font', GutUtils.GutFonts.FONT_TYPES.BOLD],
		['italics_font', GutUtils.GutFonts.FONT_TYPES.ITALIC],
		['bold_italics_font', GutUtils.GutFonts.FONT_TYPES.BOLD_ITALIC]
	]
)
func test_get_font_for_theme_font_name_maps_fonts_correctly(p = use_parameters(font_mappings)):
	var gf = GutUtils.GutFonts.new()
	var expected = gf.get_font('AnonymousPro', p.custom_font_type)
	var got = gf.get_font_for_theme_font_name(p.theme_font_name, 'AnonymousPro')
	assert_eq(got, expected, str(p.theme_font_name, ' == ', p.custom_font_type))


func test_get_font_for_theme_returns_regular_for_custom_font_when_theme_font_name_is_unknown():
	var gf = GutUtils.GutFonts.new()
	var default = gf.get_font('AnonymousPro', gf.FONT_TYPES.REGULAR)
	var got = gf.get_font_for_theme_font_name('this_is_not_valid', 'AnonymousPro')
	assert_eq(got, default)
	assert_push_error('Unknown theme font name ')


func test_get_font_for_theme_returns_default_when_theme_font_and_custom_font_are_unknown():
	var gf = GutUtils.GutFonts.new()
	var default = gf.get_font('Default')
	var got = gf.get_font_for_theme_font_name('this_is_not_valid', 'ThisIsInvalid')
	assert_eq(got, default)
	assert_push_error('Unknown theme font name ')
	assert_push_error('Invalid font name', 'second error because custom does not exist')
