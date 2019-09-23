#!/bin/bash

set -e
if [ $TRAVIS_DART_VERSION -ne 1.24.3 ]
then
    dartfmt --set-exit-if-changed -w .
fi
dartanalyzer lib test
pub run dependency_validator
pub run test
