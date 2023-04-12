local M = {}
M.__index = M

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

local function myHoverListener (event)
	if event.phase == "began" or event.phase =="moved" then
		parent = event.target
		if parent.btnMngr.enableInput then
			parent.btnMngr:setCurrentBtn(parent.index)
		end

	elseif event.phase == "ended" then
		if parent.btnMngr.enableInput then
			-- parent.btnMngr:setCurrentBtn(parent.index)
			print ("ended")
			print (event)
			parent.btnMngr:restoreButtonText()
		end

	end
end


local function clickButton(event)
	audioManager.playClickButton()
	target = event.target
	target.btnMngr:setCurrentBtn(target.index )
	target.btnMngr:pressButton()
end

function M:create(buttons)
   local obj = {}             -- our new object
   setmetatable(obj,M)  -- make Account handle lookup
	-- Runtime:addEventListener( "key", onKeyEvent )
	obj.paused = false
	obj.buttons = buttons
	--obj.commands = commands
	obj.enableInput = true

	for k,v in pairs(buttons) do
		v:addEventListener( "tap", clickButton )
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

function M:restoreButtonText()
	if self.currentButton.text then
		self.currentButton.text = self.originalText
	end
end

function M:setCurrentBtn(i)
	if self.enableInput then
		if i > table.getn(self.buttons) then
			i = 1
		end
		if i<1 then
			i =  table.getn(self.buttons)
		end

		if i ~= self.index then
			audioManager.playSelectButton()
		--	button = self.currentButton

			-- if self.currentButton.text then
			-- 	self.currentButton.text = self.originalText
			-- end
			self:restoreButtonText()

			self.index = i
			self.currentButton = self.buttons[i]

			self:updateTextButton()
			-- if self.currentButton.text then
			-- 	self.originalText = self.currentButton.text
			-- 	self.currentButton.text = "- " .. self.currentButton.text .. " -"
			-- end

		end
		self:updateTextButton()

		-- print ( string.starts(self.currentButton.text, "- "))
		-- if self.currentButton.text then
		-- 	self.originalText = self.currentButton.text
		-- 	self.currentButton.text = "- " .. self.currentButton.text .. " -"
		-- end

	end
end

function M:updateTextButton()
	-- and
	if  self.currentButton.text and not ( string.starts(self.currentButton.text, "- ")) then
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

	-- this breaks
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
function M:getButtonAtIndex(i)
	--self:setCurrentBtn()
	self:setCurrentBtn( i )
end


function M:pressButton()
	--self:setCurrentBtn()
	print("press button")
	audioManager.playClickButton()
	self.enableInput = false
	button = self.buttons[self.index]
	if button.arguments then
		button.command(button.arguments)
	else
		button.command()

	end

--	self.commands[self.index]()
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
