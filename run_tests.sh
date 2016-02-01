#!/bin/bash
set -e

# TODO figure out how to test GUI code on Travis
#pub run test --platform=dartium test/harvest_idb_test.dart 
pub run test --platform=content-shell test/harvest_idb_test.dart

if [ "$COVERALLS_TOKEN" ]; then
  # run tests on travis and publish code coverage
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token $COVERALLS_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/all.dart
else
  # run tests locally
  dart --checked test/all.dart
fi
