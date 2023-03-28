local M = {}
M.__index = M

local function myHoverListener (event)
	parent = event.target
	parent.btnMngr:setCurrentBtn(parent.index)
end

function M:create(buttons, commands)
   local obj = {}             -- our new object
   setmetatable(obj,M)  -- make Account handle lookup
	-- Runtime:addEventListener( "key", onKeyEvent )
	obj.paused = false
	obj.buttons = buttons
	obj.commands = commands
	obj.enableInput = true

	for k,v in pairs(buttons) do
		v:addEventListener( "tap", commands[k] )
		v:addEventListener( "mouseHover", myHoverListener)
			--playButton:addEventListener("mouseHover", myHoverListener)
			v.index = k
			v.btnMngr = obj
	end

	obj.currentButton = buttons[1]
	obj.index = 1
	obj.originalText = obj.currentButton.text
	--obj.currentButton.text = "- " .. obj.currentButton.text .. " -"
	return obj
end


function M:setCurrentBtn(i)
	if self.enableInput then
		if i > table.getn(self.buttons) then
			i = 1
		end
		if i<1 then
			i =  table.getn(self.buttons)
		end

		self.currentButton.text = self.originalText
		self.index = i
		self.currentButton = self.buttons[i]
		self.originalText = self.currentButton.text
		self.currentButton.text = "- " .. self.currentButton.text .. " -"
	end
end

-- function M:refresh()
-- 	self.originalText = self.currentButton.text
-- 	self.currentButton.text = "- " .. self.currentButton.text .. " -"
-- end

function M:pause()
	if not self.enableInput then
		return false
	end
	print("pause btn mngr")
	self.currentButton.text = self.originalText
	self.enableInput = false
end

function M:resume()
	if self.enableInput then
		return false
	end
	print("resume btn mngr")

	-- this shit breaks
	-- self.originalText = self.currentButton.text
	-- self.currentButton.text = "- " .. self.currentButton.text .. " -"

	self.enableInput = true
end

function M:getNextButton()
	--self:setCurrentBtn()
	self:setCurrentBtn(self.index + 1 )
end
function M:getPrevButton()
	--self:setCurrentBtn()
	self:setCurrentBtn(self.index - 1 )
end

function M:pressButton()
	--self:setCurrentBtn()
	print("press button")
	self.commands[self.index]()
	self.enableInput = false
end

-- function onKeyEvent(event)
--  	M:onKeyEvent(event)
-- end
--
-- function M:onKeyEvent(event)
-- --
-- 		if (event.phase=="up") then return false
-- 		end
--
--     if ( event.keyName == "up" ) then
-- 			getNextButton()
--     elseif event.keyName == "down" then
-- 			getNextButton()
--
-- 	   -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
-- 	    if ( event.keyName == "back" ) then
-- 	        local platformName = system.getInfo( "platformName" )
-- 	    --	composer.gotoScene( "menu" )
-- 	        if ( platformName == "Android" ) or ( platformName == "WinPhone" ) then
-- 	            return true
-- 	        end
-- 	    end
-- 	    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
-- 	    -- This lets the operating system execute its default handling of the key
-- 	    return false
-- 		end
-- end


return M
