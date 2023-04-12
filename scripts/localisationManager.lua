-- get all naming from this file
local M = {} --publicClass

M.languages = {}
M.languages.english = "english"
M.languages.dutch = "nederlands"

function M:setLanguage(language)
	local continue = {}
	continue.english ="continue"
	continue.dutch ="doorgaan"
	M.continue = continue[language]

	local play = {}
	play.english ="Play"
	play.dutch ="Start spel"
	M.play = play[language]

	local levelSelect = {}
	levelSelect.english ="level Select"
	levelSelect.dutch ="selecteer level"
	M.levelSelect = levelSelect[language]

	local credits = {}
	credits.english ="credits"
	credits.dutch ="aftiteling"
	M.credits = credits[language]

	local quit = {}
	quit.english ="quit"
	quit.dutch ="afsluiten"
	M.quit = quit[language]

	local continue = {}
	continue.english ="continue"
	continue.dutch ="doorgaan"
	M.continue = continue[language]

	local retry = {}
	retry.english ="retry"
	retry.dutch ="herproberen"
	M.retry = retry[language]

	local menu = {}
	menu.english ="menu"
	menu.dutch ="menu"
	M.menu = menu[language]

end

--M:setLanguage("dutch")
-- print(M.continue)
-- print ("test")
return M


