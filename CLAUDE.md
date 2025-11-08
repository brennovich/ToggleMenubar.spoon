# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Hammerspoon Spoon that toggles macOS menubar visibility while maintaining consistent window grid margins. A Spoon is a modular plugin for Hammerspoon (macOS automation tool).

## Technology Stack

- Lua (Hammerspoon API)
- AppleScript (for system preferences control)
- macOS system defaults commands

## Architecture

The spoon consists of a single module (`init.lua`) that:

1. Reads menubar state from macOS preferences using `defaults read NSGlobalDomain _HIHideMenuBar`
2. Toggles the menubar autohide preference via AppleScript through System Events
3. Reapplies Hammerspoon grid configuration after a 0.5s delay to account for system animations

The grid margin reapplication is critical - it ensures window positioning remains consistent whether the menubar is visible or hidden.

## Testing

### Unit Tests

The spoon uses LuaUnit for testing. Tests are located in the `tests/` directory.

To run tests:
```bash
make test
```

To install test dependencies:
```bash
make install-deps
luarocks install --local luaunit
```

The code is designed for testability by accepting dependencies as optional parameters. The `toggle()` method accepts an optional `deps` table with mocked dependencies for testing.

### Manual Testing

To test the spoon manually in Hammerspoon:

1. Place the spoon in `~/.hammerspoon/Spoons/ToggleMenubar.spoon/`
2. Reload Hammerspoon configuration: Console > Reload Config (or `hs.reload()`)
3. Test in Hammerspoon console:
   ```lua
   hs.loadSpoon("ToggleMenubar")
   spoon.ToggleMenubar:toggle()
   ```

## Key Implementation Details

- The 0.5 second delay before grid reapplication matches the macOS menubar animation timing
- State detection must handle the case where the preference doesn't exist (defaults to 0/visible)
- AppleScript boolean values must be stringified ("true"/"false") for proper execution
- The `gap` property is configurable and used for grid margins
