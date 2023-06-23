# The STLC with booleans

This is the most basic STLC implementation provided
(it's possible to make one with just functions, but
the book authors opted to only do that for the untyped
lambda calculus).

Chapter 10 goes through how this works, so I just
want to highlight the one thing I noticed that didn't
jump out to me when I wrote notes on the full untyped
lambda calculus: at runtime, the context *only* contains
gobals.

I point this out because I talked about how we can think
of De Brujin indices from the parser as "lexical stack
depths", and in fact an environment-based evaluator like
clox can basically just use them this way, with some
gymnastics around closure handling in the case where we don't
want to persist.

But in a substitution-based evaluator, there's never
actually a stack at all except for globals (which ironically
don't usually go on the stack in evaluation models!),
because instead of storing values to look up later in
execution we are always eagerly rewriting "the rest of the
program" (on a term-by-term basis) which means there
is no need for a runtime stack.

As a result, as the rewrite-based execution progresses,
all De Brujin indices are either:
- Free in the current top-level expression, and therefore
  refer to the globals stack
- Or, bound in the current top-level expression and
  therefore not referring to a stack at all, other
  than a theoretical lexical scope stack.

This wasn't entirely obvious to me until now, but you can
see by skimming the code that `ctx` is never modified by
expression evaluation, the only time it is modified is
when evaluating a Bind command (in `Main.process_command`)
- 
