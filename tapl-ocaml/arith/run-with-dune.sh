#!/usr/bin/env sh

# Make sure none of the Makefile artifacts pollute
# the current directory
make clean

# Run the program
dune exec ./main.exe test.f
