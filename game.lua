-- by hannes delbeke october 2017
-- GAME LOGIC

-- tweakable variables

-- local levelManager = require("scripts.levelManager")
-- local levels = levelManager.levels

-- local levels = saveManager.isLevelUnlocked(name)

--levels[lvl].name
local levelScale  = 1 -- TODO set this per level for bigger levels

local index_botSlot = 7
local indexGem = 8
local indexDoor = 18
local index_topSlot = 19
local indexTeleport = 32
local indexAntiGravityGem = 33
local indexSlideMid = 38
local indexSlideEnd = 39
local indexSlidingBoulder = 40
local indexSlideCorner = 41
local indexSlideTjunction = 42


local tileSize = 40*scale  * levelScale-- this scales the 20 pixel tiles up with x2
local offsetX --=  -display.contentCenterX/2
local offsetY = 0.5*tileSize

local debugEnabled = false

-------------------------------------------------------------------
-- logic variables
local currentLevelLoaded = 0
local menuOverlayVisible = false
local e_direction = {
  up = "up",
  down = "down",
  left = "left",
  right = "right"
}
local directionGravity = e_direction.down
local directionGravityLastTurn = e_direction.down
local levelCompleted = false
local turnsLeft = 6
local turnsTotal = 6
local turnsMax = 10

local deltatime = 5
local globaltimer = 0

local undoQueu = 0
local undoInProgress = false

local rows = 11
local cols = 7
local startTile
local endTile

local player
local debugInfo = {}

local tick
local objectsAreMoving = false
local gfxAreMoving = false

local playerEnterDarkTimer = false

local objectiveTable = {}
local objectsTable = {}
local objectsPosBackupTable = {}
local tileTable = {}
local doorTable = {}
local slideTable = {}
local levelGraphicsTable = {}

local UIgems = {}

local anim =      require("scripts.AnimData")
local json =      require( "json" )
local widget =    require( "widget" )
local composer =  require( "composer" )
local scene = composer.newScene()
scene.name = "Game"

local background = display.newGroup()
local midground = display.newGroup()  --this will overlay 'farBackground'
local foreground = display.newGroup()
local UILayer = display.newGroup()

-- local debugcirclecenter = display.newCircle( 0, 0, 100 )
-- ==================================================================
-- functions
-- ==================================================================

local function printDebug( msg )
  -- custom print to easy cleanup debugcode - simply search for this name
  print(msg)
end

local function getObj(col,row)
  return tileTable[col][row]
end


function len(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


local function getColRowFromDirectionOffset(direction,col,row,offset)
  if direction==e_direction.up then
    if row-offset>0 then
       return col,row-offset
    end
  elseif  direction==e_direction.down then
    if row+offset<=rows then
       return col,row+offset
    end
  elseif  direction==e_direction.left then
    if col-offset>0 then
       return col-offset,row
    end
  elseif  direction==e_direction.right then
    if col+offset<=cols then
       return col+offset,row
    end
  end
  return false
end

local function objectiveIsFilled()
  -- get objectives
  for k,obj in pairs(objectiveTable) do
  -- check if they have a obj in them
    local col = getCol(obj)
    local row = getRow(obj)
    if not hasObj(col,row) then
      return false
    end
  end
  return true
end

function hasObj(col,row)
   return getObj(col,row)~=0
end


local function botRowIsFree()
  -- check if space between 2 doors is free
    for col=getCol(doorTable[1])+1, getCol(doorTable[2])-1 ,1 do
      if getObj(col,rows - 1)~=0 then
        return false
      end
    end
    return true
end


local function checkWinLoss()
  if not botRowIsFree() then
    return false
  end

  if objectiveIsFilled() and gfxAreMoving==false then
    print("WIN")

    if currentLevel == 1 then
      steamworks.setAchievementUnlocked( "ACHIEV_COMPLETE_1" )
    end


    saveManager:saveLevelComplete( levels[currentLevel].name )

    -- TODO play animation, doors disapear
    -- wait
    if levelCompleted==false then
      loadLevelAnimation()
      levelCompleted=true
      updateUndoButton()
    -- else
    --   updateUndoButton()
    end
  end
end


function getRow(obj)
  if obj == 0 or obj==nil  then return false end
--this returns the wrong value - changes when offset x changeSceneOptions--TODO fix it
  local x = (obj.y-offsetY)/tileSize
  return  math.floor(x + 0.5)
end


function getCol(obj)
  if obj == 0 or obj==nil then return false end
--this returns the wrong value - changes when offset x changeSceneOptions--TODO fix it
  local x = (obj.x-offsetX)/tileSize
  return  math.floor(x + 0.5)
end


local function moveGfxToObj(obj)
  gfx = obj.gfx
  gfx.x = obj.x
  gfx.y = obj.y
end


local function simpleMoveObject(col,row,obj)
  obj.x = col*tileSize+offsetX
  obj.y = row*tileSize+offsetY
  obj.hasMoved = true
  tileTable[col][row] = obj
  return obj
end


function canObjMove(obj)
  if obj ~= 0 and obj ~= nil then
    return obj.canMove
  end
  return false
end

local function moveObject(col,row,obj)
  -- BUG sets old pos to 0, 
  --if old pos is the target of another obj, then it sets it to 0 and removes the obj from tiletable
  -- happens when you undo and 1 obj ends up in the old pos of another, breaking it
  -- see lvl 8 undo bug

  if obj.hasMoved then
    return false
  end

  originalCol = getCol(obj)
  originalRow = getRow(obj)
  obj.hasMoved = true
  if originalCol>=0 and originalRow>=0 and obj==tileTable[originalCol][originalRow] then -- check if this is still obj in the table to prevent erasing other objs that were inserted during undo loop
    tileTable[originalCol][originalRow] = 0
  end
	obj.x = col*tileSize+offsetX
	obj.y = row*tileSize+offsetY
--todo move the obj out of its current place in the table
  tileTable[col][row] = obj
  print ("set col row in tiletable: "..col..row)

  for k,v in pairs(tileTable) do
    for kk,vv in pairs(v) do
      obj = tileTable[k][kk]
      ob = canObjMove(obj)
    end
  end
	return obj
end


local function moveObjectRecursive(direction,obj)
  --move recursive
  local col = getCol(obj)
  local row = getRow(obj)
  local c,r = getColRowFromDirectionOffset(direction,col,row,1)
  if c == false then
    return false
  end
  local nextObj = getObj(c,r)
  if nextObj==0 then
    moveObject(c,r,obj)
    return true


  -- CHECK IF NEXT OBJ IS A teleporter . but can also contain a cube - multiple things in 1 slot
  -- elseif nextObj==teleport
  --get other teleporter and move it to there, then continue moving
  elseif canObjMove(nextObj) then
    if moveObjectRecursive(direction,nextObj) then
      moveObject(c,r,obj)
    end
  end
end


local function moveObjectRelative(direction,obj)
    tileTable[getCol(obj)][getRow(obj)] = 0
  --  local col = getCol(obj)
  --  local row = getRow(obj)
  --  getColRowFromDirectionOffset(col,row)
  if direction==e_direction.up then
    obj.y = obj.y -tileSize
  end

  if direction==e_direction.down then
    obj.y = obj.y +tileSize
  end

  if direction==e_direction.left then
    obj.x = obj.x -tileSize
  end

  if direction==e_direction.right then
    obj.x = obj.x +tileSize
  end

  tileTable[getCol(obj)][getRow(obj)] = obj
  return obj
end


local function createRock(row,col)
    -- todo replace image rect with non image rect
	-- local collider = display.newImageRect(background,"textures/platform.png", tileSize, tileSize)
  local collider = display.newRect(background,0,0, 1, 1 )
  collider.isVisible = false

  -- issue is that we do getco and getrow when we just created it therefor x and y is always 0, no matter the offset
  simpleMoveObject(col,row,collider)
	return collider
end

local function resetPlayer()
  if player then
    transition.cancel(player) -- reset paused win transition to prevent cheating with lvlselect
    player.isVisible = true
    player.x = doorTable[1].x-5*scale*levelScale-- - 6*scale + offsetX
    player.y = doorTable[1].y+4*scale*levelScale--tileSize*4 +4*scale + offsetY -- 16px in mid of 20px. (20-16)/2 , then *2 because all tiles are *2. =4 pixels ofset
    player:setSequence("idle" )
    player:play()
    transition.pause(player)

    player.xScale = 2*scale*levelScale
    player.yScale = 2*scale*levelScale
  end

end

local function createPlayer()--col,row)
	player = display.newSprite(foreground, anim.imageSheetPlayer,anim.sequences_player)

  resetPlayer()

  -- player:play()
end


local function BoulderGfxArrived()

  checkMovingGfx()
--  if objectsAreMoving == false then
  if not undoInProgress then
    audioManager.playStopCube()
  end

    if not gfxAreMoving then
      if undoQueu > 0 then
        undoQueu = undoQueu - 1

        if undoQueu == 0 then
          undoInProgress = false
        else
          undoInProgress = true
          executeUndo()
        end

      end
    end
    checkWinLoss()
end

local function UpdateBoulderGfx(boulder,speed)
  if speed == nil then
    speed = 1.5
  end

  boulderGfx = boulder.gfx
  if boulder.x~=boulderGfx.x or boulder.y~=boulderGfx.y then
    distance = math.sqrt((boulderGfx.x-boulder.x)^2 + (boulderGfx.y-boulder.y)^2)
    transition.cancel(boulderGfx)
    boulderGfx.transition = transition.to (
      boulderGfx,
      {
        time = distance/speed,
        x = boulder.x,
        y = boulder.y,
        onComplete = BoulderGfxArrived
      --  transition=easing.inQuad --transition doesnt work properly in sync with other cubes
      }
    )
  end
end


local function setScaleRotatePosForTile(obj, vv)
      obj.xScale = 2*scale*levelScale
      obj.yScale = 2*scale*levelScale
      obj.x, obj.y = vv["x"]*tileSize+offsetX, vv["y"]*tileSize+offsetY
      obj.rotation = vv["rot"]*90
      if vv["flipX"] then
        obj.xScale = -2*scale*levelScale
      end
      if vv["flipY"] then
        obj.yScale = -2*scale*levelScale
      end
      return obj
end

local function createTeleport(vv)
    local obj = display.newSprite(foreground, anim.imageSheetSprites, anim.sequences_spritesheet )
    setScaleRotatePosForTile(obj, vv)
    obj:setSequence( "teleport" )
    obj:play()
  end


local function createDoor(vv)
  local obj = display.newSprite(background, anim.imageSheetSprites, anim.sequences_spritesheet )
  setScaleRotatePosForTile(obj, vv)
  obj:setSequence( "idleDoor" )
  obj:play()
  table.insert(doorTable, obj )
end


local function createBoulder(vv, antiGravity, isSlidingCube)
  local col = vv["x"]
  local row = vv["y"]
-- create logic - since we write it based on position for now we split gfx and gameplay
  local boulder = display.newRect(background,0,0, 1, 1 )
  boulder.isVisible = false
	-- boulder.isFixedRotation = true
  boulder.canMove = true
  boulder.isSlidingCube = isSlidingCube
  boulder.hasMoved = false
  simpleMoveObject(col,row,boulder)

  local boulderGfx
  -- -- create GFX
  if isSlidingCube then
    boulderGfx = display.newImageRect(background, anim.imageSheetTiles, indexSlidingBoulder+1, tileSize, tileSize )
  else
    boulderGfx = display.newSprite(background, anim.imageSheetSprites, anim.sequences_spritesheet )
    boulderGfx:play()
      boulderGfx.xScale = 2*scale*levelScale
      boulderGfx.yScale = 2*scale*levelScale
  end
  -- boulderGfx = display.newSprite(background, anim.imageSheetSprites, anim.sequences_spritesheet )

  if antiGravity then
    boulder.antiGravity = true
    boulderGfx:setFillColor( 0.2,1,0.2 )
  end


  boulder.gfx = boulderGfx
  boulderGfx.x = boulder.x
  boulderGfx.y = boulder.y
	-- boulderGfx.isFixedRotation = true
  boulderGfx.canMove = true
  boulderGfx.hasMoved = false
    table.insert(levelGraphicsTable,boulderGfx )
  -- randomise incase of multiple boulders
  -- if math.random(1, 2 ) == 2 then
  --   boulderGfx:setSequence("idleGem2" )
  -- end

	table.insert(objectsTable, boulder )

	return boulder
end


-- local function createSlidingBoulder(vv)
--     local obj = display.newSprite(foreground, anim.imageSheetSprites, anim.sequences_spritesheet )
--     setScaleRotatePosForTile(obj, vv)
--     obj:setSequence( "idleGem" )
--     obj:play()
--     table.insert(objectsTable, obj )
-- end


function getOppositeDirection(direction)
  if direction == e_direction.up then
    return e_direction.down
  elseif direction == e_direction.down then
    return e_direction.up
  elseif direction == e_direction.right then
    return e_direction.left
  elseif direction == e_direction.left then
    return e_direction.right
  end
end


local function checkIfSlideSlot(col,row)
  for k,v in pairs(slideTable) do
    if getCol(v)==col and getRow(v)==row then
      return true
    end
  end
  return false
end


local function checkSlotIsFree(isSlide,col,row)
  -- check if in bounds
  if not (row<=rows and row>0 and col>0 and col<=cols) then
    return false
  end

  -- check if nothing is in the way
  if tileTable[col][row]~=0 then
    return false
  end


  if not isSlide then
    return true
  else
    return checkIfSlideSlot(col,row)
  end
end


local function getFreeSlotDirection(direction,col,row, isSlide)
  -- check if the slot next to it in direction is free

  if direction==e_direction.up then
    row = row-1
    -- if row>0 and tileTable[col][row]==0 then
    --    return true
    -- end
    return checkSlotIsFree(isSlide,col,row)
  elseif  direction==e_direction.down then
    row = row+1
    -- if row<=rows and tileTable[col][row]==0 then
    --    return true
    -- end
    return checkSlotIsFree(isSlide,col,row)
  elseif  direction==e_direction.left then
    col = col-1
    -- if col>0 and tileTable[col][row]==0 then
    --    return true
    -- end
    return checkSlotIsFree(isSlide,col,row)
  elseif  direction==e_direction.right then
    col = col+1
    -- if col<=cols and tileTable[col][row]==0 then
    --    return true
    -- end
    return checkSlotIsFree(isSlide,col,row)
  end
   return false
end

local function getFreeSlotDirectionObj(direction,obj)
  return getFreeSlotDirection(direction,getCol(obj),getRow(obj),isSlidingCubeObj(obj))
end

local function getFreeSlotRecursive(direction,col,row)
  local  c, r = col,row
  if direction==e_direction.up then
    if row-1>0 and tileTable[col][row-1]==0 then
       c, r = getFreeSlotRecursive(direction,col,row-1)
    end
  elseif  direction==e_direction.down then
    if row+1<=rows and tileTable[col][row+1]==0 then
       c, r = getFreeSlotRecursive(direction,col,row+1)
    end
  elseif  direction==e_direction.left then
    if col-1>0 and tileTable[col-1][row]==0 then
       c, r = getFreeSlotRecursive(direction,col-1,row)
    end
  elseif  direction==e_direction.right then
    if col+1<=cols and tileTable[col+1][row]==0 then
       c, r = getFreeSlotRecursive(direction,col+1,row)
    end
  end
  return c, r
end

function isSlidingCubeObj(obj)
  if obj~= 0 and obj.isSlidingCube~=nil then
    return obj.isSlidingCube
  else
    return false
  end
end

local function willMoveNextFreeSlot(direction,col,row,isSlidingCube)
  -- instead of checking if the slot is available now, check if it will be available next turn
  -- this ignores moveable objects and  sees if they will all shift as well (therefor freeing up the slot its checking)

  for i=1,100  do
    -- loop checks untill it finds a free slot, which means all cubes can be shifted

    -- if next slot is out ofrange, we reached the end
    if getColRowFromDirectionOffset(direction,col,row,1)==false then return false end

    local obj = getObj(col,row)

    -- if next slot can not move in direction, stop loop
    if obj ~=0 and canObjMove(obj) and not getFreeSlotDirectionObj(direction,obj) then
      print(false)
      return false
    end

    --   -- if antigrav cube, check if we are  going to move in that direction
    -- --directionGravity
    -- TODO
    --
    --   return true
    -- end


    if obj ~=0 and getFreeSlotDirectionObj(direction,obj) then
      return true
    end

      -- if next slot has a moveable guy continue while loop
    --elseif obj ~=0 and obj.canMove then

        --if next slot can not move
    if obj ~=0 and not canObjMove(obj) then
      return false
    end

    col,row = getColRowFromDirectionOffset(direction,col,row,1)
  end
  print("reached end, shouldnt happen")
end

--check which tiles are available to  move (have a free slot next to them), return them in a table
local function getMoveableObjects(direction,objects)
  local moveableObjTable = {}
  for k,obj in pairs(objects) do

    local dir = direction
    if obj.antiGravity then
      dir = getOppositeDirection(direction)
    end

    if canObjMove(obj) then
      if getFreeSlotDirectionObj(dir,obj) then
        table.insert(moveableObjTable, obj )
    --  elseif
      end
    end
  end
  return moveableObjTable
end

local function getAllMoveableObjects(direction)
  return getMoveableObjects(direction,objectsTable)
end



local function getCanMoveObjects()
  -- get objects that can move, but not they might not be able to atm because there is no free slot available
  local canMoveObjects = {}
  for k,obj in pairs(objectsTable) do
    if canObjMove(obj) then
      table.insert(canMoveObjects, obj )
    end
  end
  return canMoveObjects
end


local function moveMoveableObjects(direction)

    local objectsToMove = {} --store objs to move later to not cause table mess

    for k,obj in pairs( objectsTable) do
      if obj~= 0 and canObjMove(obj) and obj.hasMoved == false then
        -- move them all up untill there is no free slot

        --get the row and col for the obj we will move
        -- check if next slot is  free
        local col = getCol(obj)
        local row = getRow(obj)

        local dir = direction
        if obj.antiGravity then
          dir = getOppositeDirection(direction)
        end

        if willMoveNextFreeSlot(dir,col,row,isSlidingCubeObj(obj)) then

            table.insert(objectsToMove,obj )


        end
      end
    end

    if objectsPosBackupTable[turnsLeft+1] == nil then
      objectsPosBackupTable[turnsLeft+1] = {}
    end
    objectsPosBackupTable[turnsLeft+1].direction = directionGravityLastTurn

    for k,obj in pairs( objectsTable ) do
      if objectsPosBackupTable[turnsLeft+1][k] == nil then
        objectsPosBackupTable[turnsLeft+1][k] = {
          col=getCol(obj),
          row=getRow(obj)
        }
      end
    end
 
 --@BUG this doesnt run since objtomove is empty
    for k,obj in pairs( objectsToMove ) do
    --  objectsPosBackupTable[turnsLeft+1][k] = {
      --   col=getCol(obj),
      --   row=getRow(obj)
      -- }

      local dir = direction
      if obj.antiGravity then
        dir = getOppositeDirection(direction)
      end
      moveObjectRecursive(dir,obj)
      UpdateBoulderGfx(obj)
    end



    for k,v in pairs(objectsTable) do
     v.hasMoved = false
    end
end

local  function rotateGfxTowardsGravity(direction)
  -- rotate the boulder towards the direction its going
  for k,obj in pairs(objectsTable) do
    if obj.gfx ~= nil and not isSlidingCubeObj(obj) then
      local dir = direction

      if obj.antiGravity then
        dir = getOppositeDirection(direction)
      end


      local rotation = 0
      if dir==e_direction.up then
        rotation = 180
      elseif dir == e_direction.down then
        rotation = 0
      elseif dir == e_direction.left then
        rotation = 90
      elseif dir == e_direction.right then
        rotation = -90
      end
      obj.gfx.rotation = rotation
    end
  end
end

local function changeGravity(direction)
  print("change gravity ************")
  -- prevents bug where you press up and down at same time where it does changegravity while still moving
  checkMovingGfx()
  if gfxAreMoving then
    return false
  end


  if turnsLeft<=0 then
    audioManager.playOutOfMoves()
    gems_outOfMoves()
  end

  print("unpause tick")
  timer.resume(tick)
  if len(getAllMoveableObjects(direction)) == 0 or gfxAreMoving then
    print("nothing to move")
    return false
  end


	if (turnsLeft>0) then
    audioManager.playChangeGravity()
    directionGravityLastTurn = directionGravity
    directionGravity = direction

    objectsAreMoving = true
    gfxAreMoving = true

		turnsLeft = turnsLeft - 1

    -- rotate the boulder towards the direction its going
    rotateGfxTowardsGravity(direction)


  end

end

local function moveTEMPNAME()

      --  colTable[col] = obj
      --  rowTable[row] = obj

end

local function onKeyEvent( event )


	if (event.phase=="up") then return false
	end


    if not menuOverlayVisible then
      if event.keyName == "up" or event.keyName == "w"  then
    	   changeGravity( e_direction.up)
         return false
      elseif event.keyName == "down"  or event.keyName == "s" then
    	   changeGravity( e_direction.down)
         return false
      elseif event.keyName == "left" or event.keyName == "a"  then
    	   changeGravity( e_direction.left)
         return false
      elseif event.keyName == "right"  or event.keyName == "d" then
    	   changeGravity( e_direction.right)
      elseif event.keyName == "deleteBack" or event.keyName == "space"  then
    	   undo()
         return false

      -- elseif event.keyName == "space" then
    	--    transition.cancel()
      --    return false

      end
    end

    if ( event.keyName == "escape" ) then
      resumeGame()
      return false
    end

   -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
    if ( event.keyName == "back" ) then
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



function unloadLevel()

  for col=1,cols do
    for row=1,rows do
      local obj = tileTable[col][row]
      if obj ~= 0 then
          obj:removeSelf()
      end
    end
  end

  for k,v in pairs(levelGraphicsTable) do
    v:removeSelf()
  end

  for k,v in pairs(doorTable) do
    v:removeSelf()
  end

  -- for k,v in pairs(levelGraphicsTable) do
  --   v:removeSelf()
  -- end

  levelGraphicsTable = {}
  objectsTable = {}
  objectiveTable = {}
  tileTable = {}
  slideTable = {}
  doorTable = {}
end

function loadLevel(lvl)
  -- reset undo table
  objectsPosBackupTable = {}

  currentLevel = lvl
  currentLevelLoaded = lvl
  -- TODO
  -- load turnsLeft
  turnsLeft = levels[lvl].turns
  turnsTotal = turnsLeft
  -- load winning slots that need filling

  loadUIgems()

  if playerEnterDarkTimer then
    timer.cancel( playerEnterDarkTimer )
    playerEnterDarkTimer=false
  end

  if len(tileTable)>0 then
    print("unload level")
    unloadLevel()
  end

  local filename = system.pathForFile( levels[lvl].jsonPath )

  print (filename)
  local decoded, pos, msg = json.decodeFile( filename )
  if not decoded then
      print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
  else
      print( "File successfully decoded!" )
  end

  -- this is specific for this lvl
  rows = decoded["tileshigh"]-2
  cols = decoded["tileswide"]-2

  for col=1,cols do
    tileTable[col] ={}
    for row=1,rows do
      tileTable[col][row] = 0
    end
  end

  levelScale = 7/(rows+2)
  tileSize = 40*scale  * levelScale

  --center tiles
  offsetX = - (cols+1)*tileSize/2 + display.contentCenterX
  offsetY = 0.5*tileSize
  --TODO put this in a nice function

  display.setDefault( "background", 29/255/2, 26/255/2, 24/255/2 )

  -- draw pyxel json
  local layers = decoded["layers"]
  local layerCount = len(layers)

  -- pyxel exports highest layer on top, first.
  -- we need to reverse the order when drawing else front layer is hidden by backlayer
  local orderedLayers = {}
  for k,v in pairs(layers) do
    orderedLayers[v["number"]] = v
  end

  for i=layerCount-1,0,-1 do
    v = orderedLayers[i]
    if v["name"]=="midground" or v["name"]=="background" then

      for kk,vv in pairs(v["tiles"]) do
        local indexTile = vv["tile"]
        local obj
        if  indexTile==index_botSlot then
          obj = display.newSprite(background, anim.imageSheetSprites, anim.sequences_spritesheet )
          setScaleRotatePosForTile(obj, vv)
          obj:setSequence( "bot_idleSlot" )
          obj:play()

        elseif  indexTile==index_topSlot then
          obj = display.newSprite(background, anim.imageSheetSprites, anim.sequences_spritesheet )
          setScaleRotatePosForTile(obj, vv)
          obj:setSequence( "top_idleSlot" )
          obj:play()
          table.insert(objectiveTable,obj )


        --draw tile
        elseif indexTile~=-1 then
          obj = display.newImageRect(background, anim.imageSheetTiles, indexTile+1, tileSize, tileSize)

          if  indexTile==indexSlideMid or indexTile==indexSlideEnd or indexTile==indexSlideCorner or indexTile == indexSlideTjunction then
            table.insert(slideTable,obj )
          end

          obj.x, obj.y = vv["x"]*tileSize+offsetX, vv["y"]*tileSize+offsetY
          obj.rotation = vv["rot"]*90
          if vv["flipX"] then
            obj.xScale = -1
          end
          if vv["flipY"] then
            obj.yScale = -1
          end
        end

        -- create collider, add it to the table
        if indexTile~=-1 then
          table.insert(levelGraphicsTable,obj )
          if v["name"]=="midground" then
            -- its an immovable object
            createRock( vv["y"],vv["x"])
          end
        end
        --         "y": 5,
        --         "rot": 0,
        --         "tile": -1,
        --         "flipX": false,
        --         "index": 41,
        --         "x": 6
      end
    end
    if v["name"]=="moving" then

      local counter = 1
      for kk,vv in pairs(v["tiles"]) do
        local indexTile = vv["tile"]
        if indexTile==-1 then -- skip -1
        elseif indexTile==indexGem then
          obj = createBoulder(vv)
          obj.counter = counter
          counter = counter + 1
        elseif indexTile==indexAntiGravityGem then
          obj = createBoulder(vv, true)
          obj.counter = counter
          counter = counter + 1

        elseif indexTile==indexDoor then
          createDoor(vv)

        elseif indexTile==indexSlidingBoulder then
          obj = createBoulder(vv, false, true)
          obj.counter = counter
          counter = counter + 1
          -- createSlidingBoulder(vv)
          -- @TODO

        elseif indexTile == indexTeleport then
          createTeleport(vv)
          print("createTeleport")
        end
      end
    end
  end
  resetPlayer()
  levelCompleted=false

  debugUpdate()
  updateUndoButton()
end

local function startDarkWalk(event)
  if player.sequence == "enterDark" and event.phase == "ended" then
    player:setSequence("darkWalk" )
    player:play()
    player:removeEventListener( "sprite", startDarkWalk )
  end
end

local function checkPlayerAnim()
  --  if player.x >= (offsetX + tileSize*(cols+0.5)) and player.sequence == "walk" then
      player:setSequence("enterDark" )
      player:play()
      -- TODO clean up event listener
      player:addEventListener( "sprite", startDarkWalk )
 --   end
end

local function playerWalk()
  player:setSequence("walk" )
  player:play()
  transition.to (
    player,
    {
      --tag = "player",
      time = ( (doorTable[2].x-doorTable[1].x)/tileSize +1) * 400,
      x = doorTable[2].x+tileSize,--display.contentWidth+tileSize/2 + offsetX,
      y = player.y,
      onComplete = loadNextLevel
    }
  )
  playerEnterDarkTimer = timer.performWithDelay( ((doorTable[2].x-doorTable[1].x)/tileSize-0.5) * 400, checkPlayerAnim)
end

-- delay the walk anim
local function playerWalkStart(event)
  if event.phase == "ended" then
    timer.performWithDelay(200, playerWalk)
    door = doorTable[1]
    door:removeEventListener( "sprite", playerWalkStart )
  end
end

function loadLevelAnimation()
  local door
  for k,v in pairs(doorTable) do
    v:setSequence( "destroyDoor" )
    v:play()
  --  door = v
  end

  audioManager.playLevelComplete()

  door = doorTable[1]
  player:setSequence("delight" )
  player:play()
  -- play the anim when the door anim ends

  -- TODO clean up door evenetlistner
  door:addEventListener( "sprite", playerWalkStart )
--  playerWalk()
end

-- function loadNextLevelWithDelay()
--     timer.performWithDelay(200, loadNextLevel)
-- end


function loadNextLevel()

  audioManager.playLoadNextLevel()
  player.isVisible = false
  print("load next lvl")
  if currentLevel<lvlCount then
    loadLevel(currentLevel+1)
  end
end

function retry()
  print("reloadLevel")
  loadLevel(currentLevel)
end

-- Function to handle button events
local function handleRetryEvent( event )
    if ( "ended" == event.phase ) then
        retry()
    end
end

local function enableGems()
  -- disable gems
  for k,v in pairs(UIgems) do
    if k<=turnsLeft then
      if v.active == false then
        v:setSequence( "enable" )
        v:play()
        v:setFrame( 5 )
        v.active = true
      end
    end
  end
end


 function gems_outOfMoves()
  -- disable gems
  for k,v in pairs(UIgems) do
    -- if turnsLeft<=0 then
      -- if v.active == false then
        v:setSequence( "noMoves" )
        -- v:setFrame( 6 )
        v:play()
            -- gem:setSequence( "enable" )
            -- gem:play()
        -- v:setFrame( 5 )
        -- v.active = true
      -- end
    -- end
  end
end

function updateUndoButton()
  if turnsLeft<=0 and not levelCompleted then
    print("set undo anim")
    undoButton:setSequence("charged" )
    undoButton:play()
  else
    undoButton:setSequence("enabled" )
    undoButton:play()
  end

end

function executeUndo()
  print("execute undo")
  directionGravity = objectsPosBackupTable[turnsLeft+1].direction
  transition.cancel() -- cancels all ongoing transitions to prevent graphicglitches with undo transition and movement transition clashing
  for k,obj in pairs( objectsTable ) do
  --  moveGfxToObj(obj)
    lastPos = objectsPosBackupTable[turnsLeft+1][k]
    obj.hasMoved = false
    moveObject(lastPos.col,lastPos.row,obj)
    objectsPosBackupTable[turnsLeft]=nil
    -- TODO prevent boulder hit noise when not hitting a wall
    UpdateBoulderGfx(obj,1+ undoQueu*1.5)
  end
  turnsLeft = turnsLeft+1

  audioManager.playUndo()
  enableGems()
  rotateGfxTowardsGravity(directionGravity)
  updateUndoButton()

  debugUpdate()
  print("finished undo ==============")
end


function undo()
  print("undo")
  if turnsLeft < turnsTotal and levelCompleted==false and undoQueu+turnsLeft<=turnsTotal then
    undoQueu = undoQueu + 1
    if undoQueu > 0 and not undoInProgress then
      undoInProgress = true
      executeUndo()
    end
    -- speed up animations that are  currently playing if we click undo again
    for k,obj in pairs( objectsTable ) do
      UpdateBoulderGfx(obj, 1+undoQueu*1.5)
    end
  end
end

local function disableGems()
  -- disable gems
  for k,v in pairs(UIgems) do
    if k>turnsLeft and k<=turnsTotal then
      if v.active == true then
        v:setSequence( "disable" )
        v:play()
        v.active = false
      end
    end
  end

end


function loadUIgems()
  for i,gem in pairs(UIgems) do
    if i% 2 == 0 then
      gem.yScale = -scale
    end
    -- center to screen
    gem.x = display.contentWidth/2 + i*scale*gem.width - (turnsTotal+1)*scale/2*gem.width
    gem.y = display.contentHeight*0.9
    gem.active = true
    gem.isVisible  = false
  --  timer.performWithDelay( 100, activateGem )
    if i<=turnsTotal then
        gem:setSequence( "enable" )
        gem:play()
        gem:setFrame( 5 )
    --  timer.performWithDelay( 1, activateGem )
      gem.isVisible  = true
    else
      gem.isVisible  = false
    end
  end
end


local function createUIgems()
  for  i=1,turnsMax,1 do --turnsTotal
    local gem = display.newSprite(UILayer,anim.imageSheetGem,anim.sequences_gem)
    UIgems[i] = gem
    gem.xScale = scale
    gem.yScale = scale
    -- gem:setSequence( "enable" )
    -- gem:play()
  end
end


local function createUI()
  createUIgems()

  -- local retryButton = widget.newButton(
  --     {
  --         sheet = anim.imageSheetRetry,
  --         defaultFrame = 1,
  --         overFrame = 2,
  --         --label = "",
  --         onEvent = handleRetryEvent
  --     }
  -- )
  -- UILayer:insert(retryButton)
  -- -- Center the button
  -- retryButton.x = display.contentCenterX - 120 * scale
  -- retryButton.y = display.contentHeight*0.9
  -- retryButton.yScale = 1.5 * scale
  -- retryButton.xScale = 1.5 * scale


  -- local undoButton = widget.newButton(
  --     {
  --         sheet = anim.imageSheetRetry,
  --         defaultFrame = 1,
  --         overFrame = 2,
  --         --label = "",
  --         onEvent = undo
  --     }
  -- )

  undoButton = display.newSprite(UILayer, anim.imageSheetRetry,anim.sequences_retry)

  undoButton:addEventListener( "tap", undo )

  undoButton:setSequence("enabled" )
  undoButton:play()

  UILayer:insert(undoButton)
  -- Center the button
  undoButton.x = display.contentCenterX + 120 * scale
  undoButton.y =  display.contentHeight * 0.9
  undoButton.yScale = 1.5* scale
  undoButton.xScale = 1.5* scale
end

function checkMovingGfx()
    gfxAreMoving = false
    for k,v in pairs(getCanMoveObjects()) do
      if v.gfx.x ~= v.x or v.gfx.y ~= v.y then
        gfxAreMoving = true
      end
    end
    if not gfxAreMoving then

        checkWinLoss()
      end
end

function debugText(text,x,y)
  local myText = display.newText( text, x, y, native.systemFont, 50 )
  table.insert(debugInfo, myText )
end


function debugUpdate()
  if debugEnabled then
    for k,v in pairs(debugInfo) do
        v:removeSelf()
        debugInfo[k] = nil
    end
    for col,colTable in pairs(tileTable) do
      for row,obj in pairs(colTable) do
        x = tileSize*col + offsetX
        y = tileSize*row + offsetY
        if tileTable[col][row]~= 0 then
          if canObjMove( tileTable[col][row]) then
            -- debug moving tiles
            local debugimg = display.newRect(foreground,x,y, tileSize, tileSize )
            debugimg:setFillColor(0.8,0.3,0.8,0.4)
            table.insert(debugInfo, debugimg )
            debugText(obj.counter,tileSize*col + offsetX,tileSize*row+ offsetY)
            -- if obj.counter~-nil then
            -- local myText = display.newText( obj.counter, tileSize*col + offsetX, tileSize*row+ offsetY, native.systemFont, 50 )
            -- table.insert(debugInfo, myText )
          else
            -- debug static lvl tiles
            local debugimg = display.newRect(foreground,x,y, tileSize , tileSize )
            debugimg:setFillColor(1,0,0,0.2)
            table.insert(debugInfo, debugimg )
            debugText(col,x,y)
          end
        else
          local debugimg = display.newRect(foreground,x,y, tileSize, tileSize )
          debugimg:setFillColor(0,1,0,0.2)
          table.insert(debugInfo, debugimg )
        end
      end
    end
  end
end


local function Update()
  print ("--------- update cycle -----")

 -- checkPlayerAnim()
  disableGems()

  if objectsAreMoving == false then
    checkWinLoss()
  end

  -- for performance reasons we pause the update if no cubes are moving
  -- when pressing a key we renable this
  if objectsAreMoving == false and levelCompleted == false then
    timer.pause(tick)
    print ("==============PAUSE==============")
  end

  if objectsAreMoving==true and len(getAllMoveableObjects(directionGravity)) == 0 then
    objectsAreMoving = false
  end

  checkMovingGfx()

  if objectsAreMoving then
    moveMoveableObjects(directionGravity)
  end

  --
  updateUndoButton()
  debugUpdate()
end



local function Start()

  createUI()
    print("start: load lvl " .. currentLevel )
  -- if debugEnabled then
    -- loadLevel(lastlevel)
  -- else
    loadLevel(currentLevel)
  -- end

  createPlayer()
  tick = timer.performWithDelay( deltatime, Update, 0 ) --time in mili sec
  timer.pause(tick)
end


function scene:create( event )

  local sceneGroup = self.view


  sceneGroup:insert(background)
    sceneGroup:insert(midground)
    sceneGroup:insert(foreground)
    sceneGroup:insert(UILayer)





  Start()
end


function pausePlayer()
  transition.pause(player)
  player:pause()
  if playerEnterDarkTimer then
    timer.pause(playerEnterDarkTimer)
  end
end

function unpausePlayer()
  print("unpause player")
  transition.resume(player)
  player:play()
  if playerEnterDarkTimer then
    timer.resume(playerEnterDarkTimer)
  end
end


function resumeGame()

      if not menuOverlayVisible then
        print("show")

        local options = {
         params = { retryLevelCommand = retry }
       }
        composer.showOverlay( "menu_overlay",options )
        menuOverlayVisible = true
        pausePlayer()
      else
        print("hide")
        composer.hideOverlay( "menu_overlay" )
        menuOverlayVisible = false
        unpausePlayer()
      end
end

function scene:resumeGame()
  resumeGame()
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

    pausePlayer()

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
          Runtime:removeEventListener( "key", onKeyEvent )
          menuOverlayVisible = false

      print("hide play scene")
	end
end

function scene:show( event )

      --- @TODO remove This
      -- currentLevel = 15
      --- @TODO remove This


      if currentLevel ~= currentLevelLoaded then
        retry()
      end

    	local phase = event.phase

    	if ( phase == "will" ) then
    		-- Code here runs when the scene is on screen (but is about to go off screen)

    	elseif ( phase == "did" ) then
    		-- Code here runs immediately after the scene goes entirely off screen

          print("show play scene")
          Runtime:removeEventListener( "key", onKeyEvent )
          Runtime:addEventListener( "key", onKeyEvent )
        	print ("addKeyListener")
          unpausePlayer()
    	end


end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
 scene:addEventListener( "show", scene )
 scene:addEventListener( "hide", scene )
-- scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
return scene
