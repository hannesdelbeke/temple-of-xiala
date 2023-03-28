
--local composer = require( "composer" )


local scene = composer.newScene()

creditText = {
"Hannes Delbeke",
"backer1",
"backer1",
"backer1"
}


-- creditText = "Hannes Delbeke"..
-- "backer1"..
-- "backer1"..
-- "backer1"



-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
--local creditTextObj
-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	creditTextCombined = ""
	for k,v in pairs(creditText) do
		creditTextCombined = creditTextCombined.. v .. "\n"
	end

	local options =
	{
			parent = sceneGroup ,
	    text =creditTextCombined,
	    x = display.contentCenterX,
	    y = 200,
	   -- width = 128,
	    font = native.systemFont,
	    fontSize = 44,
	    align = "center"  -- Alignment parameter
	}

	--display.newText( sceneGroup, creditTextCombined, display.contentCenterX, 300, native.systemFont, 44 ,align=center)
	display.newText(options)

end

local function onKeyEvent(event)
		if (event.phase=="up") then return false
		end
	composer.gotoScene( "menu" )
end

-- show()
function scene:show( event )
	--creditTextObj.isVisible = true
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
	--creditTextObj.isVisible = false
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
