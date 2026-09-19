.PHONY: dry-run link install unlink test

dry-run:
	./install.sh dry-run

link:
	./install.sh link

install:
	./install.sh install

unlink:
	./install.sh unlink

test:
	./tests/install-pi.sh
	./tests/check-working-frames.sh
