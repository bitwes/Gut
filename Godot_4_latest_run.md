# The results of testing GUT as of now in Godot 4.0
This is the results of running the full GUT test suit in Godot 4.0.  This is for reference if you are working on something, this is what is currently going on.


```
==============================================
= Run Summary
==============================================

res://test/unit/test_gut.gd.TestEverythingElse
- test_asserts_on_test_object
    [Pending]:  This really is not pending

res://test/unit/test_gut_yielding.gd.TestWaitSeconds
- test_failing_assert_ends_yield
    [Failed]:  [0.51036144444444] expected to be > than [999.0]:  Testing that GUT continues after failing assert; ignore failing unless value not ~.5.
          at line 183
- test_pending_ends_yield
    [Pending]:  Testing Gut continues after yield.  0.51783788888889 should be ~.5.

res://test/unit/test_print.gd
- test_multiple_failing_no_params
    [Failed]:  SHOULD FAIL
          at line 45
    [Failed]:  SHOULD FAIL
          at line 46
- test_basic_array
    [Failed]:  (call #2) [2] expected to equal [1]:  2 and 4 expected to equal 1 SHOULD FAIL
          at line 49
    [Failed]:  (call #4) [4] expected to equal [1]:  2 and 4 expected to equal 1 SHOULD FAIL
          at line 49

res://test/unit/test_print.gd.TestLogLevels
- test_log_types_at_levels_with_failing_test
    [Failed]:  (call #1) SHOULD FAIL (-2)
          at line 169
    [Failed]:  (call #2) SHOULD FAIL (-1)
          at line 169
    [Failed]:  (call #3) SHOULD FAIL (0)
          at line 169
    [Failed]:  (call #4) SHOULD FAIL (1)
          at line 169
    [Failed]:  (call #5) SHOULD FAIL (2)
          at line 169
    [Failed]:  (call #6) SHOULD FAIL (3)
          at line 169

res://test/unit/test_test.gd.TestPending
- test_pending_accepts_text
    [Pending]:  This is a pending test.  You should see this text in the results.

res://test/unit/test_test.gd.TestAssertExports
    [Risky] Script was skipped:  Not implemented in 4.0

res://test/unit/test_test.gd.TestMemoryMgmt
- test_failing_orphan_assert_marks_test_as_failing
    [Failed]:  Expected no orphans, but found 1:  SHOULD FAIL
          at line 1684

res://test/unit/test_test_collector.gd.TestExportImport
    [Risky] Script was skipped:  Not implemented in 4.0

res://test/integration/test_doubler_and_spy.gd.TestBoth
- test_can_spy_on_singleton_doubles
    [Pending]:  No singleton doubling

Totals
Scripts:          48
Passing tests     1146
Failing tests     5
Risky tests       2
Pending:          4
Asserts:          1809 of 1821 passed

Warnings/Errors:
* 15 Errors.
* 6 Warnings.


1146 passed 5 failed.  Tests finished in 116.918s


[Orphans]:  81 new orphans in total.
```