## Overview
There are some scenarios where it is desireable to run a test numerous times with different parameters.  You can do this in GUT by creating a test that has a single parameter that is defaulted to the GUT method `use_parameters`.

## Requirements:
* The test must have one and only one paramter.
* The parameter must be defaulted to call `use_parameters`.
* You must pass an array to `use_parameters`.  The test will be called once for each element in the array.
* If the parameter is not defaulted then it will cause a runtime error.
* If `use_parameters` is not called then GUT will only run the test once and will generate an error.


## Example
Given:
``` gdscript
class Foo:
  func add(p1, p2):
    return p1 + p2
```
Then
``` gdscript
extends GutTest

var foo_params = [[1, 2, 3], ['a', 'b', 'c']]

func test_foo(params=use_parameters(foo_params)):
  var foo = Foo.new()
  var result = foo.add(params[0], params[1])
  assert_eq(result, params[2])
```
Which would result in :
* one passing test (`1 + 2 = 3`)
* one failing test (`'a' + 'b'  != 'c'`, it actually equals `'ab'`)

## Helpers (ParameterFactory)

### named_parameters(names, values)

Creates an array of dictionaries.  It pairs up the names array with each set
of values in values.  If more names than values are specified then the missing
values will be filled with nulls.  If more values than names are specified
those values will be ignored.

Example:
```
ParameterFactory.named_parameters(['a', 'b'], [[1, 2], ['one', 'two']])
# returns [{a:1, b:2}, {a:'one', b:'two'}]

# extra values
ParameterFactory.named_parameters(['a'], [[1, 2], [3, 4]])
# returns [{a:1}, {a:3}]

# not enough values
ParameterFactory.named_parameters(['a', 'b'], [[1], 'oops', ['one', 'two']])
# returns [{a:1, b:null}, {a:'oops', b:null}, {a:'one', b:'two'}]
```
This allows you to increase readability of your parameterized tests:

``` gdscript
var foo_params = ParameterFactory.named_parameters(
  ['p1', 'p2', 'result'], # names
  [[1, 2, 3], ['a', 'b', 'c']]) # values

func test_foo(params=use_parameters(foo_params)):
  var foo = Foo.new()
  var result = foo.add(params.p1, params.p2)
  assert_eq(result, params.result)
``````

### Others?
If you have an idea for a helper please create an [issue on Github](https://github.com/bitwes/Gut/issues).