# An extended STLC with record subtyping + a Top type

This implementation covers record subtyping with a Top type but *not* a bottom
type, and is built on top of the "full" extended STLC

## Relationship to other subtyping implementations

The other two chapter 17-specific implementations are both based on a more
"bare" STLC and include a bottom type as well as top:
- `bot` is a bare STLC with top and bottom; it's close to the simplest
  possible implementation of core subtyping logic
- `rcdsubbot` is like `bot` but with the addition of records to the runtime
  and record subtyping in the type system.

In addition, the Chapter 13 and 14 implementations actually include subtyping
rules from Chapter 17:
- `fullerror` is a bit misnamed; it's a relatively minimal STLC rather than
  a full one with some subtyping features and the use of `Top` for errors
  as discussed in Section 15.4.
- `fullref` is a full STLC with top and bottom types + refs.

Note that `fullref` in some sense actually subsumes all of the subtyping-only
implementations because it contains record subtyping with top and bottom (a
superset of all the subtyping-specific details) on top of a full STLC
with the addition of `ref`.

Since objects tend to be used in imperative code, the addition of `ref`
in `fullref` means it's actually the ideal implementation, from among
these choices, for playing with subtyping. Chapter 18 is probably best
approached in the context of `fullref`; the book explicitly says to
use fullref at the end of Section 18.1.

