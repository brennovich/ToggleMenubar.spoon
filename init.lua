--- === ToggleMenubar ===
---
--- Toggle macOS menubar autohide setting. It's always annoying to change the autohide of the menubar, sometimes I just want to control it as easy as it is to do with the Dock (e.g. cmd+opt+D). So I created a spoon that will toggle the autohide setting of the menubar.
---
--- Download: [https://github.com/brennovich/ToggleMenubar.spoon](https://github.com/brennovich/ToggleMenubar.spoon)

local obj = {}
obj.__index = function(table, key)
	return rawget(obj, key)
end

obj.__newindex = function(table, key, value)
	if key == "gap" and value ~= 0 then
		rawset(table, "hsGridIntegration", true)
	end
	rawset(table, key, value)
end

obj.name = "ToggleMenubar"
obj.version = "1.0"
obj.author = "brennovich"
obj.license = "MIT"

--- ToggleMenubar.gap
--- Variable
--- Gap size in pixels for grid margins. Default is 0. Only useful if you use hs.grid.
obj.gap = 0

--- ToggleMenubar.hsGridIntegration
--- Variable
--- Enable hs.grid integration. When true, reapplies grid configuration after toggling menubar. Default is false. Automatically set to true when gap is configured.
obj.hsGridIntegration = false

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
	local instance = {}
	setmetatable(instance, obj)
	return instance
end

--- ToggleMenubar:toggle([deps])
--- Method
--- Toggles the macOS menubar autohide setting and reapplies grid configuration if hsGridIntegration is enabled.
---
--- Parameters:
--- * deps - Optional table with dependencies. Keys: execute, osascript, timer, grid
---
--- Returns:
--- * None
---
--- Notes:
--- * Reads current menubar state from NSGlobalDomain _HIHideMenuBar preference
--- * Uses AppleScript to toggle the autohide preference
--- * Waits 0.5 seconds for system animation before reapplying grid margins if hsGridIntegration is true
--- * This ensures window positioning remains consistent whether menubar is visible or hidden
function obj:toggle(deps)
	deps = deps or {}
	local execute = deps.execute or hs.execute
	local osascript = deps.osascript or hs.osascript
	local timer = deps.timer or hs.timer
	local grid = deps.grid or hs.grid

	local output = execute("defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null || echo 0")
	local menubarHidden = tonumber(output:match("%d+")) == 1

	osascript.applescript(string.format([[
		tell application "System Events"
			tell dock preferences to set autohide menu bar to %s
		end tell
	]], tostring(not menubarHidden)))

	if not self.hsGridIntegration then
		return
	end

	local gridSize = grid.getGrid()

	timer.doAfter(0.5, function()
		grid.setGrid(gridSize)
		if self.gap == 0 then
			return
		end
		grid.setMargins({self.gap, self.gap})
	end)
end

return obj
