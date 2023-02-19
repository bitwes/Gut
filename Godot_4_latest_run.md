# The results of testing GUT as of now in Godot 4 RC 2

```
res://test/unit/test_bugs/test_i368_WebSocketClient_double.gd
    [Risky] Script was skipped:  WebSocket changed in beta 3, not sure if these are valid anymore.

res://test/unit/test_comparator.gd.TestSimpleCompare
- test_comparing_different_dictionaries_includes_disclaimer
    [Pending]:  4.0 Dictionary and array compare broke

res://test/unit/test_comparator.gd.TestShallowCompare
- test_comparing_dictionaries_does_not_include_sub_dictionaries
    [Pending]:  4.0 Dictionary and array compare broke
- test_comparing_arrays_does_not_include_sub_dictionaries
    [Pending]:  4.0 Dictionary and array compare broke

res://test/unit/test_diff_tool.gd.TestArrayDiff
    [Risky] Script was skipped:  4.0 Dictionary and array compare broke

res://test/unit/test_diff_tool.gd.TestArrayDeepDiff
    [Risky] Script was skipped:  4.0 Dictionary and array compare broke

res://test/unit/test_diff_tool.gd.TestDictionaryCompareResultInterace
    [Risky] Script was skipped:  4.0 Dictionary and array compare broke

res://test/unit/test_diff_tool.gd.TestDictionaryDiff
    [Risky] Script was skipped:  4.0 Dictionary and array compare broke

res://test/unit/test_gut.gd.TestMisc
- test_gut_does_not_make_orphans_when_freed_before_in_tree
    [Failed]:  Expected no orphans, but found 1
          at line 153

res://test/unit/test_gut.gd.TestEverythingElse
- test_asserts_on_test_object
    [Pending]:  This really is not pending

res://test/unit/test_gut_yielding.gd.TestWaitSeconds
- test_failing_assert_ends_yield
    [Failed]:  [0.5163724949495] expected to be > than [999.0]:  Testing that GUT continues after failing assert; ignore failing unless value not ~.5.
          at line 183
- test_pending_ends_yield
    [Pending]:  Testing Gut continues after yield.  0.5125 should be ~.5.

res://test/unit/test_logger.gd
- test_get_set_gut
    [Pending]:  pending in 4.0

res://test/unit/test_print.gd
- test_print_non_strings
    [Risky] Did not assert
- test_print_multiple_lines
    [Risky] Did not assert
- test_multiple_failing_no_params
    [Failed]:  failing test one
          at line 43
    [Failed]:  failing test two
          at line 44
- test_basic_array
    [Failed]:  (call #2) [2] expected to equal [1]:  output test may fail
          at line 47
    [Failed]:  (call #4) [4] expected to equal [1]:  output test may fail
          at line 47
- test_await
    [Risky] Did not assert

res://test/unit/test_print.gd.TestGuiOutput
    [Risky] Script was skipped:  Not implemented in 4.0

res://test/unit/test_print.gd.TestLogLevels
- test_log_types_at_levels_with_failing_test
    [Failed]:  (call #1) this should fail (-2)
          at line 147
    [Failed]:  (call #2) this should fail (-1)
          at line 147
    [Failed]:  (call #3) this should fail (0)
          at line 147
    [Failed]:  (call #4) this should fail (1)
          at line 147
    [Failed]:  (call #5) this should fail (2)
          at line 147
    [Failed]:  (call #6) this should fail (3)
          at line 147
- test_clearing_ignores_freed_objecdts
    [Risky] Did not assert

res://test/unit/test_spy.gd.TestSpy
- test_has_logger
    [Pending]:  pending in 4.0

res://test/unit/test_strutils.gd.TestType2Str
- test_file_instance
    [Pending]:  4.0 This might not need to exist anymore due to FileAccess Changes

res://test/unit/test_stub_params.gd
- test_draw_parameter_method_meta2
    [Pending]:  defaults for draw_primitive have changed, need a better fit.
- test_draw_parameter_method_meta4
    [Pending]:  Parameters for draw_pimitive have changed. Need a different method to test with
- test_not_freeing_children_generates_warning
    [Risky] Did not assert

res://test/unit/test_test.gd.TestAssertEq
- test_with_array
    [Pending]:  4.0 Dictionary and array compare broke
    [Pending]:  4.0 Dictionary and array compare broke
    [Pending]:  4.0 Dictionary and array compare broke
    [Pending]:  4.0 Dictionary and array compare broke
    [Pending]:  4.0 Dictionary and array compare broke
    [Pending]:  4.0 Dictionary and array compare broke
    [Pending]:  4.0 Dictionary and array compare broke
    [Pending]:  4.0 Dictionary and array compare broke
- test_dictionary_not_compared_by_value
    [Pending]:  4.0 Dictionary and array compare broke

res://test/unit/test_test.gd.TestAssertNe
- test_dictionary_not_compared_by_value
    [Pending]:  4.0 Dictionary and array compare broke

res://test/unit/test_test.gd.TestPending
- test_pending_accepts_text
    [Pending]:  This is a pending test.  You should see this text in the results.

res://test/unit/test_test.gd.TestAssertExports
    [Risky] Script was skipped:  Not implemented in 4.0

res://test/unit/test_test.gd.TestMemoryMgmt
- test_failing_orphan_assert_marks_test_as_failing
    [Failed]:  Expected no orphans, but found 1:  this should fail
          at line 1701

res://test/unit/test_test.gd.TestCompareDeepShallow
    [Risky] Script was skipped:  Not implemented in 4.0

res://test/unit/test_test_collector.gd.TestTestCollector
- test_has_logger
    [Pending]:  pending in 4.0

res://test/unit/test_test_collector.gd.TestExportImport
    [Risky] Script was skipped:  Not implemented in 4.0

res://test/unit/test_utils.gd
- test_latest_version_if_version_is_old_warning_is_on
    [Pending]:  http_request node does not exist?

res://test/integration/test_doubler_and_spy.gd.TestBoth
- test_can_spy_on_singleton_doubles
    [Pending]:  No singleton doubling
- test_stubber_cleared_between_tests_setup
    [Risky] Did not assert

res://test/integration/test_gut_import_export.gd
- test_if_export_path_not_set_and_no_path_passed_error_is_generated
    [Failed]:  Does not have get_logger method
          at line 29
- test_import_errors_if_file_does_not_exist
    [Failed]:  Does not have get_logger method
          at line 58

res://test/integration/test_test_stubber_doubler.gd.TestIgnoreMethodsWhenDoubling
    [Risky] Script was skipped:  skip for now, array compares are broke.

res://test/integration/test_test_stubber_doubler.gd.TestPartialDoubleMethod
- test_can_double_file_skip__
    [Pending]:  SKIPPED because it ends with _skip__

res://test/integration/test_test_stubber_doubler.gd.TestOverridingParameters
- test_issue_246_rpc_id_varargs_skip__
    [Pending]:  SKIPPED because it ends with _skip__
- test_issue_246_rpc_id_varargs2_skip__
    [Pending]:  SKIPPED because it ends with _skip__
- test_issue_246_rpc_id_varargs_with_defaults_skip__
    [Pending]:  SKIPPED because it ends with _skip__

res://test/integration/test_this_script_has_a_really_long_name_to_test_display.gd
- test_nothing
    [Pending]:  do not need a test, but felt weird to not have one.



Totals
Scripts:          48
Passing tests     1062
Failing tests     8
Risky tests       16
Pending:          29
Asserts:          1671 of 1686 passed

Warnings/Errors:
* 15 Errors.
* 35 Warnings.
* 4 Deprecated calls.


1062 passed 8 failed.  Tests finished in 118.332s
```