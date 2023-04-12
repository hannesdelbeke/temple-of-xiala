
local M = {} --publicClass


M.levels = {}

local function addLevel(jsonName,turns)
  local lvl = {}
  lvl.name = jsonName
  lvl.jsonPath = "levels/"..jsonName..".json"
  lvl.turns = turns
    table.insert(M.levels,lvl )
end

addLevel("lvl1",2)
addLevel("lvl2",6)
addLevel("lvl3",4)
addLevel("lvl4",4)
addLevel("lvl5",5)
addLevel("kickstarterMitchell",6)
addLevel("lvl6",6)
addLevel("lvl7",8)
addLevel("kickstarterNelson",7)
addLevel("lvl8",5)
addLevel("lvl9",6)
addLevel("lvl10",5)
addLevel("lvl11",5)
addLevel("lvl12",8)
addLevel("lvl13",6)
addLevel("lvl14",5)
addLevel("lvl15tutorialSlide",3)
addLevel("lvl16",5)
addLevel("lvl17",6)
addLevel("lvl18",5)
addLevel("lvl19",7) 
addLevel("lvl20",10)

-- print("levels")
-- for k,v in pairs(M.levels) do
-- 	print (k)
-- 	print (v)
-- 	end



function M:getIndexLevel(key)
	local index={}
	local value = "vol valueeeeee"
	for k,v in pairs(M.levels) do
		if v.name==key then return k end
	end
end


return M
