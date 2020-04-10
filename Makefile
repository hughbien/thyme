INSTALL_BIN ?= /usr/local/bin
VERSION = $(shell cat shard.yml | grep version | sed -e "s/version: //")

spec: test
test:
	crystal spec $(ARGS)

build: bin/thyme
bin/thyme:
	shards build --production
	rm bin/thyme.dwarf

release: build
	mv bin/thyme bin/thyme-darwin64-$(VERSION)
	docker run --rm -it -v $(PWD):/workspace -w /workspace crystallang/crystal:latest-alpine shards build --production --static
	mv bin/thyme bin/thyme-linux64-$(VERSION)

install: build
	cp bin/thyme $(INSTALL_BIN)

clean:
	rm -rf bin

reset:
	tmux source-file ~/.tmux.conf

run:
	crystal run src/cli.cr -- $(ARGS)
