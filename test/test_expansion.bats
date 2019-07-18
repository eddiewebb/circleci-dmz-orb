#!/usr/bin/env bats

# load custom assertions and functions
load bats_helper


# setup is run beofre each test
function setup {
  INPUT_PROJECT_CONFIG=${BATS_TMPDIR}/input_config-${BATS_TEST_NUMBER}
  PROCESSED_PROJECT_CONFIG=${BATS_TMPDIR}/packed_config-${BATS_TEST_NUMBER} 
  JSON_PROJECT_CONFIG=${BATS_TMPDIR}/json_config-${BATS_TEST_NUMBER} 
	echo "#using temp file ${BATS_TMPDIR}/"

  # the name used in example config files.
  INLINE_ORB_NAME="dmz"
}


@test "Command: full job expands properly (dynamic keyscan)" {
  # given
  process_config_with test/inputs/simple.yml

  # when
  assert_jq_match '.jobs | length' 1
  assert_jq_match '.jobs["build"].steps | length' 5
  assert_jq_match '.jobs["build"].steps[3].run.command' 'ssh -4 -L 9001:104.154.89.105:80 -Nf ubuntu@ec2-18-191-19-150.us-east-2.compute.amazonaws.com || true'
  assert_jq_contains '.jobs["build"].steps[2].run.command' 'ssh-keyscan ec2-18-191-19-150.us-east-2.compute.amazonaws.com >> ~/.ssh/known_hosts'
}

@test "Command: full job expands properly (explicit key)" {
  # given
  process_config_with test/inputs/public_key_file.yml

  # when
  assert_jq_match '.jobs | length' 1
  assert_jq_match '.jobs["build"].steps | length' 5
  assert_jq_match '.jobs["build"].steps[3].run.command' 'ssh -4 -L 9001:104.154.89.105:80 -Nf ubuntu@ec2-18-191-19-150.us-east-2.compute.amazonaws.com || true'
  assert_jq_contains '.jobs["build"].steps[2].run.command' 'KEY_VALUE=`cat somefile`'
  assert_jq_contains '.jobs["build"].steps[2].run.command' 'KEY_VALUE=`echo "somefile"`'
  assert_jq_contains '.jobs["build"].steps[2].run.command' 'echo "ec2-18-191-19-150.us-east-2.compute.amazonaws.com ${KEY_VALUE}" >> ~/.ssh/known_hosts'
}
