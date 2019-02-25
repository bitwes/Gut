extends 'res://test/gut_test.gd'

func test_can_warn():
	var l = Logger.new()
	l.warn('something')
	assert_eq(l.get_warnings().size(), 1)

func test_can_error():
	var l = Logger.new()
	l.error('soemthing')
	assert_eq(l.get_errors().size(), 1)

func test_can_info():
	var l = Logger.new()
	l.info('something')
	assert_eq(l.get_infos().size(), 1)

func test_can_debug():
	var l = Logger.new()
	l.debug('something')
	assert_eq(l.get_debugs().size(), 1)

func test_can_deprecate():
	var l = Logger.new()
	l.deprecated('something')
	assert_eq(l.get_deprecated().size(), 1)

func test_clear_clears_all_buffers():
	var l = Logger.new()
	l.debug('a')
	l.info('a')
	l.warn('a')
	l.error('a')
	l.deprecated('a')
	l.clear()
	assert_eq(l.get_debugs().size(), 0, 'debug')
	assert_eq(l.get_infos().size(), 0, 'info')
	assert_eq(l.get_errors().size(), 0, 'error')
	assert_eq(l.get_warnings().size(), 0, 'warnings')
	assert_eq(l.get_deprecated().size(), 0, 'deprecated')

# this is necessary b/c old implementation did weird stuff and
# I'm trying to fix it.
func test_correct_prefix_used():
	var msgs = []
	var l = Logger.new()
	msgs.append(l.debug('a'))
	msgs.append(l.info('a'))
	msgs.append(l.warn('a'))
	msgs.append(l.error('a'))
	msgs.append(l.deprecated('a'))

	assert_ne(msgs[0], msgs[1], '0, 1')
	assert_ne(msgs[1], msgs[2], '1, 2')
	assert_ne(msgs[2], msgs[3], '2, 3')
	assert_ne(msgs[3], msgs[4], '3, 4')

func test_get_set_gut():
	assert_accessors(Logger.new(), 'gut', null, double(Gut).new())

func test_uses_gut_print_if_it_has_a_gut():
	var gut = double(Gut).new()
	var l = Logger.new()
	l.set_gut(gut)
	l.info('something')
	assert_called(gut, 'p')
