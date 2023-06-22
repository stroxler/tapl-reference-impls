# The official Ocaml code for "Types and Programming Languages"

This is my github mirror for the book's original source code
(this repo also contains a mirror of someone's Haskell version
of the first half or so).

My intent with this mirror is to:

- Have source I can browse online (the official sources are
  only available as tarballs, os they aren't suitable for
  quick reference)

- Hopefully be able to mix together the original sources
  with modernized build instructions using Dune (I've got
  nothing against the Makefiles, I'd sort of like to have
  both working, but I don't think many industry players would
  use make for a real ocaml project today).

- Have code I control so I can rename directories so it's more
  obvious which code goes with which chapter, and so I can add
  clarifying comments wherever I think they are warranted.

My intent is that this will be mainly a reference for myself;
I'm loosely planning on copying the code to a new repo I write
from scratch (in the same manner as, e.g. going through the
"Crafting Interpreters" book), but I may wind up spending
more effort on comments and less on a from-scrach implementation.

Initial setup to compile the code is to install `opam` (I've
taken to bootstrapping with `nix`, so `nix-env -iA nixpkg.opam`
works for me but you can usually use whatever package manager
to get it, e.g. brew / apt / ect), and then set up a switch:
```
opam switch create tapl 5.0.0
```

You can then activate it in any shell session where you want
to work on TAPL via:
```
eval "$(opam env --switch=tapl)"
```

There are actually no dependencies at all for the build, we use ocamlyacc
rather than Menhir. But if you wanted to start tweaking the code (e.g. to use
Menhir for the parser, add unit tests, or use ppx deriving to add debug
printing) then you would want to install some dependencies into your switch,
e.g.
```
opam install --yes \
  base64.3.5.1 \
  core.v0.15.1 \
  core_unix.v0.15.2 \
  menhir.20220210 \
  dune 3.8.2
```

You also likely want IDE support; for that you can run
```
opam install --yes \
  merlin \
  ocaml-lsp-server
```
(The `merlin` tool is used in emacs and many vim setups, the
`ocaml-lsp-server` is used by the standard open-source vscode plugin).

It's also recommended for vscode to install `ocamlformat-rpc`, but as
of me writing this it couldn't yet work with 5.0.0.

## Getting IDE support

My experience was that using the basic Makefile build scripts that were
already in the project produced a state where `ocaml-lsp-server` was
able to successfully talk to VSCode and I got type hints. I'm not 100%
sure about ocaml, I didn't have vim or emacs set up to use it at the
time I tested.

It seems like using a dune build also worked out-of-the-box (after
a `make clean`) so I think `ocaml-lsp-server` is able to find
the files it needs under both a "flat" make-based structure and
a `_build`-based dune structure.
