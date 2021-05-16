prefix := $(HOME)

bindir := $(prefix)/bin
mandir := $(prefix)/share/man/man1

all:

doc: doc/git-related.1

test:
	$(MAKE) -C test

doc/git-related.1: doc/git-related.txt
	asciidoctor -b manpage $<

clean:
	$(RM) doc/git-related.1

D = $(DESTDIR)

install:
	install -d -m 755 $(D)$(bindir)/
	install -m 755 git-related $(D)$(bindir)/git-related

install-doc: doc
	install -d -m 755 $(D)$(mandir)/
	install -m 644 doc/git-related.1 $(D)$(mandir)/git-related.1

.PHONY: all test install install-doc clean
