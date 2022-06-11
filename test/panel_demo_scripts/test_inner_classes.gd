extends GutTest


class TestPassingDupeNames:
	extends GutTest
	
	func test_duplicate_name():
		pass_test('this one passes')
		
	func test_duplicate_name_two():
		pass_test('this also passes')


class TestBrokenDupedNames:
	extends GutTest
	
	func test_duplicate_name():
		fail_test('this one fails')
		
	func test_duplicate_name_two():
		pending('this one is pending')

class TestInner:
	extends GutTest
	
	func test_something_cool():
		pass_test('cool is cool')
		
	func test_something_not_cool():
		fail_test('failing is not cool')
