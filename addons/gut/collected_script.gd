var CollectedTest = load('res://addons/gut/collected_test.gd')

# ------------------------------------------------------------------------------
# This holds all the meta information for a test script.  It contains the
# name of the inner class and an array of Test "structs".
#
# This class also facilitates all the exporting and importing of tests.
# ------------------------------------------------------------------------------
var inner_class_name:StringName
var tests = []
var path:String
var _utils = null
var _lgr = null
var is_loaded = false

var name = '' :
    get: return path
    set(val):pass


func _init(utils=null,logger=null):
    _utils = utils
    _lgr = logger


func to_s():
    var to_return = path
    if(inner_class_name != null):
        to_return += str('.', inner_class_name)
    to_return += "\n"
    for i in range(tests.size()):
        to_return += str('  ', tests[i].name, "\n")
    return to_return


func get_new():
    return load_script().new()


func load_script():
    var to_return = load(path)

    if(inner_class_name != null and inner_class_name != ''):
        # If we wanted to do inner classes in inner classses
        # then this would have to become some kind of loop or recursive
        # call to go all the way down the chain or this class would
        # have to change to hold onto the loaded class instead of
        # just path information.
        to_return = to_return.get(inner_class_name)

    return to_return


func get_filename_and_inner():
    var to_return = get_filename()
    if(inner_class_name != ''):
        to_return += '.' + String(inner_class_name)
    return to_return


func get_full_name():
    var to_return = path
    if(inner_class_name != ''):
        to_return += '.' + String(inner_class_name)
    return to_return


func get_filename():
    return path.get_file()


func has_inner_class():
    return inner_class_name != ''


# Note:  although this no longer needs to export the inner_class names since
#        they are pulled from metadata now, it is easier to leave that in
#        so we don't have to cut the export down to unique script names.
func export_to(config_file, section):
    config_file.set_value(section, 'path', path)
    config_file.set_value(section, 'inner_class', inner_class_name)
    var names = []
    for i in range(tests.size()):
        names.append(tests[i].name)
    config_file.set_value(section, 'tests', names)


func _remap_path(source_path):
    var to_return = source_path
    if(!_utils.file_exists(source_path)):
        _lgr.debug('Checking for remap for:  ' + source_path)
        var remap_path = source_path.get_basename() + '.gd.remap'
        if(_utils.file_exists(remap_path)):
            var cf = ConfigFile.new()
            cf.load(remap_path)
            to_return = cf.get_value('remap', 'path')
        else:
            _lgr.warn('Could not find remap file ' + remap_path)
    return to_return


func import_from(config_file, section):
    path = config_file.get_value(section, 'path')
    path = _remap_path(path)
    # Null is an acceptable value, but you can't pass null as a default to
    # get_value since it thinks you didn't send a default...then it spits
    # out red text.  This works around that.
    var inner_name = config_file.get_value(section, 'inner_class', 'Placeholder')
    if(inner_name != 'Placeholder'):
        inner_class_name = inner_name
    else: # just being explicit
        inner_class_name = StringName("")


func get_test_named(name):
    return _utils.search_array(tests, 'name', name)


func mark_tests_to_skip_with_suffix(suffix):
    for single_test in tests:
        single_test.should_skip = single_test.name.ends_with(suffix)



# _______________ Summary ____________________
var was_skipped = false
var skip_reason = ''
var _tests = {}			# - These two replace tests[]
var _test_order = []	# -
# var name = 'NOT_SET' # <- this is path



func get_pass_count():
    var count = 0
    for t in tests:
        count += t.pass_texts.size()
    return count


func get_fail_count():
    var count = 0
    for t in tests:
        count += t.fail_texts.size()
    return count


func get_pending_count():
    var count = 0
    for t in tests:
        count += t.pending_texts.size()
    return count


func get_passing_test_count():
    var count = 0
    for t in tests:
        if(t.is_passing()):
            count += 1
    return count


func get_failing_test_count():
    var count = 0
    for t in tests:
        if(t.is_failing()):
            count += 1
    return count


func get_risky_count():
    var count = 0
    if(was_skipped):
        count = 1
    else:
        for t in tests:
            if(t.is_risky()):
                count += 1
    return count


func get_test_obj(obj_name): # <- this should be get_test_named I think
    if(!_tests.has(obj_name)):
        var to_add = CollectedTest.new()
        _tests[obj_name] = to_add
        _test_order.append(obj_name)

    var to_return = _tests[obj_name]

    return to_return


func add_pass(test_name, reason):
    var t = get_test_obj(test_name)
    t.pass_texts.append(reason)


func add_fail(test_name, reason):
    var t = get_test_obj(test_name)
    t.fail_texts.append(reason)


func add_pending(test_name, reason):
    var t = get_test_obj(test_name)
    t.pending_texts.append(reason)


func get_tests():
    return _tests