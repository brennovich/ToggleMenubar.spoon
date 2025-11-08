local lu = require('luaunit')

TestToggleMenubar = {}

function TestToggleMenubar:setUp()
	package.loaded['init'] = nil
	self.ToggleMenubar = require('init')
end

function TestToggleMenubar:testInit()
	local menubar = self.ToggleMenubar:init()
	lu.assertNotNil(menubar)
	lu.assertEquals(menubar.gap, 10)
end

function TestToggleMenubar:testDefaultGap()
	local menubar = self.ToggleMenubar:init()
	lu.assertEquals(menubar.gap, 10)
end

function TestToggleMenubar:testCustomGap()
	local menubar = self.ToggleMenubar:init()
	menubar.gap = 20
	lu.assertEquals(menubar.gap, 20)
end

function TestToggleMenubar:testToggleReadsCurrentMenubarState()
	local executeCallCount = 0
	local mockExecute = function(cmd)
		executeCallCount = executeCallCount + 1
		lu.assertStrContains(cmd, "_HIHideMenuBar")
		return "0"
	end

	local mockTimer = {
		doAfter = function() end
	}

	local mockGrid = {
		getGrid = function() return {w = 2, h = 2} end,
		setGrid = function() end,
		setMargins = function() end
	}

	local mockOsascript = {
		applescript = function() return true end
	}

	local menubar = self.ToggleMenubar:init()
	menubar:toggle({
		execute = mockExecute,
		timer = mockTimer,
		grid = mockGrid,
		osascript = mockOsascript
	})

	lu.assertEquals(executeCallCount, 1)
end

function TestToggleMenubar:testToggleShowsMenubarWhenHidden()
	local applescriptCalled = false
	local applescriptValue = nil

	local mockExecute = function()
		return "1"
	end

	local mockTimer = {
		doAfter = function() end
	}

	local mockGrid = {
		getGrid = function() return {w = 2, h = 2} end,
		setGrid = function() end,
		setMargins = function() end
	}

	local mockOsascript = {
		applescript = function(script)
			applescriptCalled = true
			applescriptValue = script:match("autohide menu bar to (%a+)")
			return true
		end
	}

	local menubar = self.ToggleMenubar:init()
	menubar:toggle({
		execute = mockExecute,
		timer = mockTimer,
		grid = mockGrid,
		osascript = mockOsascript
	})

	lu.assertTrue(applescriptCalled)
	lu.assertEquals(applescriptValue, "false")
end

function TestToggleMenubar:testToggleHidesMenubarWhenVisible()
	local applescriptCalled = false
	local applescriptValue = nil

	local mockExecute = function()
		return "0"
	end

	local mockTimer = {
		doAfter = function() end
	}

	local mockGrid = {
		getGrid = function() return {w = 2, h = 2} end,
		setGrid = function() end,
		setMargins = function() end
	}

	local mockOsascript = {
		applescript = function(script)
			applescriptCalled = true
			applescriptValue = script:match("autohide menu bar to (%a+)")
			return true
		end
	}

	local menubar = self.ToggleMenubar:init()
	menubar:toggle({
		execute = mockExecute,
		timer = mockTimer,
		grid = mockGrid,
		osascript = mockOsascript
	})

	lu.assertTrue(applescriptCalled)
	lu.assertEquals(applescriptValue, "true")
end

function TestToggleMenubar:testToggleReappliesGridConfiguration()
	local setGridCalled = false
	local setMarginsCalled = false
	local timerCallback = nil

	local mockExecute = function()
		return "0"
	end

	local mockTimer = {
		doAfter = function(delay, callback)
			lu.assertEquals(delay, 0.5)
			timerCallback = callback
		end
	}

	local mockGrid = {
		getGrid = function() return {w = 3, h = 2} end,
		setGrid = function(size)
			setGridCalled = true
			lu.assertEquals(size.w, 3)
			lu.assertEquals(size.h, 2)
		end,
		setMargins = function(margins)
			setMarginsCalled = true
			lu.assertEquals(margins[1], 10)
			lu.assertEquals(margins[2], 10)
		end
	}

	local mockOsascript = {
		applescript = function() return true end
	}

	local menubar = self.ToggleMenubar:init()
	menubar:toggle({
		execute = mockExecute,
		timer = mockTimer,
		grid = mockGrid,
		osascript = mockOsascript
	})

	lu.assertNotNil(timerCallback)

	timerCallback()

	lu.assertTrue(setGridCalled)
	lu.assertTrue(setMarginsCalled)
end

function TestToggleMenubar:testToggleUsesCustomGap()
	local marginValues = nil
	local timerCallback = nil

	local mockExecute = function()
		return "0"
	end

	local mockTimer = {
		doAfter = function(delay, callback)
			timerCallback = callback
		end
	}

	local mockGrid = {
		getGrid = function() return {w = 2, h = 2} end,
		setGrid = function() end,
		setMargins = function(margins)
			marginValues = margins
		end
	}

	local mockOsascript = {
		applescript = function() return true end
	}

	local menubar = self.ToggleMenubar:init()
	menubar.gap = 25
	menubar:toggle({
		execute = mockExecute,
		timer = mockTimer,
		grid = mockGrid,
		osascript = mockOsascript
	})

	timerCallback()

	lu.assertNotNil(marginValues)
	lu.assertEquals(marginValues[1], 25)
	lu.assertEquals(marginValues[2], 25)
end

return TestToggleMenubar
