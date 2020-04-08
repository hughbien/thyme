INSTALL_BIN ?= /usr/local/bin

spec: test
test:
	crystal spec $(ARGS)

build: target/thyme
target/thyme:
	crystal build src/cli.cr --release
	mkdir -p target
	mv cli target/thyme
	rm cli.dwarf

install: build
	cp target/thyme $(INSTALL_BIN)

clean:
	rm -rf cli cli.dwarf target

reset:
	tmux source-file ~/.tmux.conf

run:
	crystal run src/cli.cr -- $(ARGS)
