prefix := $(HOME)

all:

doc: doc/git-related.1

test:
	$(MAKE) -C test

doc/git-related.1: doc/git-related.txt
	a2x -d manpage -f manpage $<

D = $(DESTDIR)

install:
	install -D -m 755 git-related \
		$(D)$(prefix)/bin/git-related

install-doc: doc
	install -D -m 644 doc/git-related.1 \
		$(D)$(prefix)/share/man/man1/git-related.1

.PHONY: all test
