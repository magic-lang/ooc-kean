#!/bin/bash
export OOC_LIBS=$(dirname `pwd`)
ARGS=""
FAILED=false
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
for TEST in $TESTS
do
	if [[ !( $1 == "nogpu" && $TEST == *"/gpu/"* ) ]]
	then
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
			FAILED=true
		fi
		rm -f $NAME
	fi
done
if [ $FAILED ]
then
	exit 1
else
	exit 0
fi
