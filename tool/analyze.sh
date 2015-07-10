#!/usr/bin/env bash

EXIT_STATUS=0

# Find all sub-directories of the current directory with a pubspec.yaml and run dartanalyzer on it

directories=(`find . -name pubspec.yaml -print0 | xargs -0 -n1 dirname | sort --unique`)
rootDirectory=$(pwd)

for pubDirectory in ${directories[*]}
do
    if [ -d "$pubDirectory" ]
    then
        echo Analyze "'${pubDirectory}'"...
        cd "$pubDirectory"
        ANALYZE_DIRECTORIES=""
        subdirectories=( lib web test )
        for dir in "${subdirectories[@]}"
        do
        	if [ -d $dir ]
        	then
        		ANALYZE_DIRECTORIES="$ANALYZE_DIRECTORIES $dir/*.dart"
			fi
        done
		if [ -z "$ANALYZE_DIRECTORIES" ]
		then
			echo "nothing to analyze"
		else
			echo "dartanalyzer --fatal-warnings --no-hints $ANALYZE_DIRECTORIES"
			dartanalyzer --fatal-warnings --no-hints $ANALYZE_DIRECTORIES || EXIT_STATUS=$?
        fi
        echo "Current EXIT_STATUS = $EXIT_STATUS"
        cd "$rootDirectory"
        echo
    fi
done

exit $EXIT_STATUS