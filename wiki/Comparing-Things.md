# <div class="warning">This page has not been updated for GUT 9.0.0 or Godot 4.  There could be incorrect information here.</div>
# Overview
Comparing values with GUT's asserts works the way you would expect it to in most cases.  Arrays and dictionaries are a little more complicated.  The following methods can help with this:
* `compare_shallow`
* `compare_deep`
* [`assert_eq_shallow`](Asserts-and-Methods#assert_eq_shallow), [`assert_ne_shallow`](Asserts-and-Methods#assert_ne_shallow)
* [`assert_eq_deep`](Asserts-and-Methods#assert_eq_deep), [`assert_ne_deep`](Asserts-and-Methods#assert_ne_deep)

The asserts listed are convenience wrappers around `compare_shallow` and `compare_deep`.  In most cases this will be all you need.  If you would like to further inspect the differences with code then or adjust the number of differences displayed then use the "compare" methods.  These methods return a [`CompareResult`](#CompareResult) object which is described below.

### Shallow
A shallow compare will look at each element in a dictionary or array and use the default Godot equivalence logic.  Floats and Integers are never equal.  See [`assert_eq_shallow`](Asserts-and-Methods#assert_eq_shallow) for examples.

### Deep
A deep compare will recursively compare all values in the dictionary/array and all sub-dictionaries and sub-arrays.  Floats and Integers are never equal.  See [`assert_eq_deep`](Asserts-and-Methods#assert_eq_deep) for examples.

# <a name=ComparingArrays>Comparing Arrays</a>
* Godot compares arrays by value with some caveats.
    * Unlike when using `==`, floats never == integers in an array.
    * Dictionaries are compared by reference.  Two different dictionaries with the same values are not equal.
* Sub arrays are compared the same way.
* Cannot compare arrays by reference.

### Asserts and Arrays
* The `assert_eq` and `assert_ne` functions simulate Godot's behavior but have improved output.
    * Up to 30 differences in index values are listed including any missing indexes.
    * Dictionaries anywhere in the array are compared-by-ref.
    * Sub-arrays are summarized, the number of indexes that do not match are listed, but each different value is not.
* `assert_called` and `assert_not_called` perform deep compares on any parameters specified.
* `assert_signal_emitted_with_parameters` performs a deep compare on the parameters specified.
* `assert_has` and `assert_does_not_have` use Godot's default behavior.

### Shallow
A shallow compare of arrays acts the same as `assert_eq`/`assert_ne`.  Any dictionaries in the array or sub-arrays will be compared by reference.  Floats and Integers are never equal.

### Deep
A deep compare of arrays will compare all indexes and the values in all sub-arrays/sub-dictionaries found.  Floats and Integers are never equal.


# <a name=ComparingDictionaries>Comparing Dictionaries</a>
* Godot compares dictionaries by reference.
* Dictionary keys are ordered (which is unusual).
* The dictionary `hash` function requires dictionary keys be in the same order to generate the same hash so comparing dictionaries by value cannot be done reliably without additional coding.
* In order to compare values in dictionary you must use one of the shallow or deep methods listed above.

### Asserts and Dictionaries
* The `assert_eq` and `assert_ne` uses Godot's default behavior and compares them by reference.
* `assert_called` and `assert_not_called` perform deep compares on any parameters specified.
* `assert_signal_emitted_with_parameters` performs a deep compare on the parameters specified.
* `assert_has` and `assert_does_not_have` use Godot's default behavior.

### Shallow
A shallow compare of dictionaries will compare all values found in the dictionary.  Sub-dictionaries are compared by value.  Sub-arrays are compared with `==`.  Floats and Integers are never equal.

### Deep
A  deep compare of dictionaries will compare all keys and the values  in all sub-arrays/sub-dictionaries found.  Floats and Integers are never equal.

# <a name=CompareResult> CompareResult</a>
A CompareResult object is returned from `compare_shallow` and `compare_deep`.  You can use this object to further inspect the differences or adjust the output.

### Properties
* `are_equal`: returns `true`/`false` if the two objects are equal based on the kind of comparison performed.
* `summary`: returns a string of all the differences found.  This will display `max_differences` differences.  When performing a deep compare, it will also display `max_differences` per each sub-array/sub-dictionary. This is returned if you use `str` on a `CompareResult`.
* `max_differences`:  The number of differences to display.  This only affects output, all differences are accessible from the `differences` property.  Set this to -1 to show the maximum number of differences (10,000)
* `differences`:  This is a dictionary of all the keys/indexes that are different between the compared items.  The key is the key/index that is different.  Keys/indexes that are missing from one of the compared objects are included.  The value of each index is a `CompareResult`.
<br/><br/>
`CompareResult`s for sub-arrays/sub-dictionaries `differences` will contain all their differences.  You can use  the `differences` property for that key to dig deeper into the differences.  `differences` will be an empty dictionary for any element that is not an array or dictionary.


## Examples

### Deep array compare:
```gdscript
var a1 = [
    [1, 2, 3, 4],
    [[4, 5, 6], ['same'], [7, 8, 9]]
]
var a2 = [
    ["1", 2.0, 13],
    [[14, 15, 16], ['same'], [17, 18, 19]]
]
var result = compare_deep(a1, a2)
print(result.summary)

print('Traversing differences:')
print(result.differences[1].differences[2].differences[0])
```
Output
```
[[1, 2, 3, 4], [[4, 5, 6], [same], [7, 8...7, 8, 9]]] != [[1, 2, 13], [[14, 15, 16], [same], [17,... 18, 19]]]  2 of 2 indexes do not match.
    [
        0:  [
            0:  1 != "1".  Cannot compare Int with String.
            1:  2 != 2.0.  Cannot compare Int with Float/Real.
            2:  3 != 13
            3:  4 != <missing index>
        ]
        1:  [
            0:  [
                0:  4 != 14
                1:  5 != 15
                2:  6 != 16
            ]
            2:  [
                0:  7 != 17
                1:  8 != 18
                2:  9 != 19
            ]
        ]
    ]
Traversing differences:
7 != 17
```

### Deep Dictionary Compare
``` gdscript
var v1 = {'a':{'b':{'c':{'d':1}}}}
var v2 = {'a':{'b':{'c':{'d':2}}}}
var result = compare_deep(v1, v2)
print(result.summary)

print('Traversing differences:')
print(result.differences['a'].differences['b'].differences['c'])
```
Output
```
{a:{b:{c:{d:1}}}} != {a:{b:{c:{d:2}}}}  1 of 1 keys do not match.
    {
        a:  {
            b:  {
                c:  {
                    d:  1 != 2
                }
            }
        }
    }
Traversing differences:
{d:1} != {d:2}  1 of 1 keys do not match.
    {
        d:  1 != 2
    }
```
### Mix Bag of Differences
```gdscript
var a1 = [
    'a', 'b', 'c',
    [1, 2, 3, 4],
    {'a':1, 'b':2, 'c':3},
    [{'a':1}, {'b':2}]
]
var a2 = [
    'a', 2, 'c',
    ['a', 2, 3, 'd'],
    {'a':11, 'b':12, 'c':13},
    [{'a':'diff'}, {'b':2}]
]
var result = compare_deep(a1, a2)
print(result.summary)

print('Traversing differences:')
print(result.differences[5].differences[0].differences['a'])

```
Output
```
[a, b, c, [1, 2, 3, 4], {a:1, b:2, c:3},...}, {b:2}]] != [a, 2, c, [a, 2, 3, d], {a:11, b:12, c:1...}, {b:2}]]  4 of 6 indexes do not match.
    [
        1:  "b" != 2.  Cannot compare String with Int.
        3:  [
            0:  1 != "a".  Cannot compare Int with String.
            3:  4 != "d".  Cannot compare Int with String.
        ]
        4:  {
            a:  1 != 11
            b:  2 != 12
            c:  3 != 13
        }
        5:  [
            0:  {
                a:  1 != "diff".  Cannot compare Int with String.
            }
        ]
    ]
    Traversing differences:
    1 != "diff".  Cannot compare Int with String.
```
