all: test

test:
	./node_modules/mocha/bin/mocha

.PHONY: all test
