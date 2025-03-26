## Target special targets are called phony and you can explicitly tell Make they're not associated with files
.PHONY: no_targets__ all test clean
	no_targets__:

.DEFAULT_GOAL := all

all:
	@echo "starting build golang"
	go-builder
