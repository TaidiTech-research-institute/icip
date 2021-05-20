.PHONY: all

all: ICIP1 ICIP2

ICIP1:
	$(shell vessel bin)/moc $(shell vessel sources) -wasi-system-api -o ICIP1Test.wasm ICIP1Test.mo && wasmtime ICIP1Test.wasm
	rm -f ICIP1Test.wasm
ICIP2:
	$(shell vessel bin)/moc $(shell vessel sources) -wasi-system-api -o ICIP2Test.wasm ICIP2Test.mo && wasmtime ICIP2Test.wasm
	rm -f ICIP2Test.wasm