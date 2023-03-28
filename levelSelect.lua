
--local composer = require( "composer" )

--local math =  require( "math" )

local scene = composer.newScene()
local levels = 20
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function onKeyEvent(event)
		if (event.phase=="up") then return false
		end

	composer.gotoScene( "menu" )
end

-- create()
local function loadLevel(event)-- event )
	--print ( event.target.lvl )
		currentLevel = event.target.lvl
		if currentLevel >2 then currentLevel = 2 end
		composer.gotoScene( "game" )
end

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	for lvl = 1,levels,1 do


		local lvlLoadButton = display.newImageRect( sceneGroup, "textures/lvlSelectBtn.png", 40,40 )
		lvlLoadButton.x, lvlLoadButton.y = -display.contentCenterX/2  + 300* ( (lvl-1)%5),  300* math.floor ((lvl-1)/5)
		lvlLoadButton.xScale = scale
		lvlLoadButton.yScale = scale

		local lvlText = display.newText( sceneGroup, lvl , -display.contentCenterX/2  + 300* ((lvl-1)%5),  300* math.floor((lvl-1)/5), native.systemFont, 20*scale )
		lvlText.x, lvlText.y = -display.contentCenterX/2  + 300* ( (lvl-1)%5),  300* math.floor ((lvl-1)/5)

		lvlLoadButton.lvl = lvl
		lvlLoadButton:addEventListener( "tap", loadLevel )

	end

end


-- show()
function scene:show( event )

		Runtime:removeEventListener( "key", onKeyEvent )
			Runtime:addEventListener( "key", onKeyEvent )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

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
