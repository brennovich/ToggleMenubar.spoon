local lu = require('luaunit')

TestToggleMenubar = {}

function TestToggleMenubar.mockDeps(overrides)
	overrides = overrides or {}

	local defaults = {
		execute = function() return "0" end,
		timer = { doAfter = function() end },
		grid = {
			getGrid = function() return {w = 2, h = 2} end,
			setGrid = function() end,
			setMargins = function() end
		},
		osascript = { applescript = function() return true end }
	}

	local function merge(base, override)
		if type(override) ~= "table" then
			return override
		end
		local result = {}
		for k, v in pairs(base) do
			result[k] = override[k] and merge(v, override[k]) or v
		end
		for k, v in pairs(override) do
			if result[k] == nil then
				result[k] = v
			end
		end
		return result
	end

	return merge(defaults, overrides)
end

function TestToggleMenubar:setUp()
	package.loaded['init'] = nil
	self.ToggleMenubar = require('init')
end

function TestToggleMenubar:testInit()
	local menubar = self.ToggleMenubar:init()
	lu.assertNotNil(menubar)
end

function TestToggleMenubar:testDefaultGap()
	local menubar = self.ToggleMenubar:init()
	lu.assertEquals(menubar.gap, 0)
end

function TestToggleMenubar:testDefaultHsGridIntegration()
	local menubar = self.ToggleMenubar:init()
	lu.assertEquals(menubar.hsGridIntegration, false)
end

function TestToggleMenubar:testCustomGap()
	local menubar = self.ToggleMenubar:init()
	menubar.gap = 20
	lu.assertEquals(menubar.gap, 20)
end

function TestToggleMenubar:testSettingGapEnablesHsGridIntegration()
	local menubar = self.ToggleMenubar:init()
	menubar.gap = 20
	lu.assertEquals(menubar.hsGridIntegration, true)
end

function TestToggleMenubar:testSettingGapToZeroDoesNotDisableHsGridIntegration()
	local menubar = self.ToggleMenubar:init()
	menubar.gap = 20
	lu.assertEquals(menubar.hsGridIntegration, true)
	menubar.gap = 0
	lu.assertEquals(menubar.hsGridIntegration, true)
end

function TestToggleMenubar:testToggleReadsCurrentMenubarState()
	local executeCallCount = 0

	local menubar = self.ToggleMenubar:init()
	menubar:toggle(self.mockDeps({
		execute = function(cmd)
			executeCallCount = executeCallCount + 1
			lu.assertStrContains(cmd, "_HIHideMenuBar")
			return "0"
		end
	}))

	lu.assertEquals(executeCallCount, 1)
end

function TestToggleMenubar:testToggleShowsMenubarWhenHidden()
	local applescriptCalled = false
	local applescriptValue = nil

	local menubar = self.ToggleMenubar:init()
	menubar:toggle(self.mockDeps({
		execute = function() return "1" end,
		osascript = {
			applescript = function(script)
				applescriptCalled = true
				applescriptValue = script:match("autohide menu bar to (%a+)")
				return true
			end
		}
	}))

	lu.assertTrue(applescriptCalled)
	lu.assertEquals(applescriptValue, "false")
end

function TestToggleMenubar:testToggleHidesMenubarWhenVisible()
	local applescriptCalled = false
	local applescriptValue = nil

	local menubar = self.ToggleMenubar:init()
	menubar:toggle(self.mockDeps({
		osascript = {
			applescript = function(script)
				applescriptCalled = true
				applescriptValue = script:match("autohide menu bar to (%a+)")
				return true
			end
		}
	}))

	lu.assertTrue(applescriptCalled)
	lu.assertEquals(applescriptValue, "true")
end

function TestToggleMenubar:testToggleReappliesGridConfiguration()
	local setGridCalled = false
	local setMarginsCalled = false
	local timerCallback = nil

	local menubar = self.ToggleMenubar:init()
	menubar.gap = 15

	menubar:toggle(self.mockDeps({
		timer = {
			doAfter = function(delay, callback)
				lu.assertEquals(delay, 0.5)
				timerCallback = callback
			end
		},
		grid = {
			getGrid = function() return {w = 3, h = 2} end,
			setGrid = function(size)
				setGridCalled = true
				lu.assertEquals(size.w, 3)
				lu.assertEquals(size.h, 2)
			end,
			setMargins = function(margins)
				setMarginsCalled = true
				lu.assertEquals(margins[1], 15)
				lu.assertEquals(margins[2], 15)
			end
		}
	}))

	lu.assertNotNil(timerCallback)
	timerCallback()
	lu.assertTrue(setGridCalled)
	lu.assertTrue(setMarginsCalled)
end

function TestToggleMenubar:testToggleUsesCustomGap()
	local marginValues = nil
	local timerCallback = nil

	local menubar = self.ToggleMenubar:init()
	menubar.gap = 25

	menubar:toggle(self.mockDeps({
		timer = { doAfter = function(delay, callback) timerCallback = callback end },
		grid = { setMargins = function(margins) marginValues = margins end }
	}))

	timerCallback()
	lu.assertNotNil(marginValues)
	lu.assertEquals(marginValues[1], 25)
	lu.assertEquals(marginValues[2], 25)
end

function TestToggleMenubar:testToggleSkipsGridReapplicationWhenHsGridIntegrationIsFalse()
	local setGridCalled = false
	local setMarginsCalled = false

	local menubar = self.ToggleMenubar:init()
	menubar.hsGridIntegration = false

	menubar:toggle(self.mockDeps({
		timer = { doAfter = function() lu.fail("Timer should not be called when hsGridIntegration is false") end },
		grid = {
			setGrid = function() setGridCalled = true end,
			setMargins = function() setMarginsCalled = true end
		}
	}))

	lu.assertFalse(setGridCalled)
	lu.assertFalse(setMarginsCalled)
end

function TestToggleMenubar:testToggleReappliesGridWhenHsGridIntegrationIsTrue()
	local setGridCalled = false
	local timerCallback = nil

	local menubar = self.ToggleMenubar:init()
	menubar.hsGridIntegration = true

	menubar:toggle(self.mockDeps({
		timer = {
			doAfter = function(delay, callback) timerCallback = callback end
		},
		grid = {
			setGrid = function() setGridCalled = true end
		}
	}))

	lu.assertNotNil(timerCallback)
	timerCallback()
	lu.assertTrue(setGridCalled)
end

function TestToggleMenubar:testInstancesAreIndependent()
	local m1 = self.ToggleMenubar:init()
	local m2 = self.ToggleMenubar:init()

	m1.gap = 20
	m1.hsGridIntegration = true

	lu.assertEquals(m1.gap, 20)
	lu.assertEquals(m1.hsGridIntegration, true)
	lu.assertEquals(m2.gap, 0)
	lu.assertEquals(m2.hsGridIntegration, false)
end

function TestToggleMenubar:testToggleResetsGridWhenHsGridIntegrationTrueButGapIsZero()
	local setGridCalled = false
	local setMarginsCalled = false
	local timerCallback = nil

	local menubar = self.ToggleMenubar:init()
	menubar.hsGridIntegration = true
	menubar.gap = 0

	menubar:toggle(self.mockDeps({
		timer = {
			doAfter = function(delay, callback) timerCallback = callback end
		},
		grid = {
			setGrid = function() setGridCalled = true end,
			setMargins = function() setMarginsCalled = true end
		}
	}))

	lu.assertNotNil(timerCallback)
	timerCallback()
	lu.assertTrue(setGridCalled)
	lu.assertFalse(setMarginsCalled)
end

return TestToggleMenubar
