extends SceneTree

var OptParse = load('res://addons/gut/cli/optparse.gd')

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class ScriptClassCacheUpdater:
	var _entries = {}
	var class_cache_path = './.godot/global_script_class_cache.cfg'
	var res_path = './'

	func _replace_res(replace_this):
		var path = replace_this.replace("res://", '')
		return res_path.path_join(path)


	func _get_second_word_on_line_that_starts_with_word(line, start_word, err_info):
		if(line.begins_with(start_word)):
			var parts = line.split("#", false)[0].split(" ", false)

			if(parts.size() != 2):
				push_error(str("Could not parse ", start_word, " from [", line, ']:  ', err_info))
				return null
			else:
				return parts[1]


	func _is_line_script_body_type_text(line):
		var l = line.strip_edges(true, false)
		# I decided that the first occurance of func or var (that wasn't part of
		# a comment) was a good enough way to assume we are in the body of a
		# script.
		var it_is = l != '' and !l.begins_with('#') and \
			(l.begins_with('func') or l.begins_with('var'))
		return it_is


	func _parse_file(any_path):
		var path = _replace_res(any_path)
		var f = FileAccess.open(path, FileAccess.READ)
		if(f == null):
			push_error('Could not open file ', path, ':  ', FileAccess.get_open_error())
			return

		var parts_found = 0
		var i = 0
		var body_started = false

		var extends_this = null
		var the_class_name = null

		while(!f.eof_reached() and parts_found != 2 and !body_started):
			var line = f.get_line()
			var err_info = str(path, " line ", i)
			var result = _get_second_word_on_line_that_starts_with_word(
				line, 'class_name', err_info)
			if(result != null):
				the_class_name = result
				parts_found += 1
			else:
				result = _get_second_word_on_line_that_starts_with_word(
					line, 'extends', err_info)
				if(result != null):
					extends_this = result
					if(extends_this.contains("res:")):
						extends_this = extends_this.replace("'", '')
						extends_this = extends_this.replace('"', '')
						extends_this = _parse_file(extends_this)['extends']
					parts_found += 1
				elif(_is_line_script_body_type_text(line)):
					body_started = true

			i += 1
		f.close()

		var to_return = {'class_name':null, 'extends':'RefCounted'}
		if(extends_this != null):
			to_return['extends'] = extends_this
		if(the_class_name != null):
			to_return['class_name'] = the_class_name
		return to_return


	func load_it():
		_entries.clear()
		var cfg = ConfigFile.new()
		var cache_path = _replace_res(class_cache_path)
		var result = cfg.load(cache_path)
		if(result != OK):
			if(result == ERR_FILE_NOT_FOUND):
				print(cache_path, ' does not exist, it will be created when saved.')
			else:
				push_warning("Could not open/parse ", cache_path, ":  ", result, ".  Existing values will not be used.")
			return

		var scripts = cfg.get_value('', 'list', [])
		for entry in scripts:
			_entries[entry.class] = entry

		print("Loaded ", cache_path)


	func add_class_entry(path, class_string, extends_string):
		var new_entry = {
			"base" : StringName(extends_string),
			"class" : StringName(class_string),
			"icon" : "",
			"language" : &"GDScript",
			"path" : path
		}

		if(_entries.has(class_string)):
			if(_entries[class_string] == new_entry):
				print(class_string, ' does not need to be updated.')
			else:
				_entries[class_string] = new_entry
				print(class_string, " updated")
		else:
			_entries[class_string] = new_entry
			print(class_string, " added")


	func add_class_entry_from_file(path):
		if(!FileAccess.file_exists(_replace_res(path))):
			push_error('Could not find file [', path, ']')
			return

		var file_parts = _parse_file(path)
		if(file_parts['class_name'] == null):
			push_warning(str(path, ' was ignored because it does not have a class_name.'))
			return

		add_class_entry(path, file_parts['class_name'], file_parts['extends'])


	func make_list_entry_value():
		var list_value = []
		for key in _entries:
			list_value.append(_entries[key])
		return list_value


	func print_list_entry_values():
		var list_value = make_list_entry_value()
		for entry in list_value:
			for key in entry:
				var val = entry[key]
				var entry_text = str('"', val, '"')
				if(val is StringName):
					entry_text = "&" + entry_text
				print(key, ' : ', entry_text)
			print()


	func save_it():
		var list_value = make_list_entry_value()

		var path = _replace_res(class_cache_path)
		var d = DirAccess.open('./')
		d.make_dir_recursive(path.get_base_dir())

		var cfg = ConfigFile.new()
		cfg.set_value('', 'list', list_value)
		cfg.save(path)

		print("Wrote ", _replace_res(class_cache_path))




# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
var _o_class_cache_file = null
var _o_dry_run = null


func _update_class_cache(scripts):
	var updater = ScriptClassCacheUpdater.new()
	updater.class_cache_path = _o_class_cache_file.value

	updater.load_it()
	for entry in scripts:
		updater.add_class_entry_from_file(entry)
	if(_o_dry_run.value):
		print("\n-- Dry Run --")
		updater.print_list_entry_values()
	else:
		updater.save_it()


func add_scripts_from_file(path, append_to):
	var f = FileAccess.open(path, FileAccess.READ )
	if(f != null):
		var text = f.get_as_text()
		append_to.append_array(text.split("\n"))
	else:
		push_error(str("Could not open ", path, ":  ", FileAccess.get_open_error()))



func setup_options():
	var opts = OptParse.new()
	opts.show_usage_in_help = false
	opts.banner = \
"""
This will create/update a global_script_class_cache.cfg file for the provided
scripts.  It will parse out the class_name from the scripts and add entries to
the config file.

Entries are created for any script that is missing in the global class cache file.
Entries in the global class cache are updated (if they need to be) if they
already exist.  Any entries for scripts not provided are not altered.

The global class cache file will be created, as well as any parent directories,
if they do not exist.

Usage
--------
 <path to godot> --headless -s addons/gut/cli/update_script_class_cache.gd [opts] script_path1 script_path2 ...
"""

	_o_class_cache_file = opts.add("-class-cache-file", "res://.godot/global_script_class_cache.cfg",
		"The relative or absolute path to class cache config file.  Default [default]")
	opts.add("-class-list-file", "",
		"An optional file containing a list of scripts to add to the global class cache, one per line.")
	# Decided to remove this option for now.  It would be useful if this script
	# was used outside of a project, but not needed when inside GUT.
	# opts.add("-res-path", "./", "The path to the project root, default is the current working directory.")
	_o_dry_run = opts.add("-dry-run", false,
		"Print results instead of updating file")
	opts.add("-help", false, "Show this help")

	return opts


func _init():
	var opts = setup_options()
	opts.parse()

	if(opts.get_value('-help')):
		opts.print_help()
	elif(opts.get_missing_required_options().size() > 0):
		push_error(str("Missing options:  \n", opts.get_missing_text()))
	else:
		var scripts = opts.unused.duplicate()

		add_scripts_from_file('res://addons/gut/cli/gut_class_list.txt', scripts)

		var class_list_file = opts.get_value("-class-list-file")
		if(class_list_file != ''):
			add_scripts_from_file(class_list_file, scripts)

		_update_class_cache(scripts)

	quit()