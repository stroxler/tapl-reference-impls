# Bot: the simplest Top + Bottom lattice

This is a bare-bones STLC with the top and bottom types added. It's a great way
to study the essence of subtyping without any of the noise coming from actual
subtype checks.

## Relationship to the other Chapter 17 implementations

Note that Exercise 17.3.2 asks students to add Bot to the more-complex
record-subtyping implementation; one way to do this is to unify the evaluation
and subtyping logic here with what's in the `fullsub` codebase, which is an
extended STLC with record subtyping + a top type; there actually doesn't appear
to be an `rcdsub` codebase anywhere in the official sources.

There is also an `rcdsubbot` which is basically the solution to that exercise;
it is a minimal STLC with the addition of:
- records
- record subtyping
- top and bottom types

Finally, both the "ref" implementation (Chapter 13) and "error" implementation
(Chapter 14) are actually written to reflect subtyping, rather than implementing
the bare-bones typing rules presented in Chapters 13 and 14 of the book.
