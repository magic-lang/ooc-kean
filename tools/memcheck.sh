#!/bin/bash
logFile="memcheck.valgrindlog"
valgrind --leak-check=full --log-file=$logFile --suppressions=./tools/kean.supp --num-callers=500 ./Tests -n $@
#Hello
grep -A5 LEAK $logFile | grep -v LEAK
grep -A4 Invalid $logFile

exit 0
