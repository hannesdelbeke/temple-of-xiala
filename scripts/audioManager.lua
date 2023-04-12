
local M = {} --publicClass

-- ======================== public vars ================================

--M.music01 = audio.loadStream( "sound/music/music01.wav" )
M.music01 =       audio.loadStream( "sound/music/ambience.wav" )

M.changeGravity = audio.loadSound( "sound/sfx/changeGravity.wav" )

M.clickButton =   audio.loadSound( "sound/sfx/button_click.wav" )
M.selectButton =  audio.loadSound( "sound/sfx/button_select.wav" )

M.loadNextLevel = audio.loadSound( "sound/sfx/loadNextLevel.wav" )
M.levelComplete = audio.loadSound( "sound/sfx/levelComplete.wav" )

M.moveCube =      audio.loadSound( "sound/sfx/moveCube.mp3" )
M.stopCube =      audio.loadSound( "sound/sfx/stopCube.wav" )

M.openMenu =      audio.loadSound( "sound/sfx/menu_close.wav" )
M.closeMenu =     audio.loadSound( "sound/sfx/menu_open.wav" )

M.undo =          audio.loadSound( "sound/sfx/undo.wav" )

M.outOfMoves =    audio.loadSound( "sound/sfx/outOfMoves.wav" )


-- ======================== private vars ================================
-- total of 32 channels available

local freeChannel = 1
local freeMusicChannel = 1
local musicChannelAmount = 3

local freeSFXChannel = 1
local SFXChannelAmount = 20

local soundTypes = {}
soundTypes.SFX = "SFX"
soundTypes.music = "music"

-- ======================== private functions ================================

local function getAvailableChannel(soundType)
  if soundType == soundTypes.SFX then
    freeSFXChannel = freeSFXChannel + 1
    if freeSFXChannel + musicChannelAmount > SFXChannelAmount then freeSFXChannel = musicChannelAmount + 1 end
    return freeSFXChannel
  elseif soundType == soundTypes.music then
    freeMusicChannel = freeMusicChannel + 1
    if freeMusicChannel > musicChannelAmount then freeMusicChannel = 1 end
    return freeMusicChannel
  end
end


local function playMusic(source)
  freeChannel = getAvailableChannel(soundTypes.music)
  audio.play( source, {channel=freeChannel} )
end


local function playSFX(source, pitchMin, pitchMax)
  if not pitchMin then pitchMin = 1.0 end
  if not pitchMax then pitchMax = 2.0 end
  pitchMax = pitchMax-pitchMin
  playbackPitch = pitchMin + math.random()*pitchMax
  freeChannel = getAvailableChannel(soundTypes.SFX)
  audio.play( source, {channel=freeChannel} )
  local sourceChannel = audio.getSourceFromChannel(freeChannel)
  al.Source(sourceChannel, al.PITCH, playbackPitch);
end


-- ======================== public functions ================================
function M:playUndo()
  playSFX( M.undo, 1.4, 1.5)
end


function M:playClickButton()
  playSFX( M.clickButton, 1, 1)
end


function M:playSelectButton()
  playSFX( M.selectButton, 1, 1)
end


function M:playStopCube()
  playSFX( M.stopCube, 1, 2)
end


function M:playChangeGravity()
  playSFX( M.changeGravity, 1, 1.5)
end


function M:playLevelComplete()
  playSFX( M.levelComplete, 1.3, 1.4)
end


function M:playLoadNextLevel()
  playSFX( M.loadNextLevel, 1, 1)
end

function M:playOutOfMoves()
  playSFX( M.outOfMoves, 1, 1)
end


return M
