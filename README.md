# Reference implementations for TAPL

I'm moving these to my own github repo because the original sources aren't easy to find
or view, plus I want ot be able to take notes and potentially rename projects (the names
aren't really aligned with chapter numbers, which makes it not totally obvious
which source code we're supposed to look at).

The `tapl-ocaml` subdirectory contains the original sources downloaded from
https://www.cis.upenn.edu/~bcpierce/tapl/

The `tapl-haskell` directory contains the contents of the tarball from
https://code.google.com/archive/p/tapl-haskell/

The `tapl-haskell-original-source` directory contains the full source of the code
from https://code.google.com/archive/p/tapl-haskell/, including code generation logic.

# A start on matching implementations to chapters

The `tapl-haskell` google code project contains this tidbit to help map
implementations against chapters:
- arith (Chapters 3 - 4)
- untyped (Chapters 5 - 7)
- fulluntyped (Chapters 5 - 7)
- tyarith (Chapter 8)
- simplebool (Chapter 10)
- fullsimple (Chapter 9 and 11)
- fullref (Chapters 13 and 18)
- fullerror (Chapter 14)
- fullsub (Chapters 15 - 17)
- rcdsubbot (Chapters 15 - 17)
- bot (Chapter 16)


The remaining implementations (which are available only in ocaml) are
presumably related to chapters 17+.
