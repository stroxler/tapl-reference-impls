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

### Where in the book are the algorithms / implementation discussed?

Subtyping algorithms (or at least the portion of them needed for the
slightly smaller `fullsub` implementation) are described in detail in
Section 16; the ML realization of them are discussed in Chapter 17.

## Typing implementation notes

### simplifyty and tyequiv: mostly the same as in `fullsimple`

The `simplifyty` function handles expanding abbreviations to their
canonical forms via `computety` which is not trivial, but I already have
notes on that in an earlier chapter.

The `tyeqv` function is basically just a recursive equality check, except that
`TyRecord` and `TyVariant` check for equality up to permutations (which implies
subtyping both directions, an equivalence but not necessarily "equality" if we
mean physical equality) rather than exact equality.
- Note that the distinction between equality and equivalence can be
  host-language representation-sensitive; if we used a map rather than an
  association list we could use a derived equality check here because equivalent
  types would be considered "equal" in ocaml.

### join and meet: "union" and "intersection" operations (sort of)

They are mutually recursive to handle contravariant cases.

- They begin with subtype checks, which handles equivalent types and all the
  primitive types out of the box so by the time we get to a match we have ruled
  those out.
- If that doesn't work, they `simplifyty` (which again expands type abbreviations)
  and then use a match to recurse...
- They recurse down most complex types, calling either the same operation
  `join`/`meet` or the opposite depending on covariance vs contravariance (for
  example, arrow flips the input but keeps the output the same)
- If they get stuck, they produce either `Top` for join or `Bot` for meet


The special cases that pop up are:
- The `Record` case is fully implemented:
  - `meet` takes the union of all labels and meets every component type
  - `join` takes the intersection of all labels and joins every component type
- The `Ref` type is invariant, and has an incomplete implementation that
  converts to `Source` or `Sink` if needed... I think it may be an exercise
  to finish this?
- The authors didn't implement `join` and `meet` for Variant in the non-subtyping
  case; I think it's possible to do so (`meet` would take the intersection of
  labels and take meet on all components, `join` would take the union of labels
  and join all components) but maybe not that useful in practice.

**Keeping our eye on the ball: *why* do we even need meet and join?**

Meet and join are interesting conceptual operations regardless of the need,
but it's worth asking why we actually need them in `typeof`.

The answer is that `join` comes up in branching logic. In an imperative language
like `Pyre` this often means when nodes of the CFG intersect we perform a join
on *everything*; in the cleaner term-based systems of TAPL we only need joins
for `case` and `if`.

Note that from the standpoint of `typeof` only `join` is really needed; `meet`
just comes up when we have contravariant type parameters in a complex type you
need to join.  See section 16.3 (page 218) for a discussion of this.

It's also worth noting that the authors opt to use union and intersection notation
for the join and meet, even though in the context of 16.3 they are talking about
an implementation detail rather than first-class union and intersection as in
15.7. This is because the ideas are roughly isomorphic.

### `subtype`: more or less follows from `join` and `meet`

Subtype is implemented as follows:
- First we check for equivalent types, for efficiency and because it
  makes the match statement simpler (for example, none of the primitive
  literal types are needed in the match statement)
- Then we use a recursive match, which works as you'd expect:
  - For covarant type params we just recursively call `subtype` in the same direction
  - For contravariant type params we do the same but flip the direction
  - For the invariant `Ref` we require equivalence of the inner types
  - For records and variants, we use a containment check plus per-component
    covariant checks on each component.
    - The fact that this works is part of the topic of Chapter 16, since
      the algorithmic typing rules are actually simpler than the derivation
      rules (and don't follow from them, since there are *many* possible
      derivations for subtype relationships unlike in STLC).

One thing that's a little annoying is that `tyequiv` isn't implemented in
terms of two `subtype` checks, and the authors use both patterns in other code;
this means we really should have a proof that they behave the same. I suppose
there's probably an efficiency win in separating them, although this doesn't
explain why the authors frequently use two `subtype` checks rather than a
`tyequiv` check in downstream code where both were available.

### The `typeof` implementation

Once you understand `join`, `meet`, and `subtype` the `typeof` implementation
isn't too scary:
- several terms are handled exactly as before:
  - primitives evaluate to the related type
  - variables just get the type from the context
  - abstraction: add the param to context, then call `typeof` on the body
  - references: just get the type of the term
- data constructors generally require a subtype relation, for example
  - a tag term's param term needs to type as a subtype of the variant component
    type (and the tag has to be valid but that's not new since Chapter 11)
  - similarly, a record term needs to have subtype on all components - several of
    the other terms involve subtype checks and may use join / meet
- ascribe is a bit special; it allows upcasts
- operations generally have specific rules based on substitution logic
  - apply requires the parameter (`t2`) to be a subtype of what's annotated
  - case requires that the "natural type" of the case is a supertype of
    the input type (which means it could have extra branches, but must include
    a branch for every label) and then joins all of the output types
    - note that we're allowed to have incompatible output types because of the
      presence of `Top`; we just can't do anything with the output
  - Proj requires the type to be a subtype of the "natural type" - i.e. that
    it has the relevant label, and extracts that label
  - Deref just passes the type through

The bottom type shows up all over the place and is best thought of as
"this cannot happen" in this implementation; I *think* the only actual use of
bottom that will type check is an infinite loop with `Fix`.  (In an
implementation extended with exceptions bottom would also show up in exceptions;
see the Chapter 14 implementation).


### Keep your eye on the ball when thinking about `typeof`

It's easy to get lost in details of `meet`, `join`, etc, which are operations
on a lattice and don't directly produce type errors.

When you look at `typeof` you have to shift gears and remember what the
*point* of subtyping is: `t0 <: t1` if `t0` is substitutable for `t1`. This
means that we need a subtype check on the type parameters of types representing
any kind of "operation", which includes:
- application (this is really the essence of "operation")
- primitive operations, which for this language are
  - case and projection operations
  - assignment (this is a two-parameter operation!)

Keep in mind that application and its cousins (e.g. case, deref, and proj, all
of which can in principle be reformulated as application) are really the *point*
of subtyping; the only requirement is that a subtype "behave like" any
supertype, and what that means formally is that all function applications
(including primitive operations) can accept subtypes

### Why is the implementation so tricky? A few pointers to Chapter 16

If you look at the subtyping rules, they are actually pretty simple:
all we need is subtype and `T-SUB`, which allows implicit casts, and the rest
of the typing rules are unchanged.

But the implementation in `typeof` is *much* more complex, with subtype
checks buried in many of the arms where we have to think very carefully
about each case.

The reason for this is that the implicitness of `T-SUB` requires us to
*extract* the type we want to match on from the form we are substituting
into. As a result, we have to
- deduce the input type of the lambda in a `TyApp`
- effectively deduce the "natural type" of projection and case terms,
  and do a subtype check (which we don't encode that way)
- deduce the output type of `case` and `if`, because the branches no longer
  have to have the same natural type so we need a `join` here

This is exactly what the authors drive home at the start of Chapter 16: the
formula for `T-SUB` is
```
\Gamma |- t : S    S <: T
-------------------------
\Gamma |- t : T
```
and the `T` here comes out of nowhere: nothing in this form lets us extract
the `T` from a type, so this rule has no self-contained algorithmic realization.
This comes up in the handling of `typeof`.

T-TRANS is similar:
```
S <: U  U <: T
---------------
S <: T
```
has all the types coming out of nowhere, and in fact the choice of `U` is
in many cases arbitrary (e.g. "any one of a bunch of extra record fields").
This comes up in the handling of `subtype`.

**Algorithmic subtyping: Page 212, figure 16-2**

We can prove that `S-RCD` (Page 211) is equivalent to the three primitive record
subtyping rules, and in the actual `subtype` implementation this is actually
*more* convenient which solves the transitivity issue; we wind up with the
three rules at the top of 212 (`SA-TOP`, `SA-ARROw`, and `SA-RCD`) for algorithmic
subtyping.

**Algorithmic typing: Page 217, figure 16-3**

But for agorithmic typing the need for `T-SUB` is trickier and we wind up with
special-case, new algorithmic typing rules for typing (Figure 16-3 on page 217).
Those rules are what we wind up embodying in our `typeof` implementation.

But the implicit `T-SUB` issue remains, and requires special-case rules; for the
simple case the three rules on page 212 

## Usage: Chpater 18

The code in Chapter 18, for imperative objects embedded in the extended
STLC, is based on this implementation.

I'm probably going to defer going through this for now because I want
to get to recursive types and polymorphism reasonably quickly (since those
concepts are all important for Pyre), but it would be good to come back to
that chapter at some point.
