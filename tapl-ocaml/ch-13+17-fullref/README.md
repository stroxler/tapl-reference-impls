# Fullref implementation

## Runtime handling

The runtime of this is somewhat interesting because refs really don't play well
with term rewriting.

To get around this restriction (in a manner somewhat similar to the stack-based
lookup table for globals) the authors have to build a "store" table for the
ref contents. Most languages - or at least imperative languages - on the other
hand can implement references almost transparently by just allowing mutation
of that part of the environment; readonly vs mutable references can be in
principle a *purely* static-time type-enforced constraint.

A consequence of the need for a store is that `TmLoc` becomes a "term" that
can only exist at runtime, there's no way to write it in a user-controlled AST.
I find these weird artifacts of term rewriting (where we start having to extend
the AST with things that a user can't write down) to be one of the oddest
consequences of a rewriting-based evaluator. 

The evaluator now needs both a `ctx` (used to look up globals via the
"globals stack" and a `store` (used to look up refs by location).

The evaluation model is:
- `ref whatever` gets parsed into a `TmRef(_, term)`
- `TmRef(_, value)` evaluates to a `TmLoc(_, loc)` where the
  `loc` came from a side-effect of expanding the store
- `! whatever` gets parsed into a `TmDeref(_, term)`
- `TmDeref(TmLoc(_, loc))` evaluates to a store lookup

## Typing: references + subtyping (with variants, records, Top, and Bot)

This is really the cannonical implementation of not only references but
also subtyping. It is the most full-featured of the simple (non-polymorphic)
subtyping implementations, because it includes:
- a top and bottom type
- record subtyping
- variant subtyping

The interaction between references and typing is discussed in Section 15.5:
- invariance of simple references
- the introduction of the Source and Sink types constructers, originally
  introduced by Forsythe, to separate out the read behavior (which is
  covariant) and write behavior (which is contravariant) of references.

Note that the only way to actually introduce a sink or source is by ascribing
(upcasting) a ref, so we wind up with a type-level-only restriction for
read-only / write-only.

In terms of typing, the book points out that Sink and Source behave exactly
the same as endpoints of a channel (e.g. a go channel), as introduced by the
Pict language.

### The algorithms / metatheory / implementation notes

Subtyping algorithms (or at least the portion of them needed for the
slightly smaller `fullsub` implementation) are described in detail in
Section 16; the ML realization of them are discussed in Chapter 17.

## Usage: Chpater 18

The code in Chapter 18, for imperative objects embedded in the extended
STLC, is based on this implementation.

I'm probably going to defer going through this for now because I want
to get to recursive types and polymorphism reasonably quickly (since those
concepts are all important for Pyre), but it would be good to come back to
that chapter at some point.
