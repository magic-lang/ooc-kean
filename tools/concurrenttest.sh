#!/bin/bash
if [[ $# -lt 2 ]]
then
	echo "Must supply number of iterations and instances"
	exit 1
fi
iterations=$(($1))
instances=$(($2))

# Rebuild concurrent tests
echo "Rebuilding tests..."
./test.sh concurrent -x > /dev/null
rm -f concurrentresult

# Start stress if flag given
if [[ $* == *--stress* ]]
then
	echo "Running stress."
	stress -c 4 -i 4 -m 4 -d 4 -q &
fi

for (( j=1; j<=$iterations; j++ ))
do
	echo Iteration $j of $iterations with $instances instances

	for (( k=1; k<=$instances; k++ ))
	do
		./Tests > "concurrentdata$k" &
		pids[k]=$!
	done

	index=0
	for pid in ${pids[*]}
	do
		let index+=1
		wait $pid
		if [ $? -ne 0 ]
		then
			echo Error $?
			cat "concurrentdata$index"
			cat "concurrentdata$index" >> concurrentresult
		fi
	done
done

# Clean up and remove stress
rm -f concurrentdata*
if [[ $* == *--stress* ]]
then
	kill -9 $(pidof stress)
fi
