#!/bin/bash
if [ "$#" = 0 ]; then
    echo "Illegal number of arguments. Please pass correct exercise name."
    exit 1
fi
mkdir -p build
cd build
cmake .. > /dev/null
make $1 > /dev/null
if [ "$1" = "ex1" ] || [ "$1" = "ex2" ] || [ "$1" = "ex6" ]; then
    pdirun mpirun -n 1 ./$1
fi
if [ "$1" = "ex3" ]; then
    pdirun mpirun -n 1 ./$1 
    echo
    h5dump $1.h5
fi
if [ "$1" = "ex4" ]; then
    pdirun mpirun -n 2 ./$1
    echo 
    h5dump $1-data0x0.h5
    echo "------------------------------------------------------------------------------------------"
    h5dump $1-data1x0.h5
    echo "------------------------------------------------------------------------------------------"
    h5dump $1-meta0x0.h5
    echo "------------------------------------------------------------------------------------------"
    h5dump $1-meta1x0.h5
fi
if [ "$1" = "ex5" ]; then
    pdirun mpirun -n 1 ./$1
    echo
    h5dump $1-data0x0.h5
    echo "------------------------------------------------------------------------------------------"
    h5dump $1-meta0x0.h5
fi
if [ "$1" = "ex7" ] || [ "$1" = "ex8" ]; then
    pdirun mpirun -n 1 ./$1
    echo
    h5dump $1-data0x0.h5
fi
if [ "$1" = "ex9" ]; then
    if [ -z "$2" ]; then
        echo "Illegal number of processes. Please add second argument."
        exit 1
    fi
    pdirun mpirun -n $2 ./$1
    echo
    h5dump $1.h5
fi
