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


## What is TyVar?

I was pretty confused when I first saw `TyVar`, becaus it doesn't
really mean a type variable (this isn't polymorphic yet!).

The answer is that it represents a pointer to a "global" type;
this idea gets introduced by the `TyVarBind`. Whenever we have
a type annotation that is an upper-case identifier (UCID), we
ask whether that name is currently bound and if so we create
a TyVar pointing to it.

You can see this best if you look at two things:
- The `UCID TyBinder` branch of the `Command` parser, which
  winds up producing either a `TyVarBind` or a `TyAbbBind`
- The evalbinding code, which leaves type bindings as-is
- The `simplifyty` code which:
  - if all types are valid abbreviations (TyAbbBind), will
    resolve them all recursively
    - Note that if an unbound type name was used anywhere,
      it will resolve to an opaque `TyId` because that's what
      the UCID case of the parser for `AType` produces.
  - if it ever hits an unresolvable type (given the `TyId` logic
    above this would only happen when we find a valid
    `TyVarBind` binding), it terminates evaluation leaving the
    `TyVar` as is.

### `TyVar` pointing to a `TyVarBind` vs `TyId`

The `tyequiv` handles the two "unresolved-to-concrete-type"
cases of an unresolved `TyVar` (which happens when an opaque
global type is used) and `TyId` (which happens when an undeclared
type is used) in roughly the same way: if the bindings are the same
(where we can think of `TyId` as a binding to some negative stack
index representing undeclared types) they are the same.

This logic feels messy, the `TyId` and unresolvable `TyVar`
seem to be treated similarly but by incredibly different code
branches because of the De Brujin global index vs bare name
representation.


## Records and Variants

TODO: I should write some notes on how exactly the dispatching
happens here, and also add some examples of variants (the current
`test.f` only has records). I think the rules are probably pretty
obvious, but the code is nontrivial to skim.
