# Debugging Ocaml Code

One of my goals for studying TAPL code was to learn to use
the interactive debugger. I think exploring source code and the
data it executes on interactively can be a very useful way of wrapping
your head more quickly around programs.

This is useful for understanding TAPL itself, but more importantly I can
hopefully apply the same skills - once I know how to use the debugger
fluently - to exploring Pyre (or Flow) interactively.

## Setting up the debugger

FILLME - Move the notes that I inlined in an impl.

## Debugging on the command line

FILLME - Move the notes that I inlined in an impl.

**Additional notes since then:**

I discovered the `list` command today, that solves one of my major
problems with ocamldebug; I think using it on the command line is
doable (not ideal, but doable) with that.

In the output of `list`, the current location is indicated with <|b|>
which is handy; it would be more handy if I could write a wrapper
to make that louder (it's a bit hard to see right now!).

There's also the `source` command which can be used to chain commands;
this could be particularly handy for setting a bunch of breakpoints,

## Debugging with Emacs and Taureg-mode

The taureg-mode umbrella of ocaml-related emacs plugins provides
debugger support.

The actual commands to run the debugger are:
- `ocamldebug` to launch ocamldebug
- `ocamldebug-{break,delete}` to set/remove breaks
- `ocamldebug-{step,goto,last}` for execution step navigation
- `ocamldebug-{next,finish}` for current-file step navigation
   - next steps until next execution step in this function
   - finish goes to the end of the function
- `ocamldebug-{up,down}` for frame navigation
- `ocamldebug-print` prints the symbol at point
- `ocamldebug-backtrace` prints current stack trace
- `ocamldebug-reverse` go back to most recent breakpoint
- `ocamldebug-kill` kills the process
- commands I don't yet understand
  `ocamldebug-open`: opens the current module
  `ocamldebug-close`: closes the module

Default bindings for these commands:
- ocamldebug-break: C-x SPC
- ocamldebug-delete: C-x C-a C-d
- ocamldebug-{up,down} C-x C-a {<,>}
- ocamldebug-{run,goto,step} C-x C-a {r,g,s}
- ocamldebug-{next,finish} C-x C-a C-{n,f}
- ocamldebug-reverse C-x C-a C-v
- ocamldebug-{open,close,kill} C-x C-a C-{o,c,k}

Unfortunately I'm currently still blocked on actually getting it to run
correctly. I hit a few issues:
- It makes you enter the path to the executable every time, which is okay
  but a little annoying when dealing with dune.
- It cd's to the location of `main.bc` which means you have to pass the
  argument (e.g. `test.f`) as an absolute path. This is also tolerable, but
  is pretty annoying.
- I cannot seem to pass it the `-I` flag I need to pick up symbols for
  all the modules. This is actually the primary problem.

## Hack project opportunity!

It would be pretty cool to make debugger plugins
for vscode and/or neovim; with some luck reading the
emacs source would be enough to figure out basics,
especially if I cross-reference against our debugpy
bindings.

There used to be an `ocamlearlybird` plugin for VSCode
but it is no longer maintained.

## Other tools

### Red: a python wrapper around ocamldebug

Someone made a python project to stick a frontend on top of ocamldebug,
which gives a good enough out-of-the-box experience that it might be
an alternative to emacs:
https://github.com/reasonml/red

There's a video of this at
https://www.youtube.com/watch?v=2DiZ1fbtdnE

I discovered that (a) it doesn't work with Python 3 out of the box
and (b) I don't seem to be getting stdin wired up. But it looks pretty
nice nontheless.

It's only around 400 lines of code, so this could be a cool hack project
to patch it up and make it more usable (plus add some documentation!); this
is actually right in a class of tools that interests me - wrapping a cli
interface in another cli interface to make it more programmable :)
