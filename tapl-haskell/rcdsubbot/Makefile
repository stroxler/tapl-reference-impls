#   make         to rebuild the executable file f
#   make test    to rebuild the executable and run the unit tests
#   make sample  to rebuild the executable and run it on input file test.f
#                (this is "make test" in the ocaml implementation)
#   make clean   to remove all intermediate and temporary files

FILES = Tests.hs Main.hs Typing.hs Syntax.hs Printing.hs Parser.hs Evaluator.hs TaplError.hs Util.hs TestUtils.hs SimpleContext.hs SubtypeTests.hs ArithTests.hs

f: $(FILES) 
	ghc $(INCLUDE) -fglasgow-exts --make Main.hs -o f

test-runner: $(FILES) 
	ghc $(INCLUDE) -fglasgow-exts --make Tests.hs -o test-runner

test: test-runner
	./test-runner

sample: f
	./f test.f

clean:
	-rm *.hi *.o f test-runner 

