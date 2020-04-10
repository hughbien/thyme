INSTALL_BIN ?= /usr/local/bin

spec: test
test:
	crystal spec $(ARGS)

build: bin/thyme
bin/thyme:
	shards build --production
	rm bin/thyme.dwarf

install: build
	cp bin/thyme $(INSTALL_BIN)

clean:
	rm -rf bin

reset:
	tmux source-file ~/.tmux.conf

run:
	crystal run src/cli.cr -- $(ARGS)
