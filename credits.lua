
--local composer = require( "composer" )


local scene = composer.newScene()

local creditText = {
"Temple of Xiala",
"",
"",
"-",
"",
"Art and Code",
"Hannes Delbeke",
"",
"Music and Sound",
"Csaba Gyorfi",
"",
"-",
"",
"With the support of the following backers:",
"",
"Leveldesign backers",
--custom lvl 
"Berard",
"Mitchell McLeod",

"",
-- "-",
-- "",

"Beta Testers",

-- }
-- local creditText2 = {

-- early bird betatester
"Icarus",--"Sebastian Sole", 
"Yuriy Bokovoy",--"Yurapsih" ,
"Usagi Ito" ,
"JonnyJaap" ,
"Vesko Gavrilov" ,
"Kai & Kira",--"Kris Verbeeck" ,
"Bavo Callens" ,
"Sander Decleer" ,
"Nathan Cosmos" ,
"Chris Luck", --topher
"Filip Deroo",
"Tashkiira",
"Pyrouette",--"Michael",
"Muddy ",
"Joeri -SabreWing- Roels",--"Joeri Roels",
"Milan Van Damme",
"GameShoe",--"Edd",
"ko-ko",
"Stefan Herijgens",
"Paul Pasturel",
"Myles Hennessy",--"Myles",
"Brett -Magnetic- Hibl",--"TheMagneticOne",
"Thomas Corremans",

-- beta tester x 4
"Matomite",
"Daniel Matson",
"Andy Griffiths",
"Marin Brouwers , Fries Boury , Mike Ptacek , Glowfish Interactive",

-- beta testers
"Tomas -zelgaris- Zahradnicek",
"Alan Morgan",
"Jendrik -paranoidSpectre- Witt",
"Regis Le Roy",
"Jeff Maksuta (SuperJeffoMan)",
"Guest 173805860",
"Taylor C. Berrier a.k.a. thegalaxy89",

--}
-- local creditText3 = {

"",
-- "-",
-- "",

"Backers",

-- the game
"Haevermaet Anthony",
"Dragoun 900",--"justajester",
"Hannes Påfvelsson",
"Youngsage3",--"Peter Krist",
"Chris Skuller",
"Timothy -Luka- McCarthy",
"ChaoticDragon",--"Luke Christensen",
"Paul Kominers",
"Max Juchheim",
"Elliot R", --eyes Jr",
"Pyerre",--"Lanneau",
"Reb",
"Jeffrey Gray",
"Kazunori Aoki",--"No.A",
"solskido",--"Max",
"Caleb Kinkaid",
"Tim Hickey",
"Christopher Frank",
"Kide",-- / Carita",
"Orrin (The_Void)",
"targaff",
"Stephen Lestik",
"Namu-Nelo",--"C_chrishggf",
"CallMeMrHam", --"Mike",
-- NONAME "Julian Preußner",
"Kristin Morin", --Anderson
"Siân Lloyd-Wiggins",
"Sakurai Shugi",
"koniczynax",
"Jessica Klapperich",
"Jahmel Gordon",
"Jessica Harris",

-- supporter
"Timmy -FishOfPain- Petersson", --"Timmy Petersson",
"Randy Barreno", --"Hungry Pixel",

-- aditional
"Billy Lundevall",


"",
"-",
"",
"Thanks for playing and supporting this game!"

}


-------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-------------------------------------------------------------------------------




-------------------------------------------------------------------------------
-- Scene event functions
-------------------------------------------------------------------------------
--local creditTextObj
-- create()

local creditTransition
local textCredits

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	textHeight = 0
	creditTextCombined = ""
	for k,v in pairs(creditText) do
		creditTextCombined = creditTextCombined.. v .. "\n"
		textHeight = textHeight+65
	end

	-- for k,v in pairs(creditText2) do
	-- 	print(k)
	-- 	creditTextCombined = creditTextCombined.. v
	-- 	local index = tonumber(k)
	-- 	if ( index%2) and creditText2[index+1]~=nil then
	-- 		creditTextCombined = creditTextCombined.. "          " .. creditText2[index+1] .. "\n"
	-- 	else
	-- 		creditTextCombined = creditTextCombined.. "\n"
	-- 	end
	-- 	textHeight = textHeight+65
	-- end




	local options =
	{
			parent = sceneGroup ,
	    text =creditTextCombined,
	    x = display.contentCenterX,
	    y = 300,
	   -- width = 128,
	    font = native.systemFont,
	    fontSize = 44,
	    align = "center"  -- Alignment parameter
	}

	--display.newText( sceneGroup, creditTextCombined, display.contentCenterX, 300, native.systemFont, 44 ,align=center)
	textCredits = display.newText(options)
	textCredits.anchorX = 0.5
	textCredits.anchorY = 0
	textCredits.y = display.contentHeight
	textHeight = textHeight+textCredits.y
	--creditTransition = transition.to( textCredits, { iterations=-1, time=40000,  x=textCredits.x, y=textCredits.y-textHeight } ) --alpha=0,, onComplete=listener1

end

local function onKeyEvent(event)
	if (event.phase=="up") then return false
	end

	--if event.keyName == "escape" or event.keyName == "deleteBack" then
	composer.gotoScene( "menu" ,changeSceneOptions )
--	end

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
		transition.cancel(textCredits)
		textCredits.y = display.contentHeight
		creditTransition = transition.to( textCredits, { iterations=-1, time=80000,  x=textCredits.x, y=textCredits.y-textHeight } ) --alpha=0,, onComplete=listener1


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


-------------------------------------------------------------------------------
-- Scene event function listeners
-------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-------------------------------------------------------------------------------

return scene
