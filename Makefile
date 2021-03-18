INSTALL_BIN ?= /usr/local/bin
VERSION = $(shell cat shard.yml | grep version | sed -e "s/version: //")

build: bin/thyme
bin/thyme:
	shards build --production
	rm bin/thyme.dwarf

build-static:
	docker run --rm -it -v $(PWD):/workspace -w /workspace crystallang/crystal:0.36.1-alpine shards build --production --static
	mv bin/thyme bin/thyme-linux64-$(VERSION)

install: build
	cp bin/thyme $(INSTALL_BIN)

spec: test
test:
	crystal spec $(ARGS)

clean:
	rm -rf bin

reset:
	tmux source-file ~/.tmux.conf

run:
	crystal run src/cli.cr -- $(ARGS)
