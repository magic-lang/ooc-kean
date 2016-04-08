#!/bin/bash
export OOC_LIBS=$(dirname `pwd`)
ARGS=""
TESTS_USE_FILE="tests.use"
if [[ -e rock_arguments.txt ]]
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
FEATURES=""
if [[ $1 == "nogpu" ]]
then
	FEATURES=$FEATURES" -DgpuOff"
fi
if [[ -d $TESTS ]]
then
	TESTS=$(find $TESTS -name "*Test.ooc")
else
	TESTS=$TESTS"Test.ooc"
fi

echo "SourcePath: ." > "$TESTS_USE_FILE"
for TEST in $TESTS
do
	if [[ !( $1 == "nogpu" && $TEST == *"/gpu/"* ) ]]
	then
		echo "Imports: ${TEST%.*}" >> "$TESTS_USE_FILE"
	fi
done
echo "Main: ./test/Tests.ooc" >> "$TESTS_USE_FILE"
rm -f .libs/tests-linux64.*

rock -q +-Wall $ARGS $FLAGS $FEATURES $TESTS_USE_FILE
exitcode=$?
if [[ $exitcode -eq 0 && -f ./Tests ]]
then
	./Tests
	exitcode=$?
fi
exit $exitcode
