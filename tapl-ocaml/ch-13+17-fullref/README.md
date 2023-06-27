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

## Typing: defer notes on this until chapter 15.

It appears to me that this implementation was actually written to support
not only Chapter 13 but also parts of Chapter 15, because there is some
subtyping support.

So I should not read the implementation in too much detail until I've looked at
simple subtyping.
