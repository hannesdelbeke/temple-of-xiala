-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- split up into seperate scripts
--gridmanager

-- TODO
--load level
-- clear objectsTable
--create background and boulders

local debugInfo = {}
local debugEnabled = false
-- enum for directions
local tileSize = 40
local rows = 11
local cols = 7
local e_direction = {
  up = {},
  down = {},
  left = {},
  right = {}
}

local directionGravity = e_direction.right
local uiGroup = display.newGroup()
local turnsLeft = 0
local tick
local objectsAreMoving = false
--[[
local grid = {}

for  i=1,8,1 do
  grid[i] = {}
end]]

local objectsTable = {}
local tileTable = {}
local levelGraphicsTable = {}
local fillSlotsForWin = {}

-- make upscaling pixel perfect
display.setDefault( "magTextureFilter", "nearest" )
--display.setDefault( "minTextureFilter", "nearest" )

local options =
{
    --required parameters
    width = 20,
    height = 20,
    numFrames = 16,
    border = 1
    --optional parameters; used for scaled content support
    -- sheetContentWidth = 169,  -- width of original 1x size of entire sheet
    -- sheetContentHeight = 43   -- height of original 1x size of entire sheet
}
local imageSheet = graphics.newImageSheet( "textures/sourceTilesettest.png", options )


local levels = {
  [1]="levels/sourcetest.json",
  [2]="levels/sourcetest2.json"
}


local json = require( "json" )



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
    if getObj(col,rows)~=0 then
      isFree=true
    else
      return false
    end
  end

  -- check if bott row is free, if yes move the player
  -- cols is 2 because players spawns at 1
  for col=2,cols,1 do
    if getObj(col,4)~=0 then
      isFree=false
    end
  end
  if isFree and objectsAreMoving==false then
    print("WIN")
    loadLevel(2)
    --unloadLevel()
  end
end

local function updateText()
  turnsLeftText.text = turnsLeft
end

local function getRow(obj)
  return obj.y/tileSize
end
local function getCol(obj)
  return obj.x/tileSize
end




local function moveObject(col,row,obj)
  if obj.hasMoved then
    return false
  end
  originalCol = getCol(obj)
  originalRow = getRow(obj)
--  originalRow = getRow(obj)

  obj.hasMoved = true

  --this here seems bugged, swapping out table wih 0 freaks out with multiple boulders
  if originalCol~=0 and originalRow~=0  then
    --and tileTable[originalCol][originalRow]~=0
    --and tileTable[originalCol][originalRow].hasMoved==true
    tileTable[originalCol][originalRow] = 0
  end
  -- rows and columns start at 1
  -- 7 cols
  -- 11 rows
	obj.x = col*tileSize
	obj.y = row*tileSize

--  colTable[col] = obj
--  rowTable[row] = obj

--todo move the obj out of its current place in the table
  tileTable[col][row] = obj

	return obj
end

local function moveObjectRecursive(direction,obj)
  --move recursive
  print(obj)
  print("test1")
  local col = getCol(obj)
  print("test2")
  local row = getRow(obj)
  print("test3")
  local c,r = getColRowFromDirectionOffset(direction,col,row,1)
  print(c)
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
	local enemy = display.newImageRect("textures/platform.png", tileSize, tileSize)
  enemy.isVisible = false
  moveObject(col,row,enemy)
	--enemy.isAttacking = false
	--enemy.valueHealth = 100
	return enemy
end

local function createPlayer(col,row)
	local player = display.newImageRect("textures/dude.png", tileSize, tileSize)
  moveObject(col,row,player)
	--enemy.isAttacking = false
	--enemy.valueHealth = 100
	return player
end

local function createBoulder(col,row)
	local boulder = display.newImageRect( "textures/moveCube.png", tileSize, tileSize )
	--boulder.x = x
	--boulder.y = y
	--boulder.alpha = 0.2
  moveObject(col,row,boulder)
	boulder.isFixedRotation = true
  boulder.canMove = true
  boulder.hasMoved = false
	table.insert(objectsTable, boulder )
	return boulder
	--boulder.alpha = 0.5
end

-- width 8 *40
-- height 12 * 40
local function createWall(col,row)
  local wall = display.newImageRect( "moveCube.png", tileSize, tileSize )
  wall.x = x
  wall.y = y
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

--check if it is a canMove and not 0/empty


--getColRowFromDirectionOffset

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
      --check all moveable objects in colTable
      -- for col,colTable in pairs(tileTable) do
      --   for row,obj in pairs(colTable) do
      --     if obj~=0 and obj.canMove then
      --     end
      --   end
      -- end

    for k,obj in pairs( objectsToMove ) do
    --  col = getCol(obj)
    --  row = getRow(obj)
    --  c,r = getColRowFromDirectionOffset(direction,col,row,1)
      --moveObject(c,r,obj)
      moveObjectRecursive(direction,obj)
    end


    -- for col,colTable in pairs(tileTable) do
    --   for row,obj in pairs(colTable) do
    --     if obj~=0 and obj.canMove then
    --     end
    --   end
    -- end


    for k,v in pairs(objectsTable) do
     v.hasMoved = false
    end


end

local function changeGravity(direction)
  print ("changeGRAVITY")
  if len(getAllMoveableObjects(direction)) == 0 or objectsAreMoving then
    print("nothing to move")
    return false
  end

	if (turnsLeft>0) then
    directionGravity = direction
    objectsAreMoving = true
		turnsLeft = turnsLeft - 1
  end



	updateText()
end

local function moveTEMPNAME()

      --  colTable[col] = obj
      --  rowTable[row] = obj

end

local function onKeyEvent( event )
	if (event.phase=="up") then return false
	end

    if ( event.keyName == "up" ) then
  	   changeGravity( e_direction.up)
    elseif event.keyName == "down" then
  	   changeGravity( e_direction.down)
    elseif event.keyName == "left" then
  	   changeGravity( e_direction.left)
    elseif event.keyName == "right" then
  	   changeGravity( e_direction.right)
    end

   -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
    if ( event.keyName == "back" ) then
        local platformName = system.getInfo( "platformName" )
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
  tileTable = {}
end

function loadLevel(lvl)
  -- TODO
  -- load turnsLeft
  turnsLeft = 6
  -- load winning slots that need filling

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
        if vv["tile"]~=-1 then
          --draw tile
          --display.newImageRect()
          local obj = display.newImageRect( imageSheet, vv["tile"]+1, 40, 40 )
          obj.x, obj.y = vv["x"]*40, vv["y"]*40
          obj.rotation = vv["rot"]*90
          if vv["flipX"] then
            obj.xScale = -1
          end

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
        if vv["tile"]~=-1 then
          -- if vv["y"] == rows then
          --   table.insert(fillSlotsForWin,vv["x"] )
          -- else
            createBoulder(vv["x"],vv["y"])
        --  end
        end
      end
    end

  end



end



local function Update()

  checkWinLoss()


  if objectsAreMoving==true and len(getAllMoveableObjects(directionGravity)) == 0 then
    objectsAreMoving = false
  end



  if objectsAreMoving then
    moveMoveableObjects(directionGravity)
  end

  if debugEnabled then
    for k,v in pairs(debugInfo) do
    --  if v~=nil then

        v:removeSelf()
        debugInfo[k] = nil
    --  end
    end

    for col,colTable in pairs(tileTable) do
      for row,obj in pairs(colTable) do
        if tileTable[col][row]~= 0 then
          if tileTable[col][row].canMove then
            -- debug moving tiles
            local debugimg = display.newRect(tileSize*col,tileSize*row, tileSize, tileSize )
            debugimg:setFillColor(0.8,0.3,0.8,0.4)
            table.insert(debugInfo, debugimg )
          else
            -- debug static lvl tiles
            local debugimg = display.newRect(tileSize*col,tileSize*row, tileSize, tileSize )
            debugimg:setFillColor(1,0,0,0.2)
            table.insert(debugInfo, debugimg )

          end
        else
          local debugimg = display.newRect(tileSize*col,tileSize*row, tileSize, tileSize )
          debugimg:setFillColor(0,1,0,0.2)
          table.insert(debugInfo, debugimg )
        end
      --  debugimg:removeSelf()
      end
    end
  end

end

local function Start()

loadLevel(1)

  --local background = display.newImageRect( "textures/background.png", 360, 570 )
--  background.x = display.contentCenterX
--  background.y = display.contentCenterY

  --make text after background
  turnsLeftText = display.newText( turnsLeft, display.contentCenterX, 20, native.systemFont, 40 )
  turnsLeftText:setFillColor( 0, 0, 0 )


  Runtime:addEventListener( "key", onKeyEvent )
  tick = timer.performWithDelay( 100, Update, 0 ) --time in mili sec
end



Start()

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
