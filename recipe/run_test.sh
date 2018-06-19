#!/bin/bash

export PYPY3=$(which pypy3)

ldd $PYPY3

ldd $(dirname "$PYPY3")/../lib/libpypy3-c.so
