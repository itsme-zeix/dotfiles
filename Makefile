.PHONY: dry-run stow install restow unstow test

dry-run:
	./install.sh dry-run

stow:
	./install.sh link

install:
	./install.sh install

restow:
	./install.sh restow

unstow:
	./install.sh unstow

test:
	./tests/install-pi.sh
