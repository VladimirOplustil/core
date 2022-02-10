#!/usr/bin/env bash

if [ -n "${EXPECTED_FAILURES_FILE}" ]
then
	if [ -f "${EXPECTED_FAILURES_FILE}" ]
	then
		echo "Checking expected failures in ${EXPECTED_FAILURES_FILE}"
	else
		echo "Expected failures file ${EXPECTED_FAILURES_FILE} not found"
		echo "Check the setting of EXPECTED_FAILURES_FILE environment variable"
		exit 1
	fi
	# If the last line of the expected-failures file ends without a newline character
	# then that line may not get processed by some of the bash code in this script
	# So check that the last character in the file is a newline
	if [ $(tail -c1 "${EXPECTED_FAILURES_FILE}" | wc -l) -eq 0 ]
	then
		echo "Expected failures file ${EXPECTED_FAILURES_FILE} must end with a newline"
		echo "Put a newline at the end of the last line and try again"
		exit 1
	fi
	# Check the expected-failures file to ensure that the lines are self-consistent
	FINAL_EXIT_STATUS=0
	while read INPUT_LINE
		do
			# Ignore comment lines (starting with hash)
			if [[ "${INPUT_LINE}" =~ ^# ]]
			then
				continue
			fi
			# Match lines that have [someSuite/someName.feature:n] - the part inside the
			# brackets is the suite, feature and line number of the expected failure.
			# Else ignore the line.
			if [[ "${INPUT_LINE}" =~ \[([a-zA-Z0-9-]+/[a-zA-Z0-9-]+\.feature:[0-9]+)] ]]; then
			  SUITE_SCENARIO_LINE="${BASH_REMATCH[1]}"
			else
			  continue
			fi
			# Find the link in round-brackets that should be after the SUITE_SCENARIO_LINE
			if [[ "${INPUT_LINE}" =~ \(([a-zA-Z0-9:/.#-]+)\) ]]; then
			  ACTUAL_LINK="${BASH_REMATCH[1]}"
			else
			  echo "Link not found in ${INPUT_LINE}"
			  FINAL_EXIT_STATUS=1
			  continue
			fi
			OLD_IFS=${IFS}
			IFS=':'
			read -ra FEATURE_PARTS <<< "${SUITE_SCENARIO_LINE}"
			IFS=${OLD_IFS}
			SUITE_FEATURE="${FEATURE_PARTS[0]}"
			FEATURE_LINE="${FEATURE_PARTS[1]}"
			EXPECTED_LINK="https://github.com/owncloud/core/blob/master/tests/acceptance/features/${SUITE_FEATURE}#L${FEATURE_LINE}"
			if [[ "${ACTUAL_LINK}" != "${EXPECTED_LINK}" ]]; then
			  echo "Link is not correct for ${SUITE_SCENARIO_LINE}"
			  echo "  Actual link: ${ACTUAL_LINK}"
			  echo "Expected link: ${EXPECTED_LINK}"
			  FINAL_EXIT_STATUS=1
			fi

		done < ${EXPECTED_FAILURES_FILE}
else
	echo "Environment variable EXPECTED_FAILURES_FILE must be defined to be the file to check"
	exit 1
fi

if [ ${FINAL_EXIT_STATUS} == 1 ]
then
	echo "Errors were found in the expected failures file - see the messages above"
fi
exit ${FINAL_EXIT_STATUS}
