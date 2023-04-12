
--local composer = require( "composer" )
local scene = composer.newScene()

local buttonManager =      require("scripts.buttonManager")
local btnMngr = nil
local retryLevelCommand
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- button manager
-- input all buttons
--
--local function

local function gotoGame()
	--composer.gotoScene( "game" )
	composer.hideOverlay( "fade", 200 )
end

local function retryLevel()
	retryLevelCommand()
	gotoGame()
end


local function gotoMenu()
	composer.gotoScene( "menu",changeSceneOptions )
end

-- local function gotoLevelSelect()
-- 	composer.gotoScene( "levelSelect" )
-- 	--composer.hideScene( "levelSelect" )
-- end

-- local function gotoCredits()
-- 	composer.gotoScene( "credits" )
-- end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )


	print ("create overlay")

	local sceneGroup = self.view

	local darkOverlay = display.newRect(sceneGroup ,display.contentCenterX,display.contentCenterY,  display.contentHeight,display.contentWidth)
	darkOverlay.xScale = 2.1
	darkOverlay.yScale = 2.1
	darkOverlay:setFillColor( 0, 0, 0 )
	darkOverlay.alpha = 0.7

	-- local obj = display.newImageRect( sceneGroup, "textures/menuOverlay.png", 70, 40 )
	-- obj.x, obj.y = display.contentCenterX, display.contentCenterY
	-- obj.xScale = scale * 2
	-- obj.yScale = scale * 2
	retryLevelCommand = event.params.retryLevelCommand

	local textOptions = {
		parent = sceneGroup,
		text = "Continue",
		x = display.contentCenterX, 
		y = 400, 
		font = native.systemFont, 
		fontSize = textSize*scale,
		align = "center"
	}

	local playButton = display.newText( textOptions)
	textOptions.text = "Retry"
	textOptions.y = 600
	local retryBtn = display.newText( textOptions )
	textOptions.text = "Menu"
	textOptions.y = 800
	local menuBtn = display.newText( textOptions )
	
-- local playButton = display.newText( sceneGroup, "Continue", display.contentCenterX, 400, native.systemFont, textSize*scale )
-- 	local retryBtn = display.newText( sceneGroup, "Retry", display.contentCenterX, 600, native.systemFont, textSize*scale )
-- 	local menuBtn = display.newText( sceneGroup, "Menu", display.contentCenterX,800 , native.systemFont, textSize*scale )

	-- 	playButton:addEventListener( "tap", gotoGame )
	-- retryBtn:addEventListener( "tap", retryLevel )
	-- menuBtn:addEventListener( "tap", gotoMenu )

	playButton.command = gotoGame
	retryBtn.command = retryLevel
	menuBtn.command = gotoMenu


	local buttons = {playButton, retryBtn, menuBtn}
	--local commands = {gotoGame,retryLevel, gotoMenu  }
	btnMngr = buttonManager:create(buttons)


	-- local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 400, native.systemFont, 44 )
	-- highScoresButton:setFillColor( 0.75, 0.78, 1 )



	local stage = display.getCurrentStage()

	--stage:insert( background )
	-- stage:insert( composer.stage )
	-- stage:insert( playButton )
	-- stage:insert( lvlSelectButton )
	-- stage:insert( menuBtn )

	-- TODO remove this later
	-- skip menu for debug purpose
	--gotoGame()
end

local function onKeyEvent(event)

		if (event.phase=="up") then return false
		end

		if ( event.keyName == "up" ) then
			btnMngr:getPrevButton()
		elseif event.keyName == "down" then
			btnMngr:getNextButton()
		elseif ( event.keyName == "enter" ) then
			btnMngr:pressButton()

   -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
 		elseif ( event.keyName == "back" ) then
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


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
			  audio.play( audioManager.openMenu )

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

			print ("show overlay")

			btnMngr:resume()
			Runtime:removeEventListener( "key", onKeyEvent )
			Runtime:addEventListener( "key", onKeyEvent )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view

	local phase = event.phase
	local parent = event.parent

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
				  audio.play( audioManager.closeMenu )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
			Runtime:removeEventListener( "key", onKeyEvent )
			if parent.name == "Game" then
      	parent:resumeGame()
			end
			btnMngr:pause()
	end
end


-- destroy()
function scene:destroy( event )
print ("destroy overlay")
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
