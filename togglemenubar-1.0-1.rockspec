rockspec_format = "3.0"
package = "ToggleMenubar"
version = "1.0-1"

source = {
   url = "."
}

description = {
   summary = "Toggle macOS menubar visibility while maintaining consistent window grid margins",
   detailed = [[
      ToggleMenubar provides a simple interface to show/hide the macOS menubar
      while maintaining consistent grid margins for window management.
   ]],
   homepage = "https://github.com/brennovich/ToggleMenubar.spoon",
   license = "MIT"
}

dependencies = {
   "lua >= 5.3"
}

test_dependencies = {
   "luaunit >= 3.4"
}

build = {
   type = "none"
}

test = {
   type = "command",
   command = "eval $(luarocks --local path) && lua tests/test.lua -o TAP"
}
