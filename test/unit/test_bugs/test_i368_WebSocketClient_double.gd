extends GutTest

func test_make_double_of_WebSocketClient():
	var WebSocketClientPD = partial_double(WebSocketClient)
	assert_not_null(WebSocketClientPD)

func test_make_instance_of_WebSocketClient_double():
	var pd = double(WebSocketClient).new()
	assert_not_null(pd)

func test_can_spy_on_connect_to_url():
	var pd = double(WebSocketClient).new()
	pd.connect_to_url('somewhere.biz')
	assert_called(pd, 'connect_to_url')

func test_can_spy_on_partial_connect_to_url():
	var pd = partial_double(WebSocketClient).new()
	pd.connect_to_url('somewhere.biz')
	assert_called(pd, 'connect_to_url')

func test_can_spy_on_defaulted_params():
	var pd = double(WebSocketClient).new()
	pd.connect_to_url('somewhere.biz')
	assert_called(pd, 'connect_to_url',
		['somewhere.biz', PoolStringArray(), false, PoolStringArray()])

func test_can_stub_default_of_connect_to_url_first_param():
	stub(WebSocketClient, 'connect_to_url').param_defaults(['asdf'])
	var pd = double(WebSocketClient).new()
	pd.connect_to_url()
	assert_called(pd, 'connect_to_url',
		['asdf', PoolStringArray(), false, PoolStringArray()])

func test_can_spy_on_all_params():
	var pd = double(WebSocketClient).new()
	var psa_1 = PoolStringArray([1, 2, 3])
	var psa_2 = PoolStringArray(['a', 'b', 'c'])
	pd.connect_to_url('somewhere.biz', psa_1, true, psa_2)
	assert_called(pd, 'connect_to_url',
		['somewhere.biz', psa_1, true, psa_2])
