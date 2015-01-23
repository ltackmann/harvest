#!/bin/bash
set -e

dart test/cqrs_test.dart 
dart test/eventstore_test.dart
