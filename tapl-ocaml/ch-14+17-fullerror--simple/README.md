# Simple error implementation (named `fullerror`)

In spite of the name, this is actually just `simplebool` with error
handling (unlike, say, `fullref` which is references on top of the
"fullsimple" enriched STLC) plus a bottom type that lets us
include placeholder logic for subtyping.

The examples unfortunately don't include any try/with statements
out of the box.

I would definitely like to come back and add some later.

The implementation is based on the "simpler" untagged errors described
in the first part of the chapter; I guess it would make a good exercise
to change to support for the "tagged" error style described in the later
part of Chapter 14.

## Why is there subtyping here?

The subtyping isn't actually useful, we just have a top and bottom type so it's
sort of silly; the actual Chapter 14 code has subtyping-free rules for a type
checker.

I think the rationale here is that they wanted to illustrate an idea
from Chapter 15, that a bottom type can be a nice way of typing errors
more concretely - if you look at the typing rules they do *not* reflect
Chapter 14, instead the `error` term is of type `TyBot` and a try / with
uses a `join` to unify types (which might produce `Top` if the branches
have unrelated types).

## An extension: ocaml-style exceptions

It's worth noting that actual ocaml errors overlap with subtyping (and
I think the design is somewhat reasonable) because there's a base
exception type that is throwable, and custom exceptions can have arbitrary
shape but are treated as subtypes... the catch construction is a with
clause that allows partial matching.

Also ocaml's error typing rules are written in a way that is neither
like Chapter 14's rigid types *nor* like this subtyping approach; instead
an exception is parametrically polymorphic over its return type so that
the unifier can set it to anything needed based on context. I think that
approach is nicer, but it relies on a mechanism that (I think?) is similar
to the let polymorphisim in Chapter 22.

Reproducing this might be interesting, but requires figuring out how
to represent the subtyping-like part of the logic.
