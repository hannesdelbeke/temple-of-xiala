-- by hannes delbeke october 2017
-- GAME LOGIC

-- tweakable variables


--local allGraphics = {}

local lvlCount = 2
local levels = {
  [1]="levels/sourcetest.json",
  [2]="levels/lvl2.json"
}
local turnsLvl = {
  [1] = 4,
  [2] = 5
}

local indexGem = 8
local indexDoor = 18
local index_topSlot = 19
local index_botSlot = 7

local tileSize = 40*scale -- this scales the 20 pixel tiles up with x2
local offsetX = display.contentCenterX/2 -2*tileSize
local offsetY = 0.5*tileSize

local debugEnabled = true

-------------------------------------------------------------------
-- logic variables
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

local deltatime = 100
local globaltimer = 0

local rows = 11
local cols = 7

local player
local debugInfo = {}

local tick
local objectsAreMoving = false

local objectsTable = {}
local objectsPosBackupTable = {}
local tileTable = {}
local doorTable = {}
local levelGraphicsTable = {}

local UIgems = {}

local anim =      require("scripts.AnimData")
local json =      require( "json" )
local widget =    require( "widget" )
local composer =  require( "composer" )
local scene = composer.newScene()

local background = display.newGroup()
local midground = display.newGroup()  --this will overlay 'farBackground'
local foreground = display.newGroup()
local UILayer = display.newGroup()

-- ==================================================================
-- functions
-- ==================================================================

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


local function checkWinLoss()
  --check if win conditions are filled
  --lvl 1 check for slot
  local isFree = false

  -- for k,v in pairs(fillSlotsForWin) do
  --   if getObj(v,rows)~=0 then
  --     isFree=true
  --   else
  --     return false
  --   end
  -- end
  for col=1,cols,1 do
    if getObj(col,rows-1)~=0 then -- check lowest row
      isFree=true
    else
      return false
    end
  end
  -- check if bott row is free, if yes move the player
  -- cols is 2 because players spawns at 1
  for col=2,cols,1 do
    if getObj(col,4)~=0 then -- hardcoded row 4
      isFree=false
    end
  end
  if isFree and objectsAreMoving==false then
    print("WIN")
    -- TODO play animation, doors disapear
    -- wait
    if levelCompleted==false then
      loadLevelAnimation()
      levelCompleted=true
    end
  --  timer.pause(tick)
  end
end


local function getRow(obj)
  return (obj.y-offsetY)/tileSize
end


local function getCol(obj)
  return (obj.x-offsetX)/tileSize
end


local function simpleMoveObject(col,row,obj)
  obj.x = col*tileSize+offsetX
  obj.y = row*tileSize+offsetY
end

local function moveObject(col,row,obj)
  if obj.hasMoved then
    return false
  end
  originalCol = getCol(obj)
  originalRow = getRow(obj)
  obj.hasMoved = true

  --this here seems bugged, swapping out table wih 0 freaks out with multiple boulders
  if originalCol>=0 and originalRow>=0  then
    --and tileTable[originalCol][originalRow]~=0
    --and tileTable[originalCol][originalRow].hasMoved==true
    tileTable[originalCol][originalRow] = 0
  end
	obj.x = col*tileSize+offsetX
	obj.y = row*tileSize+offsetY

--todo move the obj out of its current place in the table
  tileTable[col][row] = obj

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
  elseif nextObj.canMove then
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
	local enemy = display.newImageRect(background,"textures/platform.png", tileSize, tileSize)
  enemy.isVisible = false
  moveObject(col,row,enemy)
	--enemy.isAttacking = false
	--enemy.valueHealth = 100
	return enemy
end

local function resetPlayer()
  if player then
    print ("resetplayer")
    player.x = - 6*scale + offsetX
    player.y = tileSize*4 +4*scale + offsetY -- 16px in mid of 20px. (20-16)/2 , then *2 because all tiles are *2. =4 pixels ofset
    player:setSequence("idle" )
    player:play()
    transition.pause(player)
  end
end

local function createPlayer()--col,row)
	player = display.newSprite(foreground, anim.imageSheetPlayer,anim.sequences_player)
  --moveObject(col,row,player)
  -- player.x = 34
  -- player.y = tileSize*6 +4 -- 16px in mid of 20px. (20-16)/2 , then *2 because all tiles are *2. =4 pixels ofset
--  244
  resetPlayer()

  player.xScale = 2*scale
  player.yScale = 2*scale
  -- player:play()
end


local function BoulderGfxArrived()
--print (objectsAreMoving)


end

  -- if boulder.gfx.x~=boulder.x and boulder.gfx.y~=boulder.y then
  --   boulder.gfx.x=boulder.x
  --   boulder.gfx.y=boulder.y
  -- end

local function UpdateBoulderGfx(boulder,speed)
  if speed == nil then
    speed = 2
  end

  boulderGfx = boulder.gfx

  -- if boulderGfx.x~=boulderGfx.xTarget or boulderGfx.y~=boulderGfx.yTarget then
  --   boulderGfx.x=boulder.x
  --   boulderGfx.y=boulder.y
  -- end

  transition.to (
    boulderGfx,
    {
      --transition = easing.inQuad ,
      time = speed*deltatime,
      x = boulder.x,
      y = boulder.y,
      onComplete = BoulderGfxArrived
    }
  )
  -- boulderGfx.xTarget = boulder.x
  -- boulderGfx.yTarget = boulder.y
end


local function createBoulder(col,row)
-- create logic - since we write it based on position for now we split gfx and  gameplay

  local boulder = display.newSprite(background, anim.imageSheetSprites, anim.sequences_spritesheet )
  boulder.isVisible = false
  boulder.xScale = 2*scale
  boulder.yScale = 2*scale
--  boulder:play()

  moveObject(col,row,boulder)

	boulder.isFixedRotation = true
  boulder.canMove = true
  boulder.hasMoved = false

  -- create GFX
  local boulderGfx = display.newSprite(background, anim.imageSheetSprites, anim.sequences_spritesheet )
  boulder.gfx = boulderGfx
  boulderGfx.xScale = 2*scale
  boulderGfx.yScale = 2*scale
  boulderGfx.x = boulder.x
  boulderGfx.y = boulder.y
	boulderGfx.isFixedRotation = true
  boulderGfx.canMove = true
  boulderGfx.hasMoved = false

  -- randomise incase of multiple boulders
  if math.random(1, 2 ) == 2 then
    boulderGfx:setSequence("idleGem2" )
  end
  boulderGfx:play()

	table.insert(objectsTable, boulder )

	--table.insert(objectsTableGfx, boulder )
	return boulder
	--boulder.alpha = 0.5
end

-- width 8 *40
-- height 12 * 40
local function createWall(col,row)
  local wall = display.newImageRect(background, "moveCube.png", tileSize, tileSize )
  wall.x = x+offsetX
  wall.y = y+offsetY
  return wall
end


local function getFreeSlot(direction,col,row)
  local  c, r = col,row
  if direction==e_direction.up then
    if row-1>0 and tileTable[col][row-1]==0 then
       return true
    end
  elseif  direction==e_direction.down then
    if row+1<=rows and tileTable[col][row+1]==0 then
       return true
    end
  elseif  direction==e_direction.left then
    if col-1>0 and tileTable[col-1][row]==0 then
       return true
    end
  elseif  direction==e_direction.right then
    if col+1<=cols and tileTable[col+1][row]==0 then
       return true
    end
  end
   return false
end

local function getFreeSlotObj(direction,obj)
  return getFreeSlot(direction,getCol(obj),getRow(obj))
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



local function willMoveNextFreeSlot(direction,col,row)
  -- this ignores moveable objects and  sees if they will all shift as well
local counter = 0
  while true do
    counter = counter+1
          -- if next slot is out ofrange
    if getColRowFromDirectionOffset(direction,col,row,1)==false then
      return false
    end

    -- if next slot isfree it can move
    if getFreeSlot(direction,col,row) then
      return true
    end

    col,row = getColRowFromDirectionOffset(direction,col,row,1)
    local obj = getObj(col,row)

      -- if next slot has a moveable guy continue while loop
    --elseif obj ~=0 and obj.canMove then

        --if next slot can not move
    if obj ~=0 and obj.canMove==false then
      return false
    end
  end
end

--check which tiles are avaible to  move (have a free slot next to them), return them in a table
local function getMoveableObjects(direction,objects)
  local moveableObjTable = {}
  for k,v in pairs(objects) do
    if v.canMove then
      if getFreeSlotObj(direction,v) then
        table.insert(moveableObjTable, v )
    --  elseif
      end
    end
  end
  return moveableObjTable
end

local function getAllMoveableObjects(direction)
  return getMoveableObjects(direction,objectsTable)
end

local function getCanMoveObjects(direction)
  -- get objects that can move, but not they might not be able to atm because there is no free slot available
  local canMoveObj = {}
  for k,v in pairs(objectsTable) do
    if v.canMove then
      table.insert(canMoveObj, v )
    end
  end
  return canMoveObj
end

local function moveMoveableObjects(direction)
    local objectsToMove = {} --store objs to move later to not cause table mess

    for k,obj in pairs( objectsTable) do
      if obj~= 0 then
      end
      if obj~= 0 and obj.canMove and obj.hasMoved == false then
      -- move them all up untill there is no free slot

       --get the row and col for the obj we will move
       -- check if next slot is  free
       col = getCol(obj)
       row = getRow(obj)
       if willMoveNextFreeSlot(direction,col,row) then
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

    for k,obj in pairs( objectsToMove ) do

    --  objectsPosBackupTable[turnsLeft+1][k] = {
      --   col=getCol(obj),
      --   row=getRow(obj)
      -- }

      moveObjectRecursive(direction,obj)
      UpdateBoulderGfx(obj)
    end

    for k,v in pairs(objectsTable) do
     v.hasMoved = false
    end
end

local  function rotateGfxTowardsGravity(direction)
  -- rotate the boulder towards the direction its going
  for k,v in pairs(objectsTable) do
    local rotation = 0
    if direction==e_direction.up then
      rotation = 180
    elseif direction == e_direction.down then
      rotation = 0
    elseif direction == e_direction.left then
      rotation = 90
    elseif direction == e_direction.right then
      rotation = -90
    end
    v.gfx.rotation = rotation
  end
end

local function changeGravity(direction)
  timer.resume(tick)
  print ("changeGRAVITY")
  if len(getAllMoveableObjects(direction)) == 0 or objectsAreMoving then
    print("nothing to move")
    return false
  end


	if (turnsLeft>0) then
    directionGravityLastTurn = directionGravity
    directionGravity = direction
    objectsAreMoving = true
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
      if ( event.keyName == "up" ) then
    	   changeGravity( e_direction.up)
      elseif event.keyName == "down" then
    	   changeGravity( e_direction.down)
      elseif event.keyName == "left" then
    	   changeGravity( e_direction.left)
      elseif event.keyName == "right" then
    	   changeGravity( e_direction.right)
      end
    end

    print("check escape menu")
    if ( event.keyName == "escape" ) then
      resumeGame()
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

  levelGraphicsTable = {}
  objectsTable = {}
  objectsTableGfx = {}
  tileTable = {}
  doorTable = {}
end

function loadLevel(lvl)
  resetPlayer()
  -- reset undo table
  objectsPosBackupTable = {}

  currentLevel = lvl
  -- TODO
  -- load turnsLeft
  turnsLeft = turnsLvl[lvl]
  turnsTotal = turnsLeft
  -- load winning slots that need filling

  loadUIgems()

  if len(tileTable)>0 then
    print("unload level")
    unloadLevel()
  end

  local filename = system.pathForFile( levels[lvl] )
  local decoded, pos, msg = json.decodeFile( filename )
  if not decoded then
      print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
  else
      print( "File successfully decoded!" )
  end

  -- this is specific for this lvl
  rows = decoded["tileshigh"]-1
  cols = decoded["tileswide"]-2

  for col=1,cols do
    tileTable[col] ={}
    for row=1,rows do
      tileTable[col][row] = 0
    end
  end

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
        local obj
        if  vv["tile"]==index_botSlot then
          obj = display.newSprite(background, anim.imageSheetSprites, anim.sequences_spritesheet )
          obj.x, obj.y = vv["x"]*tileSize+offsetX, vv["y"]*tileSize+offsetY
          obj.xScale = 2*scale
          obj.yScale = 2*scale
          obj:setSequence( "bot_idleSlot" )
          obj:play()

        elseif  vv["tile"]==index_topSlot then
          obj = display.newSprite(background, anim.imageSheetSprites, anim.sequences_spritesheet )
          obj.x, obj.y = vv["x"]*tileSize+offsetX, vv["y"]*tileSize+offsetY
          obj.xScale = 2*scale
          obj.yScale = 2*scale
          obj:setSequence( "top_idleSlot" )
          obj:play()

        elseif vv["tile"]~=-1 then
          --draw tile
          --display.newImageRect()
          obj = display.newImageRect(background, anim.imageSheetTiles, vv["tile"]+1, tileSize, tileSize)
          obj.x, obj.y = vv["x"]*tileSize+offsetX, vv["y"]*tileSize+offsetY
          obj.rotation = vv["rot"]*90
          if vv["flipX"] then
            obj.xScale = -1
          end
        end

        if vv["tile"]~=-1 then
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
      for kk,vv in pairs(v["tiles"]) do
        if vv["tile"]~=-1 and vv["tile"]~=indexDoor then -- TODO in stead of saying which tiles to ignore, we should say if tile = index of boulder
          -- if vv["y"] == rows then
          --   table.insert(fillSlotsForWin,vv["x"] )
          -- else
          --vv["tile"]==indexGem
            createBoulder(vv["x"],vv["y"])
        --  end


      elseif vv["tile"]==indexDoor then

            local obj = display.newSprite(background, anim.imageSheetSprites, anim.sequences_spritesheet )
            -- animatedDoor.x = 80+10
            -- animatedDoor.y = 20
            obj.xScale = 2*scale
            obj.yScale = 2*scale
            obj:setSequence( "idleDoor" )
            obj:play()

            obj.x, obj.y = vv["x"]*tileSize+offsetX, vv["y"]*tileSize+offsetY
            obj.rotation = vv["rot"]*90
            if vv["flipX"] then
              obj.xScale = -2*scale
            end

          	table.insert(doorTable, obj )

        end
      end
    end
  end

  levelCompleted=false
end

local function startDarkWalk(event)
  if player.sequence == "enterDark" and event.phase == "ended" then
    player:setSequence("darkWalk" )
    player:play()
  end
end

local function checkPlayerAnim()
    if player.x >= (offsetX + tileSize*(cols+0.5)) and player.sequence == "walk" then
      player:setSequence("enterDark" )
      player:play()

      -- TODO clean up event listener
      player:addEventListener( "sprite", startDarkWalk )
    end
end

local function playerWalk()
  player:setSequence("walk" )
  player:play()


  transition.to (
    player,
    {
      --tag = "player",
      time = 3000,

      -- TODO make this work with different resolutions andlevels
      x = display.contentWidth+tileSize/2 + offsetX,
      y = player.y,
      onComplete = loadNextLevel
    }
  )
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
  door = doorTable[1]
  player:setSequence("delight" )
  player:play()
  -- play the anim when the door anim ends

  -- TODO clean up door evenetlistner
  door:addEventListener( "sprite", playerWalkStart )
--  playerWalk()
end

function loadNextLevel()
  print("load next lvl")
  if currentLevel<lvlCount then
  -- TODO create reset player function
    -- player.x = 10
    -- player.y = 240
    -- player:setSequence("idle" )
    -- player:play()
    loadLevel(currentLevel+1)
  --  loadLevel(currentLevel+1)
  end
end

-- Function to handle button events
local function handleRetryEvent( event )
  print("reloadLevel")
    if ( "ended" == event.phase ) then
        loadLevel(currentLevel)
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

local function undo( event )
  if ( "ended" == event.phase ) and turnsLeft < turnsTotal and levelCompleted==false then
    --objectsPosBackupTable

    directionGravity = objectsPosBackupTable[turnsLeft+1].direction
    for k,obj in pairs( objectsTable ) do
      --
      -- objectsPosBackupTable[turnsLeft+1][k] = {
      --   col=getCol(obj),
      --   row=getRow(obj)
      -- }
      lastPos = objectsPosBackupTable[turnsLeft+1][k]

      obj.hasMoved = false
      moveObject(lastPos.col,lastPos.row,obj)

      objectsPosBackupTable[turnsLeft]=nil
      UpdateBoulderGfx(obj,1)
    end
    turnsLeft = turnsLeft+1
    print("undo")
    enableGems()
    rotateGfxTowardsGravity(directionGravity)
  end
end

local function disableGems()
  -- disable gems
  for k,v in pairs(UIgems) do
    if k>turnsLeft and k<=turnsTotal then
      if v.active == true then
        print("disabling UI gem")
        v:setSequence( "disable" )
        v:play()
        v.active = false
      end
    end
  end

end


-- local function activateGem(event)
--   for i,gem in pairs(UIgems) do
--     if i<=turnsTotal then
--       gem:setSequence( "enable" )
--       gem:play()
--       gem:setFrame( 5 )
--   --  timer.performWithDelay( 1, activateGem )
--
--       gem.isVisible  = true
--     else
--       gem.isVisible  = false
--     end
--   end
--end


function loadUIgems()
  for i,gem in pairs(UIgems) do
    if i% 2 == 0 then
      gem.yScale = -scale
    end
    -- center to screen
    gem.x = display.contentWidth/2 + i*tileSize/2 - (turnsTotal+1)/2*tileSize/2
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

  local retryButton = widget.newButton(
      {
          sheet = anim.imageSheetRetry,
          defaultFrame = 1,
          overFrame = 2,
          --label = "",
          onEvent = handleRetryEvent
      }
  )
  UILayer:insert(retryButton)
  -- Center the button
  retryButton.x = display.contentCenterX - 120 * scale
  retryButton.y = display.contentHeight*0.9
  retryButton.yScale = 1.5 * scale
  retryButton.xScale = 1.5 * scale

  local undoButton = widget.newButton(
      {
          sheet = anim.imageSheetRetry,
          defaultFrame = 1,
          overFrame = 2,
          --label = "",
          onEvent = undo
      }
  )
  UILayer:insert(undoButton)
  -- Center the button
  undoButton.x = display.contentCenterX + 120 * scale
  undoButton.y =  display.contentHeight*0.9
  undoButton.yScale = 1.5* scale
  undoButton.xScale = 1.5* scale
end

local function Update()
  print ("update cycle")

  checkPlayerAnim()
  disableGems()
  checkWinLoss()

  -- for performance reasons we pause the update if no cubes are moving
  -- when pressing a key we renable this
  if objectsAreMoving == false and levelCompleted == false then
    timer.pause(tick)
    print ("pause")
  end


  if objectsAreMoving==true and len(getAllMoveableObjects(directionGravity)) == 0 then

    --TODO add support for boulder graphics

    objectsAreMoving = false
  end



  if objectsAreMoving then
    moveMoveableObjects(directionGravity)
  end

    print (debugEnabled)
  if debugEnabled then
    print ("debugging")
    for k,v in pairs(debugInfo) do
        v:removeSelf()
        debugInfo[k] = nil
    end
    for col,colTable in pairs(tileTable) do
      for row,obj in pairs(colTable) do
        if tileTable[col][row]~= 0 then
          if tileTable[col][row].canMove then
            -- debug moving tiles
            local debugimg = display.newRect(foreground,tileSize*col + offsetX,tileSize*row + offsetY, tileSize, tileSize )
            debugimg:setFillColor(0.8,0.3,0.8,0.4)
            table.insert(debugInfo, debugimg )
          else
            -- debug static lvl tiles
            local debugimg = display.newRect(foreground,tileSize*col + offsetX,tileSize*row+ offsetY, tileSize , tileSize )
            debugimg:setFillColor(1,0,0,0.2)
            table.insert(debugInfo, debugimg )

          end
        else
          local debugimg = display.newRect(foreground,tileSize*col + offsetX,tileSize*row+ offsetY, tileSize, tileSize )
          debugimg:setFillColor(0,1,0,0.2)
          table.insert(debugInfo, debugimg )
        end
      --  debugimg:removeSelf()
      end
    end
  end

end

local function Start()
  --Runtime:addEventListener( "key", onKeyEvent )
  createUI()
    print("start: load lvl " .. currentLevel )
  loadLevel(currentLevel)
    --
    -- for k,v in pairs(UIgems) do
    --   v:setSequence( "enable" )
    --   v:play()
    --   v:setFrame(5)
    -- end

  createPlayer()
  tick = timer.performWithDelay( deltatime, Update, 0 ) --time in mili sec
  timer.pause(tick)
end


		-- local platformName = system.getInfo( "platformName" )
		-- if ( platformName == "Android" ) or ( platformName == "WinPhone" ) then
		--     return true
		-- end

		--[[

		local function setLaunchDirection(event)

			dirx = event.x-boulder.x
			diry = event.y-boulder.y
			lengthVector = math.sqrt(dirx*dirx+diry*diry)
			dirx = dirx/lengthVector
			diry = diry/lengthVector

			--local rotJoint = physics.newJoint( "touch",boulder,platform.x,platform.y )
			--rotJoint:setTarget( event.x, event.y )
		--	direction = Vector(event.x-boulder.x,event.y-boulder.y)
			--direction.normalize()
			boulder:applyLinearImpulse( dirx,diry, boulder.x, boulder.y )
		end

		background:addEventListener( "tap", setLaunchDirection )



    if direction==e_direction.up then

    end

    if direction==e_direction.down then
    end

    if direction==e_direction.left then
    end

    if direction==e_direction.right then
    end


		]]
  -- local function onKeyEvent( event )
  -- 		if (event.phase=="up") then return false
  -- 		end
  --
  --     if ( event.keyName == "escape" ) then
  --
  -- 			if not menuOverlayVisible then
  -- 				print("show")
  -- 				composer.showOverlay( "menu_overlay" )
  -- 				menuOverlayVisible = true
  -- 			else
  -- 				print("hide")
  -- 				composer.hideOverlay( "menu_overlay" )
  -- 				menuOverlayVisible = false
  -- 			end
  --
  --     end
  --
  --    -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
  --     if ( event.keyName == "back" ) then
  --         local platformName = system.getInfo( "platformName" )
  --
  -- 		--	composer.gotoScene( "menu" )
  --
  --         if ( platformName == "Android" ) or ( platformName == "WinPhone" ) then
  --             return true
  --         end
  --     end
  --
  --     -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
  --     -- This lets the operating system execute its default handling of the key
  --     return false
  -- end

function scene:create( event )

  local sceneGroup = self.view

---  local sceneGroup = self.view

  sceneGroup:insert(background)
    sceneGroup:insert(midground)
    sceneGroup:insert(foreground)
    sceneGroup:insert(UILayer)





  Start()
end

function resumeGame()

      if not menuOverlayVisible then
        print("show")
        composer.showOverlay( "menu_overlay" )
        menuOverlayVisible = true
      else
        print("hide")
        composer.hideOverlay( "menu_overlay" )
        menuOverlayVisible = false
      end
end

function scene:resumeGame()
  resumeGame()
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

  -- background.isVisible = false
  -- midground.isVisible = false
  -- foreground.isVisible = false
  -- UILayer.isVisible = false

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
          Runtime:removeEventListener( "key", onKeyEvent )
          menuOverlayVisible = false

      print("hide play scene")
	end
end

function scene:show( event )


    	local phase = event.phase

    	if ( phase == "will" ) then
    		-- Code here runs when the scene is on screen (but is about to go off screen)

    	elseif ( phase == "did" ) then
    		-- Code here runs immediately after the scene goes entirely off screen

          print("show play scene")
          Runtime:removeEventListener( "key", onKeyEvent )
          Runtime:addEventListener( "key", onKeyEvent )
        	print ("addKeyListener")
    	end

  -- background.isVisible = true
  -- midground.isVisible = true
  -- foreground.isVisible = true
  -- UILayer.isVisible = true

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
