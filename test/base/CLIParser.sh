#!/bin/bash
rock -v -r CLIParserTest.ooc 
#./CLIParserTest -v -r --gc=off --lphtread -m message -z -n 23
#./CLIParserTest -v -r --gc=off --lpthread -z
./CLIParserTest --version --run --gc=off  --message message1 -z -n 23 -p /vidproc/imageFiles/ --path /vidproc/imageFiles/ -l 3 --level 4
