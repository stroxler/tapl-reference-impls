# Arith language

Ocaml implementation of untyped arithmetic.

I've added to the original Makefile-based build
a dune based build as well.

You can build and run using either one, the commands
have been collected into scripts `run-with-dune.sh`
and `run-with-make.sh` - the biggest gotcha is that
dune will crash if you don't make clean, because the
make-based build pollutes the working directory with
output files, and in particular the generated lexer
and parser `.ml` files confuse dune.
