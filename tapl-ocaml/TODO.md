Where I am right now:
- I've finished a first pass on subtyping
- Next items to do (in theory they can be done in parallel)
  - Let polymorphism (supplemental: the cornell lectures)
  - Start looking at recursive types
  - System F (supposedly doesn't depend on ^)

From a quick skim of the let polymorphism code:
- reconbase is really just a STLC with bools and numbers;
  it has no new features but serves as the typed "base"
  implementation for recon
- recon is reconbase with constratint-based type inference.
  There is no let form in recon, so this is just the basic
  constraint solving from the portion of Chapter 22 prior
  to let polymorphism
- what we really want to understand is fullrecon, which is
  roughly the same thing but with let expressions and
  with the type annotations on lambda parameters made optional

The road to understanding constraint-unification based
let polymorphism is probably to focus on recon first and then
fullrecon.

Things to come back to:
- Of the first 17 chapters, only two really need close looks:
  - fullref, which is a "full" STLC with ref + subtyping +
    top/bottom
  - fullerror, which is a bare-bones STLC with 
    errors, subtyping, and top/bottom
- I should look at these in detail, particularly fullref, and
  review Chapters 15-17 in particular to understand subtyping
  well. I also should figure out how to use the emacs debugger
  hooks!
- I probably should take a stab at Chapter 18, which is implemented
  in terms of `fullref`

In the more distant future, it would be nice to combine `fullref`
with `fullerror`, and ideally build a from-scratch implementation
with an environment-based interpreter. But that's probably a
distraction from my current focus on type checking essentials.
