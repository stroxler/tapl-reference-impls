#   make         to rebuild the executable file f
#   make test    to rebuild the executable and run the unit tests
#   make sample  to rebuild the executable and run it on input file test.f
#                (this is "make test" in the ocaml implementation)
#   make clean   to remove all intermediate and temporary files

FILES = Tests.hs Main.hs Untyped.hs UntypedParser.hs Evaluator.hs Context.hs TaplError.hs Util.hs TestUtils.hs UntypedTests.hs

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

