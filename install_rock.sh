tmp="$(wget -O - https://github.com/cogneco/rock/releases/latest | grep -o '\<download/rock_.*deb\>')"
wget https://github.com/cogneco/rock/releases/$tmp
echo ${tmp##*/}
dpkg-deb -x ${tmp##*/} .
mv usr/bin/rock .
mv usr/lib/fancy_backtrace.so .
