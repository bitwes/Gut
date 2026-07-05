extends GutTest


# This test will fail when Godot removes non-public classes from
# ClassDB.get_class_list().  This fix is slated for 4.8, this issue was found in
# the first relase of 4.7.
#
# ClassDB.get_class_list() was used in utils.gd._create_class_dictionaries to
# create a list of classes by name and references to the class itself.  If this
# test is failing and you cannot find _create_class_dictionaries, then things
# have changed and you can remove this.  If it still exists then it is safe to
# do the following:
#	* Remove res://addons/gut/class_list.cfg
#	* Revert _create_class_dictionaries to the original implementation which I
#	  have put below.
#
# Related issues for this test:
#		https://github.com/godotengine/godot/issues/120370
#		https://github.com/godotengine/godot/pull/119936
#		https://github.com/bitwes/Gut/issues/841
func test_classdb_has_been_cleaned_up_so_we_can_remove_the_whitelist():
	# Issue originally found with IPUnix on Mac, another issue reported with
	# IPWindows.  This should cover things enough (FLW).
	var class_name_to_check = "IPUnix"
	if(OS.get_name() == "Windows"):
		class_name_to_check = "IPWindows"
	assert_true(ClassDB.class_exists(class_name_to_check))



# So...I couldn't figure out how to get to a reference for a GDNative Class
# using a string.  ClassDB has all thier names...so I made a hash using those
# names and the classes.  Then I dynmaically make a script that has that as
# the source and grab the hash out of it and return it.  Super Rube Golbergery,
# but tons of fun.
#
# This is lazy loaded into class_ref_by_name, it's only needed when finding
# stubs.
# static func _create_class_dictionaries():
# 	var text = "var all_the_classes: Dictionary = {\n"
# 	var black_list = [
# 		"IPUnix",
# 		"GodotNavigationServer2D",
# 		"NativeMenuMacOS",
# 	]
# 	for classname in ClassDB.get_class_list():
# 		if(!black_list.has(classname) and (ClassDB.can_instantiate(classname) or \
# 		 	GodotSingletons.names.has(classname))):
# 			text += str('"', classname, '": ', classname, ", \n")

# 	text += "}"
# 	var inst =  GutUtils.create_script_from_source(text, 'res://dynamically_generated/class_dictionary.gd').new()

# 	_class_ref_by_name = inst.all_the_classes
# 	for key in inst.all_the_classes:
# 		_class_ref_by_class[inst.all_the_classes[key]] = key