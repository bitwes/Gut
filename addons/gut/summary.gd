# ------------------------------------------------------------------------------
# Prints things, mostly.  Knows too much about gut.gd, but it's only supposed to
# work with gut.gd, so I'm fine with that.
# ------------------------------------------------------------------------------
# a _test_collector to use when one is not provided.
var _gut = null


func _init(gut = null):
	_gut = gut

# ---------------------
# Private
# ---------------------
func _log_end_run_header(gut):
	var lgr = gut.get_logger()
	lgr.log("\n\n\n")
	lgr.log('==============================================', lgr.fmts.yellow)
	lgr.log("= Run Summary", lgr.fmts.yellow)
	lgr.log('==============================================', lgr.fmts.yellow)


func _log_what_was_run(gut):
	if(!gut._utils.is_null_or_empty(gut._select_script)):
		gut.p('Ran Scripts matching "' + gut._select_script + '"')
	if(!gut._utils.is_null_or_empty(gut._unit_test_name)):
		gut.p('Ran Tests matching "' + gut._unit_test_name + '"')
	if(!gut._utils.is_null_or_empty(gut._inner_class_name)):
		gut.p('Ran Inner Classes matching "' + gut._inner_class_name + '"')


func _log_orphans_and_disclaimer(gut):
	var orphan_count = gut.get_orphan_counter()
	var lgr = gut.get_logger()
	# Do not count any of the _test_script_objects since these will be released
	# when GUT is released.
	orphan_count._counters.total += gut._test_script_objects.size()
	if(orphan_count.get_counter('total') > 0 and lgr.is_type_enabled('orphan')):
		orphan_count.print_orphans('total', lgr)
		gut.p("Note:  This count does not include GUT objects that will be freed upon exit.")
		gut.p("       It also does not include any orphans created by global scripts")
		gut.p("       loaded before tests were ran.")
		gut.p(str("Total orphans = ", orphan_count.orphan_count()))


func _log_totals(gut, totals, lgr):
	# just picked a non-printable char, dunno if it is a good or bad choice.
	var npws = PackedByteArray([31]).get_string_from_ascii()
	lgr.log()

	lgr.log("Totals", lgr.fmts.yellow)
	var col1 = 18
	var issue_count = 0
	if(totals.errors > 0):
		lgr.log(str('Errors:'.rpad(col1),       totals.errors))
		issue_count += 1
	if(totals.warnings > 0):
		lgr.log(str('Warnings:'.rpad(col1),     totals.warnings))
		issue_count += 1
	if(totals.deprecated > 0):
		lgr.log(str('Deprecated:'.rpad(col1),   totals.deprecated))
		issue_count += 1
	if(issue_count > 0):
		lgr.log("")
	# This line must use _test_script_objects since it holds the scripts that
	# were run.  totals has the total number of scripts that were found.  It was
	# either this, or create another mechanism for tracking which scripts were
	# run and where were not.  This was much much easier.
	lgr.log(str('Scripts:'.rpad(col1),          gut._test_script_objects.size()))
	lgr.log(str('Passing Tests'.rpad(col1),     totals.passing_tests))
	lgr.log(str('Failing Tests'.rpad(col1),     totals.failing_tests))
	lgr.log(str('Risky Tests'.rpad(col1),       totals.risky))
	var pnd=str('Pending Tests'.rpad(col1),     totals.pending)
	# add a non printable character so this "pending" isn't highlighted in the
	# editor's output panel.
	lgr.log(str(npws, pnd))
	lgr.log(str('Asserts:'.rpad(col1), totals.passing, ' of ', totals.passing + totals.failing, ' passed'))

	return totals


# ---------------------
# Public
# ---------------------
func log_all_non_passing_tests(gut=_gut):
	var test_collector = gut.get_test_collector()
	var lgr = gut.get_logger()

	var to_return = {
		passing = 0,
		non_passing = 0
	}

	for test_script in test_collector.scripts:
		lgr.set_indent_level(0)

		if(test_script.was_skipped or test_script.get_fail_count() > 0 or test_script.get_pending_count() > 0):
			lgr.log("\n" + test_script.get_full_name(), lgr.fmts.underline)

		if(test_script.was_skipped):
			lgr.inc_indent()
			var skip_msg = str('[Risky] Script was skipped:  ', test_script.skip_reason)
			lgr.log(skip_msg, lgr.fmts.yellow)
			lgr.dec_indent()

		for test in test_script.tests:
			if(test.was_run):
				if(test.is_passing()):
					to_return.passing += 1
				else:
					to_return.non_passing += 1
					lgr.log(str('- ', test.name))
					lgr.inc_indent()

					for i in range(test.fail_texts.size()):
						lgr.failed(test.fail_texts[i])
					for i in range(test.pending_texts.size()):
						lgr.pending(test.pending_texts[i])
					if(test.is_risky()):
						lgr.log('[Risky] Did not assert', lgr.fmts.yellow)
					lgr.dec_indent()

	return to_return


func log_the_final_line(totals, gut):
	var lgr = gut.get_logger()
	var grand_total_text = ""
	var grand_total_fmt = lgr.fmts.none
	if(totals.failing_tests > 0):
		grand_total_text = str(totals.failing_tests, " failing tests")
		grand_total_fmt = lgr.fmts.red
	elif(totals.risky > 0 or totals.pending > 0):
		grand_total_text = str("All tests passed but there are ", totals.risky + totals.pending, " pending/risky tests.")
		grand_total_fmt = lgr.fmts.yellow
	else:
		grand_total_text = "All Tests Passed!"
		grand_total_fmt = lgr.fmts.green

	lgr.log(str("---- ", grand_total_text, " ----"), grand_total_fmt)


func log_totals(gut, totals):
	var lgr = gut.get_logger()
	var orig_indent = lgr.get_indent_level()
	lgr.set_indent_level(0)
	_log_totals(gut, totals, lgr)
	lgr.set_indent_level(orig_indent)


# For backwards compat, this will use the collector set.  It was just a lot
# easier to use a local var than pass more things around.
func get_totals(gut=_gut):
	var test_collector = gut.get_test_collector()
	var lgr = gut.get_logger()

	var totals = {
		passing = 0,
		pending = 0,
		failing = 0,
		risky = 0,
		tests = 0,
		scripts = 0,
		passing_tests = 0,
		failing_tests = 0,

		errors = lgr.get_errors().size(),
		warnings = lgr.get_warnings().size(),
		deprecated = lgr.get_deprecated().size()
	}

	for s in test_collector.scripts:
		# assert totals
		totals.passing += s.get_pass_count()
		totals.pending += s.get_pending_count()
		totals.failing += s.get_fail_count()

		# test totals
		totals.tests += s.tests.size()
		totals.passing_tests += s.get_passing_test_count()
		totals.failing_tests += s.get_failing_test_count()
		totals.risky += s.get_risky_count()

	totals.scripts = test_collector.scripts.size()

	return totals


func log_end_run(gut=_gut):
	_log_end_run_header(gut)

	var totals = get_totals(gut)
	var tc = gut.get_test_collector()
	var lgr = gut.get_logger()

	log_all_non_passing_tests(gut)
	log_totals(gut, totals)
	lgr.log("\n")

	_log_orphans_and_disclaimer(gut)
	lgr.log(str("Tests finished in ", gut.get_elapsed_time(), 's'))
	_log_what_was_run(gut)
	log_the_final_line(totals, gut)
	lgr.log("")
