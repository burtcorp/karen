GULP = ./node_modules/.bin/gulp

all:
	$(GULP) compile

test:
	./node_modules/mocha/bin/mocha

.PHONY: all test
