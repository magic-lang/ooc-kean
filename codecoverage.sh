#!/bin/bash
INFO_FILE="test_coverage.info"
ARGS=$@

if [ $# -eq 0 ];
then
	ARGS="all"
fi

./test.sh $ARGS -x +--coverage +-O0
lcov --quiet -t 'OOC Test coverage' -o $INFO_FILE -c --directory ./.libs/ooc/ --base-directory .
genhtml --quiet -o coverage $INFO_FILE --num-spaces 4
rm $INFO_FILE

if which xdg-open > /dev/null
then
	xdg-open 'coverage/index.html'
elif which gnome-open > /dev/null
then
	gnome-open 'coverage/index.html'
else
	echo "Could not detect the web browser to use."
fi
