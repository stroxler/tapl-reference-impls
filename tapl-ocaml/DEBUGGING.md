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

## Other tools, and printing

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

### Loading and installing printers

Here's some discussion of how loading and installing printers works.
https://stackoverflow.com/questions/75619816/how-do-i-install-a-printer-for-a-user-defined-type-in-ocamldebug
and also
https://groups.google.com/g/fa.caml/c/EZvxh3UWrAA?pli=1

I suspect I may need to scriptify this to get printing wroking on
parts of Pyre (also temporarily deleting relevant .mli files when
debugging to expose the "raw" types may help).

Also note that it's somewhat likely I'll have to deal with dune
wrapped libraries, which affects both the location of main
(as I've noted elsewhere) and the `install_printer` directive.

There's a discussion of that (in the context of using a different
debugger `rdbg` that is built on top of ocaml) here:
https://verimag.gricad-pages.univ-grenoble-alpes.fr/vtt/articles/sasa-ocamldebug/

One other resource that may prove handy:
https://github.com/ocaml/ocaml/issues/6777

## Debugging on complex projects

The TAPL code is all pure-ocaml, but I've been having major issues
getting a bytecode compile of Pyre to work at all - dune just chokes
complaining about ld failures.

I suspect fixing this will require a deep dive on dune internals because
somehow the linker paths are messed up. I found a few threads about it,
I vaguely remember in the past that I was able to use the advice here to
set LIBRARY_PATH.
https://github.com/janestreet/pythonlib/issues/1

Unfortunately it doesn't appear that the LIBRARY_PATH fix is working for me
today :/

There's a thread about the problem in Dune here:
https://github.com/ocaml/dune/issues/3910

What's strange is that `dune utop` works just fine.

In the meantime, I'm probably going to have to give up on debugging Pyre
until / unless I learn enough to actually figure out why dune isn't setting
the right flag; it's at least nice to be able to debug academic example code;
for Pyre I might have to rely on tracevent tooling if I want good stack
visibility.
