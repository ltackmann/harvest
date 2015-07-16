#!/bin/bash
set -e

# TODO broken
#pub run test test/harvest_file_test.dart 
#pub run test --platform=dartium test/harvest_idb_test.dart 
pub run test test/harvest_memory_test.dart 
pub run test test/harvest_message_test.dart 
