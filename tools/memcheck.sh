#!/bin/bash
valgrind --leak-check=full --log-file=memcheck.valgrindlog --num-callers=500 --time-stamp=yes ./Tests -n $@
