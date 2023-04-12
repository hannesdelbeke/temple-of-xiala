local M = {}
M.__index = M

local json = require("json")

M.saveData = {} -- is actially saved as array, keywords arent saved

-- local saveData = {}

local saveFile = system.pathForFile( "data.sav", system.DocumentsDirectory) --SavesDir
-- local saveFile =  "SavesDir.data.sav"

-- local saveFile = "D:\\Corona Projects\\gravity puzzle\\SavesDir\\data.sav"
-- print (saveFile)
-- print("path")
local jsoncontents = ""


function M:readJson()
 	-- local saveData = {}
 	local file = io.open( saveFile, "r" )
	if file then
		local jsoncontents = file:read( "*a" )
		M.saveData = json.decode(jsoncontents)
		io.close( file )
	end
end


function M:saveJson()
    local file = io.open(saveFile, "w")
    local jsoncontents = json.encode(M.saveData)
    file:write( jsoncontents )
	io.close( file )
end

function M:saveLevelComplete(lvlName) --levels[lvl].name
	print ("save level completed")
	local lvlData = {}
	lvlData.name = lvlName	
	lvlData.completed = true


	local lastActiveLevelData = {}
	lastActiveLevelData.name = "lastActiveLevel"	
	lastActiveLevelData.completed = lvlName

	local lvlAlreadyInSave = false
	local saveAlreadyInSave = false
	for k,v in pairs(M.saveData) do
		if v.name == lvlName then
			v.completed=true	
			lvlAlreadyInSave = true
		elseif v.name == "lastActiveLevel" then
			v.completed = lvlName	
			saveAlreadyInSave = true
		end
	end
	if not lvlAlreadyInSave  then table.insert( M.saveData, lvlData ) end
	if not saveAlreadyInSave then table.insert( M.saveData, lastActiveLevelData ) end

	M.saveJson()

	self.loadAchievementsFromSaveFile()
end

-- function M:getLvlDataInSaveData(lvlName)
-- 	for k,v in pairs(M.saveData) do
-- 		if v.name == lvlName then
-- 			v.completed=true
-- 			return true
-- 		end
-- 	end
-- 	return nil
-- end


function M:isLevelCompleted(lvlName) --levels[lvl].name
	M.readJson()

	for k,v in pairs(M.saveData) do
		if v.name == lvlName then
			return v.completed
		end
	end
	return false
end

function M:getLastActiveLevel()
	M.readJson()
	-- load the level that was active in the prev session of our game

	self.loadAchievementsFromSaveFile()

	for k,v in pairs(M.saveData) do
		if v.name == "lastActiveLevel" then
			levelIndex = levelManager:getIndexLevel(v.completed) -- v completed stores the name of the last active level	
			return tonumber(levelIndex)
		end
	end
	return 1 -- return level 1 if no active level detected
end

function M:loadAchievementsFromSaveFile()

	-- get save file, which lvl unlocked
	-- apply achievements
	completedLevels = 0
	for k,v in pairs(M.saveData) do
		if v.completed ~= nil and v.name~="lastActiveLevel" then
			completedLevels = completedLevels +1
		end
	end

	for k,v in pairs({1,5,10,15,20}) do		
		x = v
	    if completedLevels >= x then
	      steamworks.setAchievementUnlocked( "ACHIEV_COMPLETE_"..x )
	      print ("ACHIEV_COMPLETE_"..x )
	    end
	end

    -- if completedLevels >= 1 then
    --   steamworks.setAchievementUnlocked( "ACHIEV_COMPLETE_1" )
    -- end
end

--if lvlName == "lvl1" then return true end --make sure lvl1 is always unlocked
return M