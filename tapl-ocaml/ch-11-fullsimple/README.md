# Notes on the `fullsimple` code

Mostly I think this code follows relatively easily from the code
for `fulluntyped` plus `simplebool`:
- It's a term-rewriting evaluator, which is weird but I've already
  discussed in quite some detail.
- The parser-generator doesn't actually output a parser to AST,
  but rather a parser to callbacks that will create an AST when
  invoked, giving it some of the flavor of a State or Reader monad;
  it uses this to build a stack of variable bindings to convert
  to De Brujin indices in a single parsing pass.

The one new insight I had is that if you want to understand normal
evaluation vs error conditions you need to compare `isval` with
the `NoRuleApplies` logic in `eval1`.
- We raise `NoRuleApplies` whenever we can't step
- A correct `eval1` *always* steps if it can; the match statements
  always step the "next" sub-term until it is a value (this might
  be more explicit if we used CPS)
- It's expected that `eval1` throws if the overall form is a value,
  but otherwise we should be stepping the next sub-term
- "Stuck" code means we thrwe a `NoRuleApplies` but we *don't*
  have a value according to `isval`.
  - Our code might keep going, because as a learning tool it's
    intended to handle some stuck cases by just dumping the stuck
    term.
  - But a "normal" interpreter would fail when it hits a case
    like this. And safety means precisely that well-typed code
    won't hit this code (up to some "scope" of safety which varies)

Here I'll add some notes on the biggest new ideas we run into.

## What are `TmInert` and `TyId`

`TmInert` lets us write a "typed hole" by specifying a type name
in square brackets. This lets us check complex typing rules
without actually needing an implementation to get a value of
the type in question.

`TyId` lets us use a not-yet-bound uppercase identifier as
a type which has no actual computational content; the only ways
I can see to actually create a value of this type are to:
- derive them from a term of some more complex type, e.g.
  a lambda returning this type or a record containing it
- or, use a typed hole via `TmInert`

Evaluation will end when we try to evaluate `tmInfo`, but
it isn't a value. (By this I mean it raises a NoRuleApplies,
but fails the `isvalue` check).

This isn't actually discussed in the book as far as I can tell,
I think it may be here largely as a convenience for trying out
complex examples without needing tons of boilerplate.

TODO: make some examples of this! Currently `test.f` doesn't have
any.
