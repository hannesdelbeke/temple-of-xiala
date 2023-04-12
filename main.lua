

-- make upscaling pixel perfect
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )
native.systemFont = "uni05_53.ttf"


-- currentScene = "Menu"

changeSceneOptions =
{
    effect = "fade",
    time = 200,
}


-- general classes shared trough scripts
steamworks = require( "plugin.steamworks" )
composer = require( "composer" )
audioManager = require( "scripts.audioManager" )
levelManager = require("scripts.levelManager")

localisationManager = require("scripts.localisationManager")
localisationManager:setLanguage("dutch")

saveManager = require("scripts.saveManager")

levels = levelManager.levels

scale = 4
textSize = 30

print("level count")

lvlCount = 0
for k,v in pairs(levels) do
	lvlCount = lvlCount+1
end

-- lvlCount = 20


audio.play( audioManager.music01, {loops = -1} )

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )




-- Go to the menu screen
composer.gotoScene( "menu" )




-- anim =      require("scripts.AnimData")
-- json =      require( "json" )
-- widget =    require( "widget" )
--local composer =  require( "composer" )

-- Seed the random number generator
--math.randomseed( os.time() )

-- mousecursor = require('plugin.mousecursor')
--
--   local cursors = {}
--
--   if not cursors.image then
--   			cursors.image = mousecursor.newCursor{
--   				filename = 'cursor.png',
--   				x = 32,	y = 32
--   			}
--   		end
--   		cursors.image:show()
