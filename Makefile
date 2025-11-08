.PHONY: test install-deps

docs.json: init.lua
	hs -c "hs.doc.builder.genJSON(\"$$(pwd)\")" | grep -v "^--" > $@

install-deps:
	luarocks install --local --only-deps togglemenubar-1.0-1.rockspec

test:
	eval $$(luarocks --local path) && lua tests/test.lua -o TAP
