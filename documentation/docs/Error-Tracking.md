# Error Tracking

Godot introduced the ability to detect errors in version 4.5.  GUT uses this new ability to fail all tests that encounter an error during the test's execution.  There are three different kinds of errors that GUT can detect.
* Internal GUT errors
* Calls to `push_error`
* Engine errors (Script/Shader/Godot errors)

GUT also provides some methods (below) to assert that expected errors have occurred and prevent tests from failing.


## Disabling Failing/Error Detection
You can prevent GUT from failing when it encounters an error or prevent the detection all together.  When failures are disabled, you can still assert that errors have occured.  If you disable the error detection then error assertions will always fail.


### Via the Editor
These options can be found in the GutPanel options.  Track Errors disables the error tracking systm (same as `no_error_tracking` below).  "Engine", "Push", and "GUT" enable/disable whether that error type causes a test to fail.

![Editor Error Options](_static/images/GutErrorOptions.png)


### Via .gutconfig.json File
`failure_error_types` holds a list of the error types that will cause failures.  An empty list means no error types will cause failures.  Invalid values are ignored.  Values are case sensitive.  This is the default entry which contains all errors.  This should only be specified in your file if you want to disable an error type.
```json
failure_error_types = ["engine", "gut", "push_error"]
```

`no_error_tracking` can be used to disable the error detection system.  GUT errors will still be detected (they are handled differently).
```json
no_error_tracking = true,
```


### Via the CLI
There are also command line options for these, see the command line help for more information.




## "Handling" Expected Errors
There are a couple methods that can be used to test for expected errors and prevent tests from failing when an error occurs.  The two asserts will prevent failures when the expected number of error types has occurred.  You can use `get_errors` to get all the errors and inspect them more closely to determine if the exact errors you expected happend during the test. See the methods for more information.

All errors will always appear in the output.

* <a href="class_ref/class_guttest.html#class-guttest-method-assert-push-error">GutTest.assert_push_error</a>
* <a href="class_ref/class_guttest.html#class-guttest-method-assert-engine-error">GutTest.assert_engine_error</a>
* <a href="class_ref/class_guttest.html#class-guttest-method-get-errors">GutTest.get_errors</a>




## See Also
This is my first pass at adding error detection/assertions to GUT.  Please open an issue if you have additional ideas.

* <a href><a href="class_ref/class_guttrackederror.html">GutTrackedError</a>