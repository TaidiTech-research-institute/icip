test:
	$(shell vessel bin)/moc $(shell vessel sources) -wasi-system-api -o ICIP1Test.wasm ICIP1Test.mo && wasmtime ICIP1Test.wasm
	rm -f ICIP1Test.wasm