var _Logger = load('res://addons/gut/logger.gd') # everything should use get_logger

var Doubler = load('res://addons/gut/doubler.gd')
var Gut = load('res://addons/gut/gut.gd')
var HookScript = load('res://addons/gut/hook_script.gd')
var MethodMaker = load('res://addons/gut/method_maker.gd')
var Spy = load('res://addons/gut/spy.gd')
var Stubber = load('res://addons/gut/stubber.gd')
var StubParams = load('res://addons/gut/stub_params.gd')
var Summary = load('res://addons/gut/summary.gd')
var Test = load('res://addons/gut/test.gd')
var TestCollector = load('res://addons/gut/test_collector.gd')
var ThingCounter = load('res://addons/gut/thing_counter.gd')
var OneToMany = load('res://addons/gut/one_to_many.gd')

const GUT_METADATA = '__gut_metadata_'

enum DOUBLE_STRATEGY{
	FULL,
	PARTIAL
}

var escape = PoolByteArray([0x1b]).get_string_from_ascii()
var CMD_COLORS  = {
	RED = escape + '[31m',
	YELLOW = escape + '[33m',
	DEFAULT = escape + '[0m',
	GREEN = escape + '[32m',
	UNDERLINE = escape + '[4m',
	BOLD = escape + '[1m'
}

func colorize_word(source, word, c):
	var new_word  = c + word + CMD_COLORS.DEFAULT
	return source.replace(word, new_word)

func colorize_text(text):
	var t = colorize_word(text, 'FAILED', CMD_COLORS.RED)
	t = colorize_word(t, 'PASSED', CMD_COLORS.GREEN)
	t = colorize_word(t, 'PENDING', CMD_COLORS.YELLOW)
	t = colorize_word(t, '[ERROR]', CMD_COLORS.RED)
	t = colorize_word(t, '[WARNING]', CMD_COLORS.YELLOW)
	t = colorize_word(t, '[DEBUG]', CMD_COLORS.BOLD)
	t = colorize_word(t, '[DEPRECATED]', CMD_COLORS.BOLD)
	t = colorize_word(t, '[INFO]', CMD_COLORS.BOLD)
	return t
	

var _file_checker = File.new()

func is_version_30():
	var info = Engine.get_version_info()
	return info.major == 3 and info.minor == 0

func is_version_31():
	var info = Engine.get_version_info()
	return info.major == 3 and info.minor == 1

# ------------------------------------------------------------------------------
# Everything should get a logger through this.
#
# Eventually I want to make this get a single instance of a logger but I'm not
# sure how to do that without everything having to be in the tree which I
# DO NOT want to to do.  I'm thinking of writings some instance ids to a file
# and loading them in the _init for this.
# ------------------------------------------------------------------------------
func get_logger():
	return _Logger.new()

# ------------------------------------------------------------------------------
# Returns an array created by splitting the string by the delimiter
# ------------------------------------------------------------------------------
func split_string(to_split, delim):
	var to_return = []

	var loc = to_split.find(delim)
	while(loc != -1):
		to_return.append(to_split.substr(0, loc))
		to_split = to_split.substr(loc + 1, to_split.length() - loc)
		loc = to_split.find(delim)
	to_return.append(to_split)
	return to_return

# ------------------------------------------------------------------------------
# Returns a string containing all the elements in the array separated by delim
# ------------------------------------------------------------------------------
func join_array(a, delim):
	var to_return = ''
	for i in range(a.size()):
		to_return += str(a[i])
		if(i != a.size() -1):
			to_return += str(delim)
	return to_return

# ------------------------------------------------------------------------------
# return if_null if value is null otherwise return value
# ------------------------------------------------------------------------------
func nvl(value, if_null):
	if(value == null):
		return if_null
	else:
		return value

# ------------------------------------------------------------------------------
# returns true if the object has been freed, false if not
#
# From what i've read, the weakref approach should work.  It seems to work most
# of the time but sometimes it does not catch it.  The str comparison seems to
# fill in the gaps.  I've not seen any errors after adding that check.
# ------------------------------------------------------------------------------
func is_freed(obj):
	var wr = weakref(obj)
	return !(wr.get_ref() and str(obj) != '[Deleted Object]')

func is_not_freed(obj):
	return !is_freed(obj)

func is_double(obj):
	return obj.get(GUT_METADATA) != null

func extract_property_from_array(source, property):
	var to_return = []
	for i in (source.size()):
		to_return.append(source[i].get(property))
	return to_return

func file_exists(path):
	return _file_checker.file_exists(path)

func write_file(path, content):
	var f = File.new()
	f.open(path, f.WRITE)
	f.store_string(content)
	f.close()

func is_null_or_empty(text):
	return text == null or text == ''

func get_native_class_name(thing):
	var to_return = null
	if(is_native_class(thing)):
		to_return = thing.new().get_class()
	return to_return

func is_native_class(thing):
	var it_is = false
	if(typeof(thing) == TYPE_OBJECT):
		it_is = str(thing).begins_with("[GDScriptNativeClass:")
	return it_is

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
func get_file_as_text(path):
	var to_return = ''
	var f = File.new()
	var result = f.open(path, f.READ)
	if(result == OK):
		to_return = f.get_as_text()
		f.close()
	return to_return
