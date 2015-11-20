#!/bin/bash
valgrind --log-file=memcheck.valgrindlog --suppressions=./kean.supp --num-callers=500 --time-stamp=yes ./Tests -n $@
