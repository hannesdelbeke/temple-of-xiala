
local M = {} --publicClass

------------------------------------------------------------------------------
-- tiles
------------------------------------------------------------------------------
local options =
{
    width = 20,
    height = 20,
    numFrames = 48,
    border = 0
    --optional parameters; used for scaled content support
    -- sheetContentWidth = 169,  -- width of original 1x size of entire sheet
    -- sheetContentHeight = 43   -- height of original 1x size of entire sheet
}
 M.imageSheetTiles = graphics.newImageSheet( "textures/tileSheet.png", options )

------------------------------------------------------------------------------
-- spritesheet animations
------------------------------------------------------------------------------

local options =
{
    --required parameters
    width = 20,
    height = 20,
    numFrames = 24,
    border = 0
    --optional parameters; used for scaled content support
    -- sheetContentWidth = 169,  -- width of original 1x size of entire sheet
    -- sheetContentHeight = 43   -- height of original 1x size of entire sheet
}

M.sequences_spritesheet = {
    -- consecutive frames sequence
    {
        name = "idleGem",
        start = 1,
        count = 4,
        time = 400,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "idleGem2",
        start = 1,
        count = 4,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "idleDoor",
        start = 5,
        count = 4,
        time = 400,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "destroyDoor",
        start = 8,
        count = 5,
        time = 400,
        loopCount = 1,
        loopDirection = "forward"
    },
    {
        name = "top_idleSlot",
        start = 13,
        count = 4,
        time = 400,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "bot_idleSlot",
        start = 17,
        count = 4,
        time = 400,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "teleport",
        start = 21,
        count = 4,
        time = 400,
        loopCount = 0,
        loopDirection = "forward"
    }
}

M.imageSheetSprites = graphics.newImageSheet( "textures/spritesheet.png", options )

------------------------------------------------------------------------------
-- gem
------------------------------------------------------------------------------
local options =
{
    width = 16,
    height = 16,
    numFrames = 10,
    border = 0
}

M.sequences_gem = {
    -- consecutive frames sequence
    {
        name = "disable",
        start = 1,
        count = 5,
        time = 300,
        loopCount = 1,
        loopDirection = "forward"
    },
    {
        name = "enable",
        start = 1,
        count = 5,
        time = 500,
        loopCount = 1,
        loopDirection = "bounce"
    },
    {
        name = "noMoves",
        start = 5,
        count = 2,
        time = 500,
        loopCount = 1,
        loopDirection = "bounce"
    }
}

M.imageSheetGem = graphics.newImageSheet( "textures/gem.png", options )

------------------------------------------------------------------------------
-- player
------------------------------------------------------------------------------

local options =
{
    width = 16,
    height = 16,
    numFrames = 16,
    border = 0
}

M.sequences_player = {
    -- consecutive frames sequence
    {
        name = "idle",
        start = 1,
        count = 2,
        time = 300,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "delight", -- blue light dissapears
        start = 3,
        count = 3,
        time = 300,
        loopCount = 1,
        loopDirection = "forward"
    },
    {
        name = "walk",
        start = 6,
        count = 3,
        time = 300,
        loopCount = 0,
        loopDirection = "bounce"
    },
    {
        name = "enterDark",
        start = 9,
        count = 4, -- extra buffer frame, seems last frame gets skipped if trigger on ended
        time = 300,
        loopCount = 1,
        loopDirection = "forward"
    },
    {
        name = "darkWalk",
        start = 12,
        count = 3,
        time = 300,
        loopCount = 0,
        loopDirection = "bounce"
    }
}

M.imageSheetPlayer = graphics.newImageSheet( "textures/dude.png", options )

------------------------------------------------------------------------------
--menu background
------------------------------------------------------------------------------
local options =
{
    width = 140,
    height = 60,
    numFrames = 4,
    border = 0
}

M.sequences_temple = {
    -- consecutive frames sequence
    {
        name = "temple",
        start = 1,
        count = 4,
        time = 600,
        loopCount = 0,
        loopDirection = "forward"
    }
}

M.imageSheetTemple = graphics.newImageSheet( "textures/temple.png", options )

------------------------------------------------------------------------------
--lvlselect background
------------------------------------------------------------------------------
local options =
{
    width = 140,
    height = 60,
    numFrames = 1,
    border = 0
}

M.sequences_lvlSelectBackground = {
    -- consecutive frames sequence
    {
        name = "temple",
        start = 1,
        count = 1,
        time = 600,
        loopCount = 0,
        loopDirection = "forward"
    }
}

M.imageSheetLevelSelectBackground = graphics.newImageSheet( "textures/lvlSelectBackground.png", options )

------------------------------------------------------------------------------
--retry button
------------------------------------------------------------------------------
local options =
{
    width = 40,
    height = 20,
    numFrames = 12,
    border = 0
}

M.sequences_retry = {
    -- consecutive frames sequence
    {
        name = "click",
        start = 1,
        count = 3,
        time = 500,
        loopCount = 1,
        loopDirection = "forward"
    },
    {
        name = "enabled",
        start = 2,
        count = 1,
        time = 500,
        loopCount = 1,
        loopDirection = "forward"
    },
    {
        name = "charged",
        start = 9,
        count = 4,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    }
}


M.imageSheetRetry = graphics.newImageSheet( "textures/retry.png", options )

------------------------------------------------------------------------------

return M
