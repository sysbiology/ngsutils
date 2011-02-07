#!/bin/bash

usage(){
    echo "Fetches dependencies required for working with BAM files"
    echo ""
    echo "Dependencies:"
    echo "  Cython"
    echo "  pysam"
    echo ""
    echo "Usage: `basename $0`"
    echo ""
    exit 1
}

control_c() {
    rm -rf `dirname $0`/ext/*
    exit 1
}

if [ "$1" == "-h" ]; then
    usage
fi

if [ -e "`dirname $0`/ext/pysam" ]; then
    exit
fi

trap control_c SIGINT

echo "[depends] Downloading and building dependencies..." >&2

WORK=`dirname $0`/ext/work
mkdir -p $WORK
cd $WORK
rm -rf *

python -c "import Cython" > /dev/null
if [ $? -ne 0 ]; then
    echo "[cython] downloading" >&2
    curl -sLO "http://pypi.python.org/packages/source/C/Cython/Cython-0.14.1.tar.gz"
    tar zxf Cython-0.14.1.tar.gz
    cd Cython-0.14.1
    echo "[cython] building" >&2
    python setup.py build &>> $WORK/build.log
    python setup.py install --user &>> $WORK/build.log
    cd ..
fi

echo "[pysam] downloading" >&2
curl -sLO "http://pysam.googlecode.com/files/pysam-0.3.1.tar.gz"
tar zxf pysam-0.3.1.tar.gz
cd pysam-0.3.1
echo "[pysam] building" >&2
python setup.py build &>> $WORK/build.log

cp -r build/lib*/pysam ../..
cp build/lib*/*.so ../../pysam
echo "Done!" >&2
echo "" >&2

