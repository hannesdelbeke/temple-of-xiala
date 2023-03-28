
-- make upscaling pixel perfect
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )


local composer = require( "composer" )

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- Seed the random number generator
--math.randomseed( os.time() )

-- Go to the menu screen
composer.gotoScene( "menu" )
