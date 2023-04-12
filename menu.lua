
--local composer = require( "composer" )
mouseHover = require "plugin.mouseHover"

local anim =      require("scripts.AnimData")
local buttonManager =      require("scripts.buttonManager")
local btnMngr = nil

-- local btnMngr = {}

local background = display.newGroup()
local midground = display.newGroup()  --this will overlay 'farBackground'
local foreground = display.newGroup()
local UILayer = display.newGroup()
local playButton
local scene = composer.newScene()
currentLevel = 1

-- composer.getScene( "game" )
-- composer.getScene( "levelSelect" )
-- composer.getScene( "credits" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

	-- local myHoverListener = function(event)
	-- 	print("hover")
	-- 	if event.phase == "began" then
	-- 	-- respond to the hover event here
	-- 		print(event.phase, event.target, event.x, event.y)
	-- 	end
  --
	-- 	if event.phase == "ended" then
	-- 	-- respond to the hover event here
	-- 		print(event.phase, event.target, event.x, event.y)
	-- 	end
  --
	-- end

function setTextToContinue()
	playButton.text = localisationManager.continue
	btnMngr.originalText = playButton.text

end

local function gotoGame()
	timer.performWithDelay( 500 , setTextToContinue)
	composer.gotoScene( "game" ,changeSceneOptions )
end

local function gotoLevelSelect()
	composer.gotoScene( "levelSelect" ,changeSceneOptions )
end

local function gotoCredits()
	composer.gotoScene( "credits"  ,changeSceneOptions)
end

--local function



function onKeyEvent(event)

		if (event.phase=="up") then
			return false
		end

	    -- if not menuOverlayVisible then
	      if ( event.keyName == "up" ) then
					btnMngr:getPrevButton()
	      elseif event.keyName == "down" then
					btnMngr:getNextButton()
	      end
	    -- end

				if ( event.keyName == "enter" ) then
					print ("enter")
					-- get btn from current button
					btnMngr:pressButton()

				end

	    -- print("check escape menu")
	    -- if ( event.keyName == "escape" ) then
	    --   resumeGame()
	    -- end

	   -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
	    if ( event.keyName == "back" ) then
	        local platformName = system.getInfo( "platformName" )
	    --	composer.gotoScene( "menu" )
	        if ( platformName == "Android" ) or ( platformName == "WinPhone" ) then
	            return true
	        end
	    end

	    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
	    -- This lets the operating system execute its default handling of the key
	    return false
end

local function quitGame()

	native.requestExit()
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	Runtime:addEventListener( "key", onKeyEvent )

	local sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen

	--local background = display.newImageRect( sceneGroup, "textures/story1.png", 140, 60 )

	local background = display.newSprite(sceneGroup, anim.imageSheetTemple,anim.sequences_temple)

	background:play()

	background.x = display.contentCenterX
	background.y = display.contentCenterY
	background.xScale = display.contentHeight/70
	background.yScale = display.contentHeight/70

	
	-- background.xScale = 1.5
	-- background.yScale = 1.5

	-- local title = display.newImageRect( sceneGroup, "title.png", 500, 80 )
	-- title.x = display.contentCenterX
	-- title.y = 200


	  -- for i=0,5,1 do
		-- 	local menuButton = display.newImageRect(sceneGroup,"textures/menuButton.png",80,11)
		-- 	menuButton.xScale = 15
		-- 	menuButton.yScale = 15
		-- 	menuButton.x = display.contentWidth+100
		-- 	menuButton.y = 350 + 200*i
		-- 	print (display.contentHeight)
		-- 	print(i)
		-- end

		local logo = display.newImageRect( sceneGroup, "textures/logo.png", 140, 60 )
			-- logo.x = display.contentCenterX
			-- logo.y = display.contentCenterY
			-- logo.xScale = display.contentHeight/100
			-- logo.yScale = display.contentHeight/100

		logo.xScale = 8
		logo.yScale = 8
		logo.x = display.contentWidth+100
		logo.y = 300

	local yOffsetParent = 350
	local yOffset = 165
	local textOptions = {
		parent = sceneGroup,
		text = localisationManager.play, --"Play",
		x = display.contentWidth+100, 
		y = yOffset*1 + yOffsetParent, 
		font = native.systemFont, 
		fontSize = textSize*scale,
		-- width = 1200,
		-- height = 150,
		align = "center"
	}

	playButton = 			display.newText( textOptions )
	textOptions.text = 		localisationManager.levelSelect
	textOptions.y = 		2*yOffset + yOffsetParent

	local lvlSelectButton = display.newText( textOptions )
	textOptions.text = 		localisationManager.credits
	textOptions.y = 		3* yOffset + yOffsetParent
	local creditBtn = 		display.newText( textOptions )
	textOptions.text =		localisationManager.quit
	textOptions.y = 		4* yOffset + yOffsetParent
	local quitBtn = 		display.newText( textOptions )


	playButton.command = gotoGame
	lvlSelectButton.command = gotoLevelSelect
	creditBtn.command = gotoCredits
	quitBtn.command = quitGame


	local buttons = {playButton,lvlSelectButton,creditBtn,quitBtn}
	btnMngr = buttonManager:create(buttons)




	--set currentlevel based on save data 
    currentLevel = saveManager:getLastActiveLevel() + 1
    if currentLevel~=1 then setTextToContinue() end
    print ("should load level")
    print (currentLevel)



end


-- show()
function scene:show( event )
	-- composer.removeScene("menu_overlay")
	-- composer.hideOverlay("menu_overlay")

	composer.hideOverlay( "menu_overlay" )

		Runtime:removeEventListener( "key", onKeyEvent )
		Runtime:addEventListener( "key", onKeyEvent )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

			print ("show menu")
			btnMngr:resume()
	end
end


-- hide()
function scene:hide( event )

	Runtime:removeEventListener( "key", onKeyEvent )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

		print ("hide menu")
		btnMngr:pause()

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------


return scene
