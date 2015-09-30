#!/bin/bash
export OOC_LIBS=$(dirname `pwd`)
ARGS=""
FAILED=false
TEST_DIRECTORY="./test"
SOURCE_DIRECTORY="./source"
TESTS_USE_FILE="tests_generated.use"
TESTS_SOURCE_FILE="tests_generated.ooc"
if [ -e rock_arguments.txt ]
	then
		ARGS=$(cat rock_arguments.txt)
fi
FLAGS=${@:2}
TESTS=$@
case "$1" in
	"nogpu")
		;&
	"")
		;&
	"all")
		TESTS="./test"
		;;
	*)
		TESTS="./test/$1"
		;;
esac
if [[ -d $TESTS ]]
then
	TESTS=$(find $TESTS -name "*Test.ooc")
else
	TESTS=$TESTS"Test.ooc"
fi
echo "SourcePath: ." > "$TESTS_USE_FILE"
echo "use ${TESTS_USE_FILE%.*}" > "$TESTS_SOURCE_FILE"
echo "main: func {" >> "$TESTS_SOURCE_FILE"
for TEST in $TESTS
do
	if [[ !( $1 == "nogpu" && $TEST == *"/gpu/"* ) ]]
	then
		echo "Imports: ${TEST%.*}" >> "$TESTS_USE_FILE"
		echo "    $(basename ${TEST%.*}) new() run()" >> "$TESTS_SOURCE_FILE"
	fi
done
echo "   exit(0)" >> "$TESTS_SOURCE_FILE"
echo "}" >> "$TESTS_SOURCE_FILE"
echo "Main: $TESTS_SOURCE_FILE" >> "$TESTS_USE_FILE"
rock -q -lpthread --gc=off -r $ARGS $FLAGS $TESTS_USE_FILE 2>&1
if [ "$FAILED" = true ]
then
	exit 1
else
	exit 0
fi
