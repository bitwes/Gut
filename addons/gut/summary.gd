# ------------------------------------------------------------------------------
# Prints things mostly.
# ------------------------------------------------------------------------------
# a _test_collector to use when one is not provided.
var _collector = null


func _init(tc = null):
	_collector = tc

# ---------------------
# Private
# ---------------------
func _count_tests_and_log_non_passing_tests(test_collector, lgr):
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


func _log_totals(test_collector, lgr):
	# just picked a non-printable char, dunno if it is a good or bad choice.
	var npws = PackedByteArray([31]).get_string_from_ascii()
	lgr.log()
	var totals = get_totals(test_collector)
	lgr.log("Totals", lgr.fmts.yellow)
	lgr.log(str('Scripts:          ', test_collector.scripts.size()))
	lgr.log(str('Passing Tests     ', totals.passing_tests))
	lgr.log(str('Failing Tests     ', totals.failing_tests))
	lgr.log(str('Risky Tests       ', totals.risky))
	var pnd=str('Pending Tests     ', totals.pending)
	# add a non printable character so this "pending" isn't highlighted in the
	# editor's output panel.
	lgr.log(str(npws, pnd))
	lgr.log(str('Asserts:          ', totals.passing, ' of ', totals.passing + totals.failing, ' passed'))

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

	return totals

# ---------------------
# Public
# ---------------------
func log_summary(test_collector, lgr):
	var orig_indent = lgr.get_indent_level()
	var found_failing_or_pending = false

	var pass_no_pass_counts = _count_tests_and_log_non_passing_tests(test_collector, lgr)
	lgr.set_indent_level(0)

	_log_totals(test_collector, lgr)
	lgr.set_indent_level(orig_indent)


# For backwards compat, this will use the collector set.  It was just a lot
# easier to use a local var than pass more things around.
func get_totals(test_collector=_collector):
	var totals = {
		passing = 0,
		pending = 0,
		failing = 0,
		risky = 0,
		tests = 0,
		scripts = 0,
		passing_tests = 0,
		failing_tests = 0
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
