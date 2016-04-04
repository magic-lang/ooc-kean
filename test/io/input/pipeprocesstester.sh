#!/bin/bash
rm -f "test/io/output/sum.txt"
echo "$1 $2" > "test/io/output/sum.txt"

for i in `seq 1 16`
do
	echo "$i"
	echo "$1"
done
