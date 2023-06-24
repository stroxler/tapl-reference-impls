# The STLC with booleans

This is the most basic STLC implementation provided (it's possible to make one
with just functions, but the book authors opted to only do that for the untyped
lambda calculus).

Chapter 10 goes through how this works in terms of theory.

### Highlights from the chapter

The main highlight is that the typing rules, while they do follow from
the inference rules (Figure 9-1), are more properly considered a translation
of the typing inversion lemma 9.3.1.

To the extent that you want to focus on understanding the relationship between
type inference rules and a practical type checker implementation, focusing
on the process of creating an inversion lemma is the way to go; this can be
nontrivial in more complex type systems.

## bindings in this STLC

### Global bindings (VarBind produced by the parser)

I noticed that the untyped lambda calculus allows bare NameBind, which lets us
basically create variables that don't evaluate to anything in global scope.

In the STLC this is no longer allowed, which makes much more sense to me - all
globals have to have a type (only VarBind can actually be constructed by the
parser, the NameBind binding is an implementation detail).

Also, it appears to me we lost the ability to actually set a term (i.e. a value)
when we define a global - the `VarBind` constructor used to take a term as input
but now it is *just* a type with no term. This seems strange, but I think it may
be because the focus is on typing and from that point of view we only really
need typed globals (and let bindings, which we add in Chapter 11, solve most of
the resulting annoyance making runnable examples).

... Actually after a closer look, only `fulluntyped` supported top-level binds
of actual terms. The bare-bones `untyped` implementation only had `NameBind`;
all you could do was define top-level names that evaluated to themselves (plus
the parser used `NameBind` internally to build the lookup stack for making
DeBrujin indices). And the binding type in that case was `TmAbbBind`, which
is indeed present in the "full" typed lambda calculi.

You're allowed to use globals with no definition, evaluation just terminates (in
non-normal form) when you get there; I added the example code
```
bool_func: Bool->Bool;
bool_func true;
```
to `test.f` to illustrate this; the evaluator just prints out `bool_func true:
Nat` when it hits the second line.

### The use of VarBind in type checking

If you look at the `Core.typeof` function, it uses `addbinding` in the
type check for TmAbs. This is because unlike our weird substitution-based
evaluator, type checking uses a standard environment model:
- inside type check all names are De Brujin indexed
- there are no rewrites - the indices are exactly as they come out of
  the parser (i.e. as lexical scope stack offsets), similar to in `clox`.
- because we build up an environment of static, lexical scopings as we
  type check, we can actually look up each variable. All the bindings
  in the stack for type checking are `VarBind`, so they all contain a type
  (the ocaml types don't enforce this, but it's true).
  - globals are actually handled dynamically which is a little weird,
    because type check happens per-command using the existing context.
    But it winds up working out just fine, because the bottom of the
    stack will just have all the globally-bound names + types

### Okay, why do we have `NameBind` at all?

We know that the parser will always produce a `VarBind` in the AST
because we'll need types both at evaluation of top-level bindings and
when we type check functions. And the type checker always uses `VarBind`
to preserve the arg type when extending the context as it checks functions.

So why do we have `NameBind`?

We use it in contexts where the types don't matter. There are two of these:
- in the parser, we use `NameBind` to build up the *parsing* context (which
  is 1:1 with a later type check context but isn't actually the same data,
  the parsing context only has names without types). You can see this
  in the use of `addname` for parse rules on both top-level bindings and
  lambdas.
- In the printing code, we generate names on the fly for functions when
  there are clashes with the context by using `pickfreshname`
  - This is necessary because

There's an irony here: after all the work to get substitution with De Brujin
indices working - which is lots of complicated integer arithmetic - we wind up
reproducing string-based substitution logic with an equivalent of `gensym` just
for printing
  - This happens because we have to handle the case where the name in a lambda
    clashes with a name bound further up.
    - The actual AST doesn't care, the De Brujin indices know "which one" of the
      names is actually intended.
    - But if we just look up the name and print it, we'll produce code that
      wouldn't parse back to itself.
  - This almost makes the whole De Brujin index nonsense feel like a waste
    of effort - the string-based substitution algorithm would work, and
    we need the tricky thing (`pickfreshname`) for printing anyway, so it
    feels almost academic.
    - The one big benefit, I suppose, is that you can compare two terms
      to see if they are the same up to alpha-equivalence more easily using
      De Brujin. But I don't think we ever actually do that.


## More thoughts on De Brujin indexes in substitution-based evaluation

I want to highlight the one thing I noticed that didn't jump out to me when I
wrote notes on the full untyped lambda calculus: at runtime, the context *only*
contains gobals.

I point this out because I talked about how we can think of De Brujin indices
from the parser as "lexical stack depths", and in fact an environment-based
evaluator like clox can basically just use them this way, with some gymnastics
around closure handling in the case where we don't want to persist.

But in a substitution-based evaluator, there's never actually a stack at all
except for globals (which ironically don't usually go on the stack in evaluation
models!), because instead of storing values to look up later in execution we are
always eagerly rewriting "the rest of the program" (on a term-by-term basis)
which means there is no need for a runtime stack.

As a result, as the rewrite-based execution progresses,
all De Brujin indices are either:
- Free in the current top-level expression, and therefore refer to the globals
  stack
- Or, bound in the current top-level expression and therefore not referring to a
  stack at all, other than a theoretical lexical scope stack.

This wasn't entirely obvious to me until now, but you can see by skimming the
code that `ctx` is never modified by expression evaluation, the only time it is
modified is when evaluating a Bind command (in `Main.process_command`)

## De Brujin indexes and environment evaluation

As I've noted earlier, De Brujin is actually more useful in environment-based
evaluation where it leads to efficient stack lookups.

I want to reiterate that we actually now do have a form of this - type checking
uses a static stack rather than a runtime stack, but we do in fact get the
full benefits of De Brujin indexing in our type checks.

One thing that I find weird about the substitution model for a type theory
book is that it actually doesn't map as cleanly - an environment model for evaluation
leads to type check and runtime evaluation working very similarly, where at runtime
a value environment plays roughly the same role as the static type environment. With
a substitution-based evaluator the connection is much less obvious.
