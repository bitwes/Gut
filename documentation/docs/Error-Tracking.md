# Error Detection

Godot introduced the ability to detect when errors occur in version 4.5.  GUT uses this new ability to fail all tests that encounter an error during the test's execution.  There are three different kinds of errors that GUT can detect.
* Internal GUT errors
* Calls to `push_error`
* Engine errors (Script/Shader/Godot errors)




## Disabling Failing/Error Detection
You can prevent GUT from failing when it encounters an error or prevent the detection all together.


### Editor
<!-- put an image here -->


### .gutconfig.json
This is the propery and default value.  Add this property to your gutconfig with the types you want to cause failures.
```json
failure_error_types = ["engine", "gut", "push_error"]
```

You can disable the error detection by adding.  This will prevent engine and push_error errors from causing failure but not GUT errors.
```json
no_error_tracking = true,
```

There are also command line options for these, see the command line help for more information.




## Handling Expected Errors


### assert_errored
* Prevents failure
* Does not prevent the error from appearing in the log or anywhere else.  This is not possible to do.


### get_errors
Get the errors that occurred and inspect them.  Call `pass_test` or `fail_test` manually (if you want to) based on what you find.

Set `error.handled` to `true` to prevent the error from causing a failure.