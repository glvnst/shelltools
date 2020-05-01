OS_TARGETS := darwin linux windows
BINARIES := $(OS_TARGETS:%=build/%/avg)
.PHONY: build lint clean test

build: lint test $(BINARIES)

$(BINARIES): main.go
	@echo '==> Building $@'
	@OS="$$(printf '%s' '$@' | cut -f 2 -d '/')"; \
	  set -x; \
	  GOOS="$$OS" GOARCH=amd64 go build -o "$@" $<

lint: main.go
	@echo '==> Linting'
	go fmt
	go vet
	golint
	staticcheck

test:
	@echo '==> Testing'
	go test -v

clean:
	@echo '==> Cleaning'
	rm -rf -- build
