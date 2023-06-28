# Record subtyping + Top and Bottom

This implementation is a fairly minimal STLC with top, bottom,
and records with record subtyping.

It is a good place to look if you want to focus on just the
typing semantics for simple subtyping, since it includes all the
subtyping features outlined in most of TAPL (everything
except nominal subtypes) in a minimal form.

## Relationship to other subtying implementations

- The `bot` implementation is even more minimal, with just Top and
  Bottom; it's a better place to understand how subtyping is *used*
  in type checking without having to deal with a more complex
  *implementation*
- The `fullsub` implementation is a "full" STLC with record subtyping
  and Top, but without Bot.
- The chapter 13 and 14 implementations also involve subtyping:
  - Chapter 14 (fullerror) is a stripped down STLC with top and bottom
    plus an error form where error is treated as the bottom type.
  - Chapter 13 (fullref) is a full STLC with top, bottom, and record
    subtyping plus mutable refs.

For the most part `fullref` is actually the most evolved of the simple
subtyping implementations; it serves as the basis for Chapter 18
on embedding imperative objects in a STLC with refs.
