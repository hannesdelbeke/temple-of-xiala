
--local composer = require( "composer" )

--local math =  require( "math" )

local scene = composer.newScene()

local anim =      require("scripts.AnimData")
-- local levelManager = require("scripts.levelManager")
-- local levels = levelManager.levels

-- local levels = 20
local buttonManager =      require("scripts.buttonManager")
local btnMngr = nil
local sceneGroup

	local buttons = {}
	local commands = {}

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

		if ( event.keyName == "left" ) then
			btnMngr:getPrevButton()
		elseif event.keyName == "right" then
			btnMngr:getNextButton()
		elseif ( event.keyName == "up" ) then
			btnMngr:getButtonAtIndex(btnMngr.currentButton.lvl-5)
		elseif ( event.keyName == "down" ) then
			btnMngr:getButtonAtIndex(btnMngr.currentButton.lvl+5)
		elseif ( event.keyName == "enter" ) then
			btnMngr:pressButton()
		elseif event.keyName == "escape" or event.keyName == "deleteBack" then

				composer.gotoScene( "menu" ,changeSceneOptions )
		end


end

-- create()
local function loadLevelEventListener(event)
		currentLevel = event.target.lvl
		if currentLevel >lvlCount then currentLevel = lvlCount end
		composer.gotoScene( "game"  ,changeSceneOptions)
end

local function loadLevel(lvl)
	currentLevel=lvl
	if currentLevel >lvlCount then currentLevel = lvlCount end
	composer.gotoScene( "game"  ,changeSceneOptions)
end

local function createButtons(parent)
	local rowLength = 7
	for k,v in pairs(buttons) do -- del btn
        v:removeSelf()
    end

	buttons = {}
	commands = {}

	-- for lvl = 1,levels,1 do
	for lvl,lvlData in pairs(levels) do
		local isComplete = saveManager:isLevelCompleted( lvlData.name )
		print ("LVL")
		print (isComplete)
		print ("")

		local texturePath = "textures/lvlSelectBtn.png"
		if isComplete then 
			texturePath = "textures/lvlSelectBtnComplete.png"
		end
		print (sceneGroup)
		print (texturePath)
		local lvlLoadButton = display.newImageRect( sceneGroup, texturePath, 40,40 )
		local offset = 250

		lvlLoadButton.x = display.contentCenterX + offset* ( (lvl-1)%rowLength-rowLength/2+0.5)
		lvlLoadButton.y = display.contentCenterY + offset* (math.floor ((lvl-1)/rowLength-2)+1)
		lvlLoadButton.xScale = scale
		lvlLoadButton.yScale = scale


		local textOptions = {
			parent = sceneGroup,
			text = lvl,
			x = lvlLoadButton.x, 
			y = lvlLoadButton.y, 
			font = native.systemFont, 
			fontSize = 20*scale,
			-- width = 1200,
			-- height = 150,
			align = "center"
		}

		local lvlText = 			display.newText( textOptions )
		lvlText:setFillColor( 0.2,0.9,1 )
		if not isComplete then
			lvlText:setFillColor( 0.05,0.05,0.05 )
		end


		-- local lvlText = display.newText( sceneGroup, lvl , lvlLoadButton.x, lvlLoadButton.y, native.systemFont, 20*scale ) ---display.contentCenterX/2
		
		--lvlText.x, lvlText.y = lvlLoadButton.x, lvlLoadButton.y

		local btn = lvlText
		btn.lvl = lvl
		-- lvlLoadButton:addEventListener( "tap", loadLevelEventListener )
		btn.command = loadLevel
		btn.arguments = lvl
		table.insert(buttons,btn)
		--table.insert(commands,loadLevel)

	end

	btnMngr = buttonManager:create(buttons,commands)
end




function scene:create( event )
	sceneGroup = self.view
	local background = display.newSprite(sceneGroup, anim.imageSheetLevelSelectBackground, anim.sequences_lvlSelectBackground)
	
	-- local background = display.newImageRect( sceneGroup, "textures/lvlSelectBackground.png", 140,60 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	background.xScale = display.contentHeight/70
	background.yScale = display.contentHeight/70

	-- local lvlLoadButton = display.newImageRect( sceneGroup, "textures/lvlSelectBackground.png", 40,40 )
	createButtons(sceneGroup)
end


function scene:show( event )
	-- local sceneGroup = self.view
		Runtime:removeEventListener( "key", onKeyEvent )
			Runtime:addEventListener( "key", onKeyEvent )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		createButtons(sceneGroup)

		btnMngr.enableInput = true
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

		-- self:destroy(event)
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
