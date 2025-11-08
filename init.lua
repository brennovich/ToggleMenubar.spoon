--- === ToggleMenubar ===
---
--- Toggle macOS menubar visibility while maintaining consistent window grid margins
---
--- Download: [https://github.com/brennovich/ToggleMenubar.spoon](https://github.com/brennovich/ToggleMenubar.spoon)

local obj = {}
obj.__index = obj

obj.name = "ToggleMenubar"
obj.version = "1.0"
obj.author = "brennovich"
obj.license = "MIT"

--- ToggleMenubar.gap
--- Variable
--- Gap size in pixels for grid margins. Default is 10
obj.gap = 10

--- ToggleMenubar:init()
--- Method
--- Initializes the spoon
---
--- Parameters:
--- * None
---
--- Returns:
--- * The ToggleMenubar object
function obj:init()
	return self
end

--- ToggleMenubar:toggle([deps])
--- Method
--- Toggles the macOS menubar visibility and reapplies grid configuration
---
--- Parameters:
--- * deps - Optional table with dependencies for testing. Keys: execute, osascript, timer, grid
---
--- Returns:
--- * None
---
--- Notes:
--- * Reads current menubar state from NSGlobalDomain _HIHideMenuBar preference
--- * Uses AppleScript to toggle the autohide preference
--- * Waits 0.5 seconds for system animation before reapplying grid margins
--- * This ensures window positioning remains consistent whether menubar is visible or hidden
function obj:toggle(deps)
	deps = deps or {}
	local execute = deps.execute or hs.execute
	local osascript = deps.osascript or hs.osascript
	local timer = deps.timer or hs.timer
	local grid = deps.grid or hs.grid

	local output = execute("defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null || echo 0")
	local menubarHidden = tonumber(output:match("%d+")) == 1
	local gridSize = grid.getGrid()

	osascript.applescript(string.format([[
		tell application "System Events"
			tell dock preferences to set autohide menu bar to %s
		end tell
	]], tostring(not menubarHidden)))

	timer.doAfter(0.5, function()
		grid.setGrid(gridSize)
		grid.setMargins({self.gap, self.gap})
	end)
end

return obj
