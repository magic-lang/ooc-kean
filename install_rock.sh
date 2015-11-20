#!/bin/bash
if [ "$(uname -o)" == "Msys" ]; then
	latest="$(wget -O - https://github.com/cogneco/rock/releases/latest | grep -o '\<download/rock_.*zip\>')"
	wget https://github.com/cogneco/rock/releases/$latest
	echo ${latest##*/}
	7z e ${latest##*/}
else
	latest="$(wget -O - https://github.com/cogneco/rock/releases/latest | grep -o '\<download/rock_.*deb\>')"
	wget https://github.com/cogneco/rock/releases/$latest
	echo ${latest##*/}
	dpkg-deb -x ${latest##*/} .
	mv usr/bin/rock .
	mv usr/lib/fancy_backtrace.so .
fi
