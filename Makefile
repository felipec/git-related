prefix := $(HOME)

bindir := $(prefix)/bin
mandir := $(prefix)/share/man/man1

all:

doc: doc/git-related.1 doc/git-who.1

test:
	$(MAKE) -C t

%.1: %.txt
	asciidoctor -b manpage $<

clean:
	$(RM) doc/*.1

D = $(DESTDIR)

install:
	install -d -m 755 $(D)$(bindir)/
	install -m 755 git-related $(D)$(bindir)/git-related
	install -m 755 git-who $(D)$(bindir)/git-who

install-doc: doc
	install -d -m 755 $(D)$(mandir)/
	install -m 644 doc/git-related.1 $(D)$(mandir)/git-related.1
	install -m 644 doc/git-who.1 $(D)$(mandir)/git-who.1

.PHONY: all doc test install install-doc clean
