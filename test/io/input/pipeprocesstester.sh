#!/bin/bash
sum_to () (
    set -- $(seq $1)
    IFS=+
    echo "$*" | bc
)

for i in `seq 1 16`
do
	echo $i
	sum=$(sum_to $1)
	echo $sum
done

echo "$sum $2" > "test/io/output/sum.txt"
