#!/bin/sh

if [ -d "./lcov_report" ]; then
    rm -rf ./lcov_report
fi
if [ -f "./lcov_coverage.lcov" ]; then
    rm ./lcov_coverage.lcov
fi

pub get
pub run dart_codecov_generator:generate_coverage test/fluri_test.dart