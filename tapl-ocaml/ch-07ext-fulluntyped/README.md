# "Full" untyped lambda calculus with primitives

This actually isn't discussed directly in the book, but it
is the untyped lambda calculus' extension of the "extended"
simply-typed-lambda-calculus described in Chapter 11 of
the book.

It extends the untyped lambda calculus with:
- primitive types bool / int / float / string
  - the strings and floats are native
  - the ints remain from-scratch unary representations
    as in the untyped arithmetic example
- record types
- projection terms (attribute access, in oop lingo) 
- basic control flow: if and let

Weirdly there's only multiplication for floats, no
addition!
