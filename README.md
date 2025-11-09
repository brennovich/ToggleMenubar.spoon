# ToggleMenubar.spoon

ToggleMenubar provides a simple interface to toggle the autohide of the macOS menubar while maintaining consistent `hs.grid` margins for window management.

## Usage

```lua
hs.loadSpoon("ToggleMenubar")
spoon.ToggleMenubar.gap = 15

-- Similar to autohide Dock toggle that is cmd+opt+D
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "D", function()
    spoon.ToggleMenubar:toggle()
end)
```

## How it works

- Reads current menubar state from system defaults
- Toggles menubar visibility using AppleScript
- Waits 0.5 seconds for system animation
- Reapplies grid configuration with margins

This ensures the grid system accounts for the menubar space, keeping window positioning consistent whether the menubar is visible or hidden.

## Implementation Details

The spoon uses multiple methods to ensure reliable operation:

1. **State Detection:** Reads `NSGlobalDomain _HIHideMenuBar` preference to determine current state
2. **Toggle Operation:** Uses AppleScript via System Events to toggle the autohide preference
3. **Grid Refresh:** Reapplies grid configuration after a delay to account for system animations

## Development

### Unit Tests

The spoon uses LuaUnit for testing. Tests are located in the `tests/` directory.

To run tests:
```bash
make test
```

To install test dependencies:
```bash
make install-deps
```

## Acceptance Tests

By running `make acceptance-test`, the acceptance test suite will run a simple script that expects the spoon to be already loaded in Hammerspoon and will toggle the menubar state and verify the state change using OCR to read the menubar text and determine its state.

Requirements:
- tesseract OCR installed (`brew install tesseract`)
- Hammerspoon running with ToggleMenubar spoon loaded

### Docs

To generate documentation for the spoon, run the following command in the terminal:

```bash
make docs.json
```

## Release

The project uses GitHub Actions to automate testing, packaging, and releases. On every push to main, the pipeline:

1. **Commit** - Runs tests and generates the release candidate artifact
2. **Acceptance** - Validates the packaged spoon loads in Hammerspoon
3. **Release** - Creates a versioned GitHub release with ToggleMenubar.spoon.zip

Releases use semantic versioning based on conventional commit messages (feat, fix, chore, etc.).
