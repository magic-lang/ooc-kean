#!/bin/bash
INFO_FILE="test_coverage.info"
ARGS=$@

if [ $# -eq 0 ];
then
	ARGS="all"
fi

./test.sh $ARGS -x +--coverage +-O0
lcov --quiet -t 'OOC Test coverage' -o $INFO_FILE -c --directory ./.libs/ooc/ --base-directory .
lcov --quiet --remove test_coverage.info '/rock_tmp/*' -o test_coverage.info
lcov --quiet --remove test_coverage.info '/test/*' -o test_coverage.info

rm -r coverage/
genhtml --quiet -o coverage $INFO_FILE --num-spaces 4

if which xdg-open > /dev/null
then
	xdg-open 'coverage/index.html'
elif which gnome-open > /dev/null
then
	gnome-open 'coverage/index.html'
else
	echo "Could not detect the web browser to use."
fi
