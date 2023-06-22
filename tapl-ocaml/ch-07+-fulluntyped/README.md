# "Full" untyped lambda calculus with primitives

This actually isn't discussed directly in the book, but it
is the untyped lambda calculus' extension of the "extended"
simply-typed-lambda-calculus described in Chapter 11 of
the book.

It extends the untyped lambda calculus with:
- primitive types bool / int / float / string
  - the strings and floats are native
  - the ints remain from-scratch unary representations
    as in the untyped arithmetic example
- record types
- projection terms (attribute access, in oop lingo) 
- basic control flow: if and let

Weirdly there's only multiplication for floats, no
addition!


# Some quick notes on the implementation

## Lexing, and what is LCID?

The lexer and parser define `LCID` and `UCID`, which are lower-case and
upper-case identifiers (only LCID is really used here; UCID is just a
placeholder for typing constructs that will show up later).

These tokens, instead of just carrying location info, carry both a string
and location info (this is standard - lexemes for names need to carry
the raw lexeme for use later). The `withinfo` record used to build these
lexemes has the info at the `.i` attribute and the value at the `.v` attribute.

You can see how they are defined lecixally in the lexer.

Weirdly symbols also resolve using the same createID function that produces
LCID and UCID; the way this works is that we build a `symbolTable` out of
`reservedWords`, which will intercept symbols so they become the appropriate
token (if we didn't do this, they would become `LCID`s... weirdly if someone
uses a symbol that isn't defined, it will wind up being an `LCID` because there's
no error checking - I guess since this is all academic that's fine).

The INTV / FLOATV / STRINGV lexemes work similarly, but the names are
a lot more obvious and there's no confusion.

## De Brujin indices

### Parsing

Because we convert names to De Brujin indices, we have to include a context
when we parse; the role it plays is very similar to the environment maps used
in `Resolution.java` of Crafting Interpreters (becasue De Brujin indices are
closely related to the scope stack mechanism used to resolve lexically-scoped
captures in lox... it's not the same, but the idea is similar and in fact it
is even *more* similar to the stack-depth approach used in clox's bytecode
compiler). 

You can see this in the type signature of `toplevel` in `parser.mly` - it accepts
a `Syntax.context` as input. The context types at parsing and runtime are the
same for this implementation; in a typical real language they would be different
but related.

The entire parser is written in something a bit like a cross between a
reader-monad  and state-monad style - the raw parse result of any syntax element
is not itself data, but rather a function which, given the `ctx`, can return
data.
- This is what allows the parser to have outer terms create context that is
  passed to inner terms, but then abandoned when we get to later terms.
- When you see code like `$4 ctx` in the parser, this is what's
  going on:
  - the `$4` refers to the raw `ocamlyacc` result of parsing term "4" of the
    current parse rule, and that value is actually a *function* from context
    to an AST.
  - So to get the AST, we call that function on the appropriate context.

When the parser encounters a binding statement, it does two things:
- it spits out a `Bind` AST term, which is the "parsing" part of the work
- But it also adds the name to the context, which is the "resolution" part
  of the work - all later statements will see a context with this binding prepended.
  Unlike most other binds, this bind will remain in the context for the remainder
  of the program.

In a let expression, on the other hand:
- We evaluate the parser for the binding term in the current context
- But then we extend the context before parsing the body

Lambdas are similar: at evaluation time they are more complex but for
parsing purposes they are handled almost exactly like Let.

Variables are then where all this pays off: when we hit an LCID in the ATerm
parsing rule, we do the following:
- Record the De Brujin index (the depth of the first hit of that variable name
  in the lexical context at parse time) as the first integer.
- Record the depth of the lexical context as the second integer. We'll need this
  at evaluation time for the "cutoff" when index-shifting.

If we don't find any binding for a variable, we throw an error; this is similar
to how the `Resolution.java` implementation / the clox bytecode compiler were able
to mostly guarantee that we wouldn't hit unbound name errors at runtime.

Note that new bindings always appear at the "head" of the context, which is acting
like a stack here. The De Brujin indices are then just the location of a
particular binding in that stack - again, very similar to the clox bytecode
output.

### Evaluation

Once we've parsed a program using our lexical context, we have all terms in
De Brujin form already, which means every variable term knows:
- How deep in the runtime context (the variable stack) it wants to look at
  runtime for bound variables.
- What the the total depth of the runtime context is, lexically, at the point
  when the variable is defined.

In a typical stack machine like clox the way we do this is by creating a closure
object that contains in it a sequence of pointers that point back into the stack
when a closure is created, and wiring up logic to move the data off the stack / onto
the heap whenever the captured variables go out of scope originally.

In an untyped lambda calculus, everything is based on rewriting which means
things get handled differently:
- When we want to evaluate `(\ T) S`, wherer T and S are De Brujin indexed terms,
  we want to rewrite T in terms of S plus adjusting for one fewer lambda.
- To do this, we need to
  - Traverse `T`, indicating the depth of the `T` top level:
    - It will start at zero because if `T` is just 0, that is the top-level var
    - It will increase every time we enter a `TmLet` or `TmAbs`
  - In that traversal, let `t_tl` indicate the current index of the `T` top-level
    - Any time we encounter a variable with index *greater than* `t_tl`, it is free
      in `T`. Since we're in the process of stripping the `\` in `\ T`, we need
      to decrement this variable (by exactly one).
    - Any time we encounter a variable with index *equal to* `t_tl`, we need to
      substitute `S`. But remember, `S` may have free variables, which were
      indexed such that `0` in `S` means the same as `1` in `T`. As a result:
      - traverse `S` indicating the depth of the `S` top level as `s_tl`
      - any time we hit a variable whose index is *greater than or equal to*
        `s_tl`, we should increment it by `t_tl`
        - For example: `(\ (\ 1)) 1` steps to `\ 2`, which is correct because
          the 1 in `S` says "look up one more past the top level" but when it
          gets bound in the inner `\` we now need to "look up two more".

This operation is implemented by these functions, where I've tweaked variable
names to make it clear which parts are recursive.
```ocaml
let termShiftAbove d0 c0 t0 =
  tmmap
    (fun fi c v_i v_d ->
      if v_i >= c
      then TmVar(fi, v_i + d0, v_d + d0)
      else TmVar(fi, v_i, v_d + d0))
    c0
    t

let termShift d0 t0 = termShiftAbove d0 0 t0

let termSubst j s1 t =
  tmmap
    (fun fi c x n ->
      if v_i = j + c
      then termShift c s1
      else TmVar(fi, v_i, v_d))
    0
    t

let termSubstTop s0 t0 = termShift (-1) (termSubst 0 (termShift 1 s0) t0)

```
The underlying `tmmap` function does the following:
- Traverse a term, walking with a cutff `c` that starts at `c0` and increments
  every time we enter a binding context (from a `TmLet` or `TmAbs`).
- when it incounters a variable with index `v_i` and context depth `v_d`
  - adjust the context depth by `d0`. Do this always (regardless of )
  - if the index is greater than `c`, which means the variable is free in the
    outermost term `t0`, then adjust it by `d0`. Otherwise leave it alone.

In the context of `termShift Above d0 c0 t0` what this does is
- take any variable that is free with "extra" depth `c0` in the term `t0` and
  adjust the index by `d0`
- adjust the depths of all variables (free or not) by `d0`

When used in the `termShift 1 s0` term, this produces an `s1` with extra depth
of 1 whose free variables have an extra index of depth.

When used inside of `termSubst 0 s1 t0`, the result is a new term `t1` in which:
- for every variable in `t0` such that `v_i` is equal to the cutoff `c` - which
  means that `v_i` refers to the top-level of t0 - we:
  - replace `v_i` with `s1` shifted by `c` (i.e. `s` shifted by `c + 1`)
- The resulting term `t1` whose:
  - inner-bound variables are exactly the same as those of `t0`
  - free variables are exactly the same as those of `t0`
  - top-level bound variables have been replaced by a version of `s0` whose
    free variables are now mapped to the top level of `t0` *plus* a layer
    are now free
- Finally, we termShift this by -1

The algorithm here is a little different than I described in that it does
duplicate work, but the end result is the same - the confusing bit
`termShift 1 s0` is just there so that we can blanket `termShift (-1)` the
entire result at the end instead of doing a more delicate traversal where
we handle the substitution and free variable adjustments in one pass.


### What's the relation of substitution to "normal" environments?

This is all somewhat icky, and I'm still trying to wrap my head around how
the term rewriting approach jives with the much easier to understand environment
model, which can be compiled down to stack lookups that feel pretty similar in
principle.

My impression after thinking about this for a while is that the key difference
is how we represent closures, plus the handling of globals.
- In a normal interpreter, closures have some mechanism to capture their
  environment and let bindings extend the environment with a new value.
  - As a result, there's no need for adjusting anything:
    - the body of an abstraction will be evaluated with some kind of closure
      scope where the original indices (or in the string-name based approach
      the old variable names) remain valid.
    - the body of a let will be evaluated against an extended stack, and the
      resolver-generated stack depths will be correct already. There can't
      *be* any free variables, because we don't allow referring to "symbolic
      globals" - a value *never* has free variables.
- In this interpreter,
  - The biggest difference is that there's only one stack
    - This means instead of closures being represented directly with an
      adjusted context, we "handle" them by eagerly rewriting them.
    - There are two different "classes" of De Brujin indices that appear:
      - lexically-scoped indices of all bound variables
      - sort-of-dynamically-scoped indices of free variables (which refer to
        something in the current stack, but also have to be adjusted based on
        lexical scope *within* the current term to account for the fact that the
        stack will change)
    - The constant rewrites are due to the smashing together of these two
      scoping "classes". If we instead push let bindings onto the stack
      and preserve context for closures, none of this is needed.

The problem isn't really unique to De Brujin indices; if we use plain old string
variable names we can handle this pretty cleanly using environment stacks and
environment closures (with some careful handling of lexical scope for closures
in a resolver), whereas the rewriting would be pretty onerous and we'd have to
traverse everything tracking which names have bindings shadowing other names.

In both cases, I think part of the challenge is that theoreticians are wedded
to the substitution / rewriting model from the '30s as the "one true model" of
computation, and it's actually not only less efficient but also quite a bit
harder for me to think through than the environment stack model used by real
languages.

## Names of syntactic constructs + what are global bindings?

Tost of them are obvious, the ones I had to think about were
- `TmProj`: to TAPL authors, "projection" is the term for extracting
  part of a product type; in this case it means attribute access on a record.
- `NameBind` refers to binding a name without an initializer. I'm still slightly
  confused about what this even does; the syntax for it is the name followed by
  a forward slash. This operation exists even in the "simple" untyped lambda
  calculus, but given that there are no assignment operations it perplexes me
  what it actually *means* to "bind a name".
- `TmAbbBind`: I'm actually not sure what this abbreviation means, but it 
  means the normal global binding I'm used to where we bind a name to a term.
  My best guess is that it means "abbreviation bind" - the idea being that if you're
  thinking super theoretically, a global is just a stand in for substituting its
  value and therefore you can think of a global as just an "abbreviation" for the
  underlying term. In practical implementations there's a big difference but the
  TAPL authors are focused on type thoery, not implementation techniques.

To understand how bound names are used we can look at the handling of `context`
plus `evalbinding` plus the use of context in `eval`:
- a `context` is an alist of names and bindings, simple enough. Bindings can
  be either `NameBind` or `TmAbbBind`.
- `evalbinding` evaluates `NameBind` to itself, and `TmAbbBind` to whatever
  the term evaluates to (what this means is that terms get evaluated eagerly
  when we bind global names - so it's not just an "abbreviation" for the raw
  syntactic term which is part of why I dislike the name).
- When `eval1` on `TmVar` hits a variable, it calls `getbinding`
  - If it finds a `TmAbbBind`, this will evaluate to the bound term
  - If it finds a `NameBind`, it raises `NoRuleApplies`, which effectively
    means we stop evaluating. The interaction between `eval` and `eval1` here
    is a bit confusing, but I *think* this means we treat "bound names" sort of
    like symbols, where they are allowed to evaluate to themselves (because
    the result is that the `TmVar` simply remains a `TmVar`, but we don't
    terminate the program)
  - If `getbinding` finds nothing it all it will raise an `Exit 1`, terminating
    the program. This shouldn't really happen since the `name2index` call during
    parsing should have guaranteed that all variables are in scope.

So again, I *think* that a form like `x/;` is basically saying we are allowed to
use `x` as a free variable in terms for the rest of the program, but it won't
evaluate to anything. This doesn't really have an analogy in languages I've used
other than maybe lisp.

Note that in the "pure" untyped lambda calculus we *only* had `NameBind`, there
was no such thing as a "value" bound to a global name.


The de brujin index of a term is how closely bound the term is