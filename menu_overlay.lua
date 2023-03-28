
--local composer = require( "composer" )
local scene = composer.newScene()

local buttonManager =      require("scripts.buttonManager")
local btnMngr = nil
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
	composer.hideOverlay( "fade", 0 )
end
local function gotoMenu()
	composer.gotoScene( "menu" )
end

local function gotoLevelSelect()
	composer.gotoScene( "levelSelect" )
	--composer.hideScene( "levelSelect" )
end

local function gotoCredits()
	composer.gotoScene( "credits" )
end


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


	local playButton = display.newText( sceneGroup, "Continue", display.contentCenterX, 500, native.systemFont, textSize*scale )
	local menuBtn = display.newText( sceneGroup, "Menu", display.contentCenterX, 700, native.systemFont, textSize*scale )

	playButton:addEventListener( "tap", gotoGame )
	menuBtn:addEventListener( "tap", gotoMenu )

	local buttons = {playButton, menuBtn}
	local commands = {gotoGame,gotoMenu  }
	btnMngr = buttonManager:create(buttons,commands)


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

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
			Runtime:removeEventListener( "key", onKeyEvent )
      parent:resumeGame()
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
