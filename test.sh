#!/bin/bash
export OOC_LIBS=$(dirname `pwd`)
ARGS=""
if [ -e rock_arguments.txt ]
	then
		ARGS=$(cat rock_arguments.txt)
fi
FLAGS=${@:2}
TESTS=$@
case "$1" in
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
for TEST in $TESTS
do
	OUTPUT=$(rock -q -lpthread --gc=off $ARGS $FLAGS $TEST 2>&1 )
	if [[ !( $? == 0 ) ]]
	then
		echo -e $OUTPUT
		echo "Compilation failed of test: $TEST"
		exit 2
	fi
	NAME=${TEST##*/}
	NAME=${NAME%.*}
	#echo $TEST
	./$NAME
	if [[ !( $? == 0 ) ]]
	then
		echo "Failed test: $TEST"
		exit 1
	fi
	rm -f $NAME
done
exit 0
