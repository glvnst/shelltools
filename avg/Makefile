OS_TARGETS := darwin linux windows
BINARIES := $(OS_TARGETS:%=build/%/avg)
.PHONY: build check clean

build: check $(BINARIES)

$(BINARIES): main.go
	@echo '==> Building $@'
	@OS="$$(printf '%s' '$@' | cut -f 2 -d '/')"; \
	  set -x; \
	  GOOS="$$OS" GOARCH=amd64 go build -o "$@" $<

check: main.go
	@echo '==> Checking'
	go fmt
	golint
	go vet
	go test -v

clean:
	@echo '==> Cleaning'
	rm -rf -- build
