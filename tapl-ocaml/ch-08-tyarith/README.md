# Typed arithmetic

There's not a ton here worth discussing that didn't come up
earlier in my notes on either `arith` or `fulluntyped`.

The main new "thing" in this code is that
- We now have an ocaml datatype representing types, `Syntax.ty`
- We have a recursive function `Core.typeof` that:
  - recursively computes the types of subterms
  - throws an error if it encounters a violation when
    typing the various arms of the term
  - otherwise returns the term
- In the `Main.process_command` function, we now compute
  `typeof t` before evaluating a term `t`. This will type check
  it; moreover, if it does type check then after evaluating it
  we will print both the result *and* a type annotation (in
  the same format as `GHCi`)


