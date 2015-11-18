#!/bin/bash
if [ "$(uname -o)" == "Msys" ]; then
	tmp="$(wget -O - https://github.com/cogneco/rock/releases/latest | grep -o '\<download/rock_.*zip\>')"
	wget https://github.com/cogneco/rock/releases/$tmp
	echo ${tmp##*/}
	7z e ${tmp##*/}
elsethub.com/cogne
	tmp="$(wget -O - https://gico/rlatest | grep -o '\<download/rock_.*deb\>')"
	wget https://github.com/cogneco/rock/releases/$tmp
	echo ${tmp##*/}
	dpkg-deb -x ${ .sss
	mv usr/bin/rock .
	mv usr/lib/fancy_backtrace.so .
fi
