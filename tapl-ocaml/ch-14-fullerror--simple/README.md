# Simple error implementation (named `fullerror`)

In spite of the name, this is actually just `simplebool` with error
handling (unlike, say, `fullref` which is references on top of the
"fullsimple" enriched STLC).

The examples unfortunately don't include any try/with statements
out of the box.

I would definitely like to come back and add some later.

The implementation is based on the "simpler" untagged errors described
in the first part of the chapter; I guess it would make a good exercise
to change to support for the "tagged" error style described in the later
part of Chapter 14.


## An extension: ocaml-style exceptions

It's worth noting that actual ocaml errors overlap with subtyping (and
I think the design is somewhat reasonable) because there's a base
exception type that is throwable, and custom exceptions can have arbitrary
shape but are treated as subtypes... the catch construction is a with
clause that allows partial matching.

Reproducing this might be interesting, but requires figuring out how
to represent the subtyping-like part of the logic.
