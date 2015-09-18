tmp="$(wget -O - https://github.com/cogneco/magic/releases/latest | grep -o -m 1 '\<download/.*tar.gz\>')"
wget https://github.com/cogneco/magic/releases/$tmp
echo ${tmp##*/}
tar zxvf ${tmp##*/}
