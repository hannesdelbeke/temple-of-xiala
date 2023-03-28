
-- make upscaling pixel perfect
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )
native.systemFont = "uni05_53.ttf"

scale = 4
textSize = 30
-- anim =      require("scripts.AnimData")
-- json =      require( "json" )
-- widget =    require( "widget" )
--local composer =  require( "composer" )

composer = require( "composer" )

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

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




-- Go to the menu screen
composer.gotoScene( "menu" )
