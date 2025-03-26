## Configure via:
## SVACE_BUILD_ACTION=-f ${SVACE_MAKE_BUILD_PROJECT_FILE}
## SVACE_MAKE_BUILD_PROJECT_FILE: file variable
SHELL                         = /bin/bash

## Target special targets are called phony and you can explicitly tell Make they're not associated with files
.PHONY: no_targets__ all test clean
	no_targets__:

.DEFAULT_GOAL := all

all:
	@echo "Build via svace wrapper"
	@svace build $(MAKE) -f ${MAKE_BUILD_PROJECT_FILE} all >>build.log 2>&1
