.PHONY: test install-deps

build: docs.json
	mkdir -p release/ToggleMenubar.spoon
	cp init.lua docs.json release/ToggleMenubar.spoon/
	cd release && zip -r ToggleMenubar.spoon.zip ToggleMenubar.spoon

docs.json: init.lua
	hs -c "hs.doc.builder.genJSON(\"$$(pwd)\")" | grep -v "^--" > $@

install-deps:
	luarocks install --local --only-deps togglemenubar-1.0-1.rockspec

test:
	eval $$(luarocks --local path) && lua tests/test.lua -o TAP
