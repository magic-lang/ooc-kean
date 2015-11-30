#!/bin/bash
valgrind --log-file=memcheck.valgrindlog --num-callers=500 --time-stamp=yes ./Tests -n $@
