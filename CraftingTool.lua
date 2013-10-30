-- Create a new table for our code:
CraftingTool={ }

--some variables
CraftingTool.doCraft = false

CraftingTool.LastSkillUseTime = 0
CraftingTool.WaitTime = 3000

CraftingTool.prevItemId = 0
CraftingTool.ProgressGain = 0
CraftingTool.QualityGain = 0
CraftingTool.RecipeLevel = 0

CraftingTool.FirstUse = false
CraftingTool.FirstUseLevel = 0

--Look up tables
CraftingTool.cLookUpProf = { --proffesions table
	["CRP"] = { ["id"] = 8, ["init"] = false },
	["BSM"] = { ["id"] = 9, ["init"] = false },
	["ARM"] = { ["id"] = 10, ["init"] = false },
	["GSM"] = { ["id"] = 11, ["init"] = false },
	["LTW"] = { ["id"] = 12, ["init"] = false },
	["WVR"] = { ["id"] = 13, ["init"] = false },
	["ALC"] = { ["id"] = 14, ["init"] = false },
	["CUL"] = { ["id"] = 15, ["init"] = false },
}

CraftingTool.actionType = { --Next Action
	["0"] = "Progress",
	["1"] = "Quality",
	["2"] = "Durability",
	["3"] = "Buff",
	["4"] = "Skip"
}

CraftingTool.Skills = { } --Made Runtime
CraftingTool.Buffs = {} --Made Runtime

-- Initializing function, we create a new Window for our module that has 1 button and 1 field to display data:
function CraftingTool.ModuleInit()
	GUI_NewWindow("CraftingTool",600,200,300,200)
	--Crafting proffesion
	GUI_NewComboBox("CraftingTool","Profession","gCraftProf", "Profession Selection", "None")
	GUI_UnFoldGroup("CraftingTool","Profession Selection")
	--Crafting
	GUI_NewField("CraftingTool","Item ID","itemID", "Crafting")
	GUI_NewField("CraftingTool","Item Level","itemLevel", "Crafting")
	GUI_NewField("CraftingTool","Craftsmanship","craftsmanship", "Crafting")
	GUI_NewField("CraftingTool","Control","control", "Crafting")
	GUI_NewField("CraftingTool","Steps To Finish","stepsLeft", "Crafting")
	GUI_NewField("CraftingTool","Last Skill Used","lSkill", "Crafting")
	GUI_NewField("CraftingTool","Crafting","cCraft", "Crafting")
	GUI_NewField("CraftingTool","CraftLog Open","clOpen", "Crafting")
	GUI_NewField("CraftingTool"," ","emptyVar", "Crafting")
	GUI_NewButton("CraftingTool", "Start\\Stop", "CraftingTool.Craft","Crafting") 
	RegisterEventHandler("CraftingTool.Craft", CraftingTool.Craft)
	--Skills
	--DO NOT OPEN
	GUI_NewField("CraftingTool", "Artifact Fix", "artfixvar","Fix")
	--Win Size
	GUI_SizeWindow("CraftingTool",300,200)
	
	Initialise()
	--Init Values
	
	gCraftProf_listitems = ""
	d("<< Proffesions Initialised >>")
	for i,e in pairs(CraftingTool.cLookUpProf) do
		if(e.init) then
			gCraftProf_listitems = gCraftProf_listitems..","..i
		end
		d(i .. " init: " .. tostring(e.init))
	end
	d("<< Proffesions End >>")
	
	if (Settings.CraftingTool.gCraftProf == nil) then
		Settings.CraftingTool.gCraftProf = "WVR"
	end
	gCraftProf = Settings.CraftingTool.gCraftProf
	
	GUIUpdate()
	
	if (Settings.CraftingTool.useProgress == nil) then
		Settings.CraftingTool.useProgress = "1"
	end
	useProgress = Settings.CraftingTool.useProgress
	
	if (Settings.CraftingTool.useQuality == nil) then
		Settings.CraftingTool.useQuality = "0"
	end
	useQuality = Settings.CraftingTool.useQuality
	
	if (Settings.CraftingTool.useDurability == nil) then
		Settings.CraftingTool.useDurability = "0"
	end
	useDurability = Settings.CraftingTool.useDurability
	
	if (Settings.CraftingTool.useBuff == nil) then
		Settings.CraftingTool.useBuff = "0"
	end
	useBuff = Settings.CraftingTool.useBuff
	
	if (Settings.CraftingTool.useSkip == nil) then
		Settings.CraftingTool.useSkip = "0"
	end
	useSkip = Settings.CraftingTool.useSkip
end

function Initialise()
	local localLookUp = {
		["WVR"] = {
			["100060"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "100", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Basic Synthesis", ["level"] = "1", ["cost"] = "0", ["CC"]=false },
			["100061"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "100", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Basic Touch", ["level"] = "5", ["cost"] = "18", ["CC"]=false },
			["100062"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "30", ["chance"] = "30", ["buffid"] = "0", ["name"] = "Master's Mend", ["level"] = "7", ["cost"] = "92", ["CC"]=false },
			["248"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "253", ["name"] = "Steady Hand", ["level"] = "9", ["cost"] = "22", ["CC"]=false },
			["256"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "251", ["name"] = "Inner Quiet", ["level"] = "11", ["cost"] = "18", ["CC"]=false },
			["100070"] = { ["actionType"] = CraftingTool.actionType["4"], ["efficiency"] = "1", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Observe", ["level"] = "13", ["cost"] = "14", ["CC"]=false },
			["100063"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "90", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Careful Synthesis", ["level"] = "15", ["cost"] = "0", ["CC"]=true },
			["100064"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "125", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Standard Touch", ["level"] = "18", ["cost"] = "32", ["CC"]=false },
			["264"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "200", ["chance"] = "0", ["buffid"] = "254", ["name"] = "Great Strides", ["level"] = "21", ["cost"] = "32", ["CC"]=false },
			["100065"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "60", ["chance"] = "60", ["buffid"] = "0", ["name"] = "Master's Mend II", ["level"] = "25", ["cost"] = "160", ["CC"]=false },
			["100067"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Standard Synthesis", ["level"] = "31", ["cost"] = "15", ["CC"]=false },
			["100066"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "200", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Brand of Lightning", ["level"] = "37", ["cost"] = "15", ["CC"]=false },
			["100068"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Advanced Touch", ["level"] = "43", ["cost"] = "48", ["CC"]=false },
			["100069"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "120", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Careful Synthesis II", ["level"] = "50", ["cost"] = "0", ["CC"]=true  }
		},
		["CUL"] = {
             ["100105"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "100", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Basic Synthesis", ["level"] = "1", ["cost"] = "0", ["CC"]=false },
             ["100106"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "100", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Basic Touch", ["level"] = "5", ["cost"] = "18", ["CC"]=false },
             ["100107"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "30", ["chance"] = "30", ["buffid"] = "0", ["name"] = "Master's Mend", ["level"] = "7", ["cost"] = "92", ["CC"]=false },
             ["251"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "253", ["name"] = "Steady Hand", ["level"] = "9", ["cost"] = "22", ["CC"]=false },
             ["259"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "251", ["name"] = "Inner Quiet", ["level"] = "11", ["cost"] = "18", ["CC"]=false },
             ["100113"] = { ["actionType"] = CraftingTool.actionType["4"], ["efficiency"] = "1", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Observe", ["level"] = "13", ["cost"] = "14", ["CC"]=false },
             ["100108"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "100", ["chance"] = "50", ["buffid"] = "0", ["name"] = "Hasty Touch", ["level"] = "15", ["cost"] = "0", ["CC"]=true },
             ["100109"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "125", ["chance"] = "80", ["buffid"] = "0", ["name"] = "Standard Touch", ["level"] = "18", ["cost"] = "32", ["CC"]=false },
             ["267"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "200", ["chance"] = "0", ["buffid"] = "254", ["name"] = "Great Strides", ["level"] = "21", ["cost"] = "32", ["CC"]=false },
             ["100110"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "60", ["chance"] = "60", ["buffid"] = "0", ["name"] = "Master's Mend II", ["level"] = "25", ["cost"] = "160", ["CC"]=false },
             ["100111"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Standard Synthesis", ["level"] = "31", ["cost"] = "15", ["CC"]=false },
             ["281"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "262", ["name"] = "Steady Hand II", ["level"] = "37", ["cost"] = "25", ["CC"]=true },
             ["100112"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Advanced Touch", ["level"] = "43", ["cost"] = "48", ["CC"]=false },
             ["287"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "90", ["buffid"] = "260", ["name"] = "Reclaim", ["level"] = "50", ["cost"] = "55", ["CC"]=true  }
         },
		["ALC"] = {
            ["100090"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "100", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Basic Synthesis", ["level"] = "1", ["cost"] = "0", ["CC"]=false },
            ["100091"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "100", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Basic Touch", ["level"] = "5", ["cost"] = "18", ["CC"]=false },
            ["100092"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "30", ["chance"] = "30", ["buffid"] = "0", ["name"] = "Master's Mend", ["level"] = "7", ["cost"] = "92", ["CC"]=false },
            ["250"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "253", ["name"] = "Steady Hand", ["level"] = "9", ["cost"] = "22", ["CC"]=false },
            ["258"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "251", ["name"] = "Inner Quiet", ["level"] = "11", ["cost"] = "18", ["CC"]=false },
            ["100099"] = { ["actionType"] = CraftingTool.actionType["4"], ["efficiency"] = "1", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Observe", ["level"] = "13", ["cost"] = "14", ["CC"]=false },
            ["100098"] = { ["actionType"] = CraftingTool.actionType["4"], ["efficiency"] = "20", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Tricks Of The Trade", ["level"] = "15", ["cost"] = "0", ["CC"]=true },
            ["100093"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "125", ["chance"] = "80", ["buffid"] = "0", ["name"] = "Standard Touch", ["level"] = "18", ["cost"] = "32", ["CC"]=false },
            ["266"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "200", ["chance"] = "0", ["buffid"] = "254", ["name"] = "Great Strides", ["level"] = "21", ["cost"] = "0", ["CC"]=false },
            ["100094"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "60", ["chance"] = "60", ["buffid"] = "0", ["name"] = "Master's Mend II", ["level"] = "25", ["cost"] = "160", ["CC"]=false },
            ["100096"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Standard Synthesis", ["level"] = "31", ["cost"] = "15", ["CC"]=false },
            ["100095"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "200", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Brand of Water", ["level"] = "37", ["cost"] = "15", ["CC"]=false },
            ["100097"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Advanced Touch", ["level"] = "43", ["cost"] = "48", ["CC"]=false },
            ["286"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "261", ["name"] = "Comfort Zone", ["level"] = "50", ["cost"] = "66", ["CC"]=true  }
        },
		["ARM"] = {
            ["100030"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "100", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Basic Synthesis", ["level"] = "1", ["cost"] = "0", ["CC"]=false },
            ["100031"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "100", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Basic Touch", ["level"] = "5", ["cost"] = "18", ["CC"]=false },
            ["100032"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "30", ["chance"] = "30", ["buffid"] = "0", ["name"] = "Master's Mend", ["level"] = "7", ["cost"] = "92", ["CC"]=false },
            ["246"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "253", ["name"] = "Steady Hand", ["level"] = "9", ["cost"] = "22", ["CC"]=false },
            ["254"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "251", ["name"] = "Inner-Quiet", ["level"] = "11", ["cost"] = "18", ["CC"]=false },
            ["100040"] = { ["actionType"] = CraftingTool.actionType["4"], ["efficiency"] = "1", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Observe", ["level"] = "13", ["cost"] = "14", ["CC"]=false },
            ["100033"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "250", ["chance"] = "50", ["buffid"] = "0", ["name"] = "Rapid Synthesis", ["level"] = "15", ["cost"] = "0", ["CC"]=true },
            ["100034"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "125", ["chance"] = "80", ["buffid"] = "0", ["name"] = "Standard Touch", ["level"] = "18", ["cost"] = "32", ["CC"]=false },
            ["262"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "200", ["chance"] = "0", ["buffid"] = "254", ["name"] = "Great Strides", ["level"] = "21", ["cost"] = "0", ["CC"]=false },
            ["100035"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "60", ["chance"] = "60", ["buffid"] = "0", ["name"] = "Master's Mend II", ["level"] = "25", ["cost"] = "160", ["CC"]=false },
            ["100037"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Standard Synthesis", ["level"] = "31", ["cost"] = "15", ["CC"]=false },
            ["100036"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "200", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Brand of Ice", ["level"] = "37", ["cost"] = "15", ["CC"]=false },
            ["100038"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Advanced Touch", ["level"] = "43", ["cost"] = "48", ["CC"]=false },
            ["100039"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "0", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Piece By Piece", ["level"] = "50", ["cost"] = "15", ["CC"]=true  }
        },
		["BSM"] = {
            ["100015"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "100", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Basic Synthesis", ["level"] = "1", ["cost"] = "0", ["CC"]=false },
            ["100016"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "100", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Basic Touch", ["level"] = "5", ["cost"] = "18", ["CC"]=false },
            ["100017"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "30", ["chance"] = "30", ["buffid"] = "0", ["name"] = "Master's Mend", ["level"] = "7", ["cost"] = "92", ["CC"]=false },
            ["245"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "253", ["name"] = "Steady Hand", ["level"] = "9", ["cost"] = "22", ["CC"]=false },
            ["253"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "251", ["name"] = "Inner-Quiet", ["level"] = "11", ["cost"] = "18", ["CC"]=false },
            ["100023"] = { ["actionType"] = CraftingTool.actionType["4"], ["efficiency"] = "1", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Observe", ["level"] = "13", ["cost"] = "14", ["CC"]=false },
            ["277"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "255", ["name"] = "Ingenuity", ["level"] = "15", ["cost"] = "24", ["CC"]=true },
            ["100018"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "125", ["chance"] = "80", ["buffid"] = "0", ["name"] = "Standard Touch", ["level"] = "18", ["cost"] = "32", ["CC"]=false },
            ["261"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "200", ["chance"] = "0", ["buffid"] = "254", ["name"] = "Great Strides", ["level"] = "21", ["cost"] = "0", ["CC"]=false },
            ["100019"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "60", ["chance"] = "60", ["buffid"] = "0", ["name"] = "Master's Mend II", ["level"] = "25", ["cost"] = "160", ["CC"]=false },
            ["100021"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Standard Synthesis", ["level"] = "31", ["cost"] = "15", ["CC"]=false },
            ["100020"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "200", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Brand of Fire", ["level"] = "37", ["cost"] = "15", ["CC"]=false },
            ["100022"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Advanced Touch", ["level"] = "43", ["cost"] = "48", ["CC"]=false },
            ["283"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "256", ["name"] = "Ingenuity II", ["level"] = "50", ["cost"] = "32", ["CC"]=true  }
        },
		["GSM"] = {
            ["100075"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "100", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Basic Synthesis", ["level"] = "1", ["cost"] = "0", ["CC"]=false },
            ["100076"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "100", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Basic Touch", ["level"] = "5", ["cost"] = "18", ["CC"]=false },
            ["100077"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "30", ["chance"] = "30", ["buffid"] = "0", ["name"] = "Master's Mend", ["level"] = "7", ["cost"] = "92", ["CC"]=false },
            ["247"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "253", ["name"] = "Steady Hand", ["level"] = "9", ["cost"] = "22", ["CC"]=false },
            ["255"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "251", ["name"] = "Inner-Quiet", ["level"] = "11", ["cost"] = "18", ["CC"]=false },
            ["100082"] = { ["actionType"] = CraftingTool.actionType["4"], ["efficiency"] = "1", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Observe", ["level"] = "13", ["cost"] = "14", ["CC"]=false },
            ["278"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "30", ["chance"] = "0", ["buffid"] = "258", ["name"] = "Manipulation", ["level"] = "15", ["cost"] = "88", ["CC"]=true },
            ["100078"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "125", ["chance"] = "80", ["buffid"] = "0", ["name"] = "Standard Touch", ["level"] = "18", ["cost"] = "32", ["CC"]=false },
            ["263"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "200", ["chance"] = "0", ["buffid"] = "254", ["name"] = "Great Strides", ["level"] = "21", ["cost"] = "0", ["CC"]=false },
            ["100079"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "60", ["chance"] = "60", ["buffid"] = "0", ["name"] = "Master's Mend II", ["level"] = "25", ["cost"] = "160", ["CC"]=false },
            ["100080"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Standard Synthesis", ["level"] = "31", ["cost"] = "15", ["CC"]=false },
            ["100083"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "0", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Flawless Synthesis", ["level"] = "37", ["cost"] = "15", ["CC"]=true },
            ["100081"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Advanced Touch", ["level"] = "43", ["cost"] = "48", ["CC"]=false },
            ["284"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "50", ["chance"] = "0", ["buffid"] = "259", ["name"] = "Innovation", ["level"] = "50", ["cost"] = "18", ["CC"]=true  }
        },
		["LTW"] = {
            ["100045"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "100", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Basic Synthesis", ["level"] = "1", ["cost"] = "0", ["CC"]=false },
            ["100046"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "100", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Basic Touch", ["level"] = "5", ["cost"] = "18", ["CC"]=false },
            ["100047"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "30", ["chance"] = "30", ["buffid"] = "0", ["name"] = "Master's Mend", ["level"] = "7", ["cost"] = "92", ["CC"]=false },
            ["249"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "253", ["name"] = "Steady Hand", ["level"] = "9", ["cost"] = "22", ["CC"]=false },
            ["257"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "251", ["name"] = "Inner-Quiet", ["level"] = "11", ["cost"] = "18", ["CC"]=false },
            ["100053"] = { ["actionType"] = CraftingTool.actionType["4"], ["efficiency"] = "1", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Observe", ["level"] = "13", ["cost"] = "14", ["CC"]=false },
            ["279"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "100", ["buffid"] = "252", ["name"] = "Waste Not", ["level"] = "15", ["cost"] = "56", ["CC"]=true },
            ["100048"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "125", ["chance"] = "80", ["buffid"] = "0", ["name"] = "Standard Touch", ["level"] = "18", ["cost"] = "32", ["CC"]=false },
            ["265"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "200", ["chance"] = "90", ["buffid"] = "254", ["name"] = "Great Strides", ["level"] = "21", ["cost"] = "32", ["CC"]=false },
            ["100049"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "60", ["chance"] = "60", ["buffid"] = "0", ["name"] = "Master's Mend II", ["level"] = "25", ["cost"] = "160", ["CC"]=false },
            ["100051"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Standard Synthesis", ["level"] = "31", ["cost"] = "15", ["CC"]=false },
            ["100050"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "200", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Brand Of Earth", ["level"] = "37", ["cost"] = "15", ["CC"]=false },
            ["100052"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Advanced Touch", ["level"] = "43", ["cost"] = "48", ["CC"]=false },
            ["285"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "90", ["buffid"] = "257", ["name"] = "Waste Not II", ["level"] = "50", ["cost"] = "98", ["CC"]=true  }
        },
		["CRP"] = {
            ["100001"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "100", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Basic Synthesis", ["level"] = "1", ["cost"] = "0", ["CC"]=false },
            ["100002"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "100", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Basic Touch", ["level"] = "5", ["cost"] = "18", ["CC"]=false },
            ["100003"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "30", ["chance"] = "30", ["buffid"] = "0", ["name"] = "Master's Mend", ["level"] = "7", ["cost"] = "92", ["CC"]=false },
            ["244"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "253", ["name"] = "Steady Hand", ["level"] = "9", ["cost"] = "22", ["CC"]=false },
            ["252"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "0", ["chance"] = "0", ["buffid"] = "251", ["name"] = "Inner-Quiet", ["level"] = "11", ["cost"] = "18", ["CC"]=false },
            ["100010"] = { ["actionType"] = CraftingTool.actionType["4"], ["efficiency"] = "1", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Observe", ["level"] = "13", ["cost"] = "14", ["CC"]=false },
            ["276"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "100", ["chance"] = "100", ["buffid"] = "276", ["name"] = "Rumination", ["level"] = "15", ["cost"] = "0", ["CC"]=true },
            ["100004"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "125", ["chance"] = "80", ["buffid"] = "0", ["name"] = "Standard Touch", ["level"] = "18", ["cost"] = "32", ["CC"]=false },
            ["260"] = { ["actionType"] = CraftingTool.actionType["3"], ["efficiency"] = "200", ["chance"] = "90", ["buffid"] = "254", ["name"] = "Great Strides", ["level"] = "21", ["cost"] = "32", ["CC"]=false },
            ["100005"] = { ["actionType"] = CraftingTool.actionType["2"], ["efficiency"] = "60", ["chance"] = "60", ["buffid"] = "0", ["name"] = "Master's Mend II", ["level"] = "25", ["cost"] = "160", ["CC"]=false },
            ["100007"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Standard Synthesis", ["level"] = "31", ["cost"] = "15", ["CC"]=false },
            ["100006"] = { ["actionType"] = CraftingTool.actionType["0"], ["efficiency"] = "200", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Brand Of Wind", ["level"] = "37", ["cost"] = "15", ["CC"]=false },
            ["100008"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "150", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Advanced Touch", ["level"] = "43", ["cost"] = "48", ["CC"]=false },
            ["100009"] = { ["actionType"] = CraftingTool.actionType["1"], ["efficiency"] = "100", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Byregot's Blessing", ["level"] = "50", ["cost"] = "24", ["CC"]=true  }
        }
	}
	
	for z=8,15 do
		local theProf = getProf(z)
		CraftingTool.Skills[theProf] = {}
		CraftingTool.Buffs[theProf] = {}
	end
	
	local ccindex = 0
	for z=8,15 do
		local skilllist = ActionList("type=1,job="..z)
		local theProf = getProf(z)
		d("<< Trying to init " .. theProf .. " >>")
		local index = 0
		if(localLookUp[theProf]) then
			local i,e = next (localLookUp[theProf])
			while ( i and e ) do
				local sName = "S" .. index
				CraftingTool.Skills[theProf][sName] = {}
				local found = false
				
				local skill = skilllist[tonumber(i)]
				if(skill) then
					CraftingTool.Skills[theProf][sName] = {
					["id"] = tonumber(skill.id),
					["name"] = skill.name, 
					["cost"] = tonumber(skill.cost), 
					["level"] = tonumber(skill.level),
					["actionType"] = e.actionType,
					["efficiency"] = "100", ["chance"] = tonumber(e.chance),
					["buffid"] = tonumber(e.buffid),
					["CC"] = e.CC
					}
					found = true
				else
					CraftingTool.Skills[theProf][sName] = {
					["id"] = tonumber(i),
					["name"] = e.name, 
					["cost"] = tonumber(e.cost), 
					["level"] = tonumber(e.level),
					["actionType"] = e.actionType,
					["efficiency"] = "100", ["chance"] = tonumber(e.chance),
					["buffid"] = tonumber(e.buffid),
					["CC"] = e.CC
					}
				end
				d("SKILL => " .. sName .. " -> " .. " ID: " .. i .. " Name:" .. e.name .. " Cost:" .. e.cost .. " Level:" .. e.level .. " Type:" .. e.actionType .. " Chance:" .. e.chance .. " BuffID:" .. e.buffid .. " -> F:" .. tostring(found))
				
				if(e.CC) then
					local aTo = ""
					for h=8,15 do
						local theCCProf = getProf(h)
						if(theCCProf ~= theProf) then
							CraftingTool.Skills[theCCProf]["CC"..ccindex] = CraftingTool.Skills[theProf][sName]
							if(e.actionType == CraftingTool.actionType["3"]) then
								CraftingTool.Buffs[theCCProf]["CC"..ccindex] = { ["id"] = tonumber(e.buffid), ["length"] = 0 }
							end
							aTo = aTo .. theCCProf .. " "
						end
					end
					ccindex = ccindex + 1
					d("SKILL => IS CC"..ccindex .. " In: " .. aTo)
				end
				
				if(e.actionType == CraftingTool.actionType["3"]) then
					CraftingTool.Buffs[theProf][sName] = { ["id"] = tonumber(e.buffid), ["length"] = 0 }
					d("BUFF => " .. CraftingTool.Buffs[theProf][sName].id .. " " .. CraftingTool.Buffs[theProf][sName].length)
				end
				
				index = index + 1
				i,e = next (localLookUp[theProf],i)
			end
			d("<< " .. theProf ..  " init successfully >>")
			CraftingTool.cLookUpProf[theProf].init = true
		else
			d("No skill list found for " .. theProf)
			d("<< ".. theProf .. " init failed >>")
		end
	end
	--[[Test--
	for i,e in pairs(CraftingTool.Skills) do
		if(CraftingTool.cLookUpProf[i].init) then
			d("Profession: " .. i)
			for s,k in pairs(e) do
				d("Skill Handle: " .. s .. " Skill Name: " .. k.name) 
			end
			d("Buffs: " .. i)
			for s,k in pairs(CraftingTool.Buffs[i]) do
				d("Buff Handle: " .. s .. " ID: " .. k.id) 
			end
		end
	end
	--End Test]]--
end

function getProf(id)
	local localLookUp = {["8"] = "CRP",["9"] = "BSM",["10"] = "ARM",["11"] = "GSM",["12"] = "LTW",["13"] = "WVR",["14"] = "ALC",["15"] = "CUL"}
	return localLookUp[tostring(id)]
end

function CraftingTool.Craft( dir )
	CraftingTool.doCraft = not CraftingTool.doCraft
end

function CraftingTool.GUIVARUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if(k == "gCraftProf") then
			GUIUpdate()
		else
			Settings.CraftingTool[tostring(k)] = v
		end
	end
	GUI_RefreshWindow("CraftingTool")
end

function GUIUpdate()
	Settings.CraftingTool["gCraftProf"] = gCraftProf
	
	for i,k in pairs(CraftingTool.actionType) do
		GUI_DeleteGroup("CraftingTool", k.." Skills")
		GUI_NewCheckbox("CraftingTool","Use "..k,"use"..k, k.." Skills")
		GUI_NewField("CraftingTool"," ","emptyVar", k.." Skills")
	end
	GUI_DeleteGroup("CraftingTool","Cross Class Skills")
	GUI_UnFoldGroup("CraftingTool","Cross Class Skills")	
	GUI_DeleteGroup("CraftingTool","Fix")
	d("<< Trying to load "..gCraftProf.." >>")
	if(CraftingTool.cLookUpProf[gCraftProf]) then
		for i,skill in pairs(CraftingTool.Skills[gCraftProf]) do
			if(skill) then
				if(string.match(i, "CC.") ~= nil) then
					GUI_NewCheckbox("CraftingTool",skill.name, gCraftProf.."."..i , "Cross Class Skills")
				else
					GUI_NewCheckbox("CraftingTool",skill.name, gCraftProf.."."..i , skill.actionType .. " Skills")
				end
				if(Settings.CraftingTool[gCraftProf.."."..i] == nil) then
					Settings.CraftingTool[gCraftProf.."."..i] = "0"
				else
					_G[gCraftProf .."."..i] = Settings.CraftingTool[gCraftProf.."."..i]
				end
				d("Name: " .. skill.name) -- .. " Handle: " .. gCraftProf.."."..i)
			end
		end
	end
	d("<< Loaded "..gCraftProf.." >>")
	for i,k in pairs(CraftingTool.actionType) do
		GUI_UnFoldGroup("CraftingTool", k.." Skills")
	end
	GUI_NewField("CraftingTool", "Artifact Fix", "artfixvar","Fix")
end

function CraftingTool.Update(Event, ticks)
	cCraft = tostring(CraftingTool.doCraft)
	clOpen = tostring(Crafting:IsCraftingLogOpen())
	
	if(CraftingTool.doCraft) then
		if(ticks - CraftingTool.LastSkillUseTime > CraftingTool.WaitTime) then
			local synth = Crafting:SynthInfo()
			if(synth) then
				itemID = synth.itemid
				--If it's a different item then set this stuff to def and change the id of the item
				if(CraftingTool.prevItemId ~= synth.itemid) then
					CraftingTool.prevItemId = synth.itemid
					CraftingTool.ProgressGain = 0
					CraftingTool.QualityGain = 0
					CraftingTool.FirstUse = false
					CraftingTool.FirstUseLevel = 0
				end
				-- I could simply calculate this each step to make sure that it works, but it seems better to not.
				if (not CraftingTool.FirstUse or CraftingTool.FirstUseLevel ~= Player.level or CraftingTool.ProgressGain == 0 or CraftingTool.QualityGain == 0) then
					--d("Progress Prediction: ".. tostring(ProgressPrediction(tonumber(itemLevel), tonumber(craftsmanship))))
					--d("Quality Prediction: ".. tostring(QualityPrediction(tonumber(itemLevel), tonumber(control))))
					CraftingTool.ProgressGain = tonumber(ProgressPrediction(tonumber(itemLevel), tonumber(craftsmanship)))
					CraftingTool.QualityGain = tonumber(QualityPrediction(tonumber(itemLevel), tonumber(control)))
				end
				--if(not CraftingTool.FirstUse) then
				--	if(synth.progress > 0) then
				--		CraftingTool.ProgressGain = synth.progress
				--		CraftingTool.FirstUse = true
				--	end
				--end
				
				local skill = SelectSkill(synth)
				if(skill) then
					lSkill = skill.name
					UseSkill(skill)
				end
			else
				if (not Crafting:IsCraftingLogOpen()) then
					Crafting:ToggleCraftingLog()
				elseif(Crafting:CanCraftSelectedItem()) then
					d("<< Crafting Item >>")
					Crafting:CraftSelectedItem()
					Crafting:ToggleCraftingLog()
					for i,k in pairs(CraftingTool.Buffs[gCraftProf]) do
						k.length = 0
					end
					CraftingTool.WaitTime = 3500
				end
			end
			CraftingTool.LastSkillUseTime = ticks
		end
	end
end

function SelectStepType(synth)
	local progress = synth.progress
	local progressmax = synth.progressmax
	local quality = synth.quality
	local qualitymax = synth.qualitymax
	local durability = synth.durability
	local description = synth.description
	local playerLevel = Player.level
	local playerCP = Player.cp.current
	local playerCPMax = Player.cp.max
	
	local stepsToFinish = tonumber(StepsToFinish((progressmax - progress)))
	stepsLeft = tostring(stepsToFinish)
	if(description == "Good" and playerCPMax - playerCP > 17 and useSkip == "1") then
		return CraftingTool.actionType["4"] --Skip (tricks)
	elseif((not CraftingTool.FirstUse or description == "Poor") and stepsToFinish ~= 1) then
		return CraftingTool.actionType["0"] --Craft
	elseif(durability == 10 and playerCP > 91 and useDurability == "1") then
		return CraftingTool.actionType["2"] --Durability
	elseif(durability == stepsToFinish * 10) then
		return CraftingTool.actionType["0"] --Craft
	elseif(durability > 10 and (description == "Excellent" or description == "Good") and playerCP > 17 and useQuality == "1") then
		return CraftingTool.actionType["1"] --Quality
	elseif(NeedToRecastBuffs() and playerCP > 24 and useBuff == "1") then
		return CraftingTool.actionType["3"] --Buffs
	else
		if(durability > 10 and useQuality == "1" and qualitymax - quality ~= 0) then
			return CraftingTool.actionType["1"] --Quality 
		else
			return CraftingTool.actionType["0"] --Craft
		end
	end
end

function NeedToRecastBuffs()
	local needtorecast = false
	for i,k in pairs(CraftingTool.Buffs[gCraftProf]) do
		d("Checking Buff: " ..k.id)
		if(not IfPlayerHasBuff(k.id)) then
			d("Buff not Active " ..gCraftProf .."."..i)
			if(_G[gCraftProf .."."..i] == "1") then
				if(Player.cp.current >= CraftingTool.Skills[gCraftProf][i].cost) then
					needtorecast = true
					break
				end
			end
		end
	end
	return needtorecast
end

function SelectSkill(synth)
	local playerLevel = Player.level
	local playerCP = Player.cp.current
	
	local stepType = SelectStepType(synth)
	
	local skillList = CraftingTool.Skills[gCraftProf]
	local bestSkill = nil
	if(skillList) then
		--d("Skill List Live")
		for i,k in pairs(CraftingTool.Skills[gCraftProf]) do
			local skillHandle = gCraftProf .."."..i
			if(Settings.CraftingTool[skillHandle] == "1") then
				--d("Pass " .. i .. " Current Best: " .. ((bestSkill == nil) and "nil" or bestSkill.name))
				if(k) then
					if(k.actionType == stepType) then 
						if((k.level <= playerLevel or string.match(i,"CC.") ~= nil) and playerCP >= k.cost) then
							--d("Checking against " .. k.name)
							if(stepType == CraftingTool.actionType["0"]) then
								if(bestSkill ~= nil) then
									if((k.chance >= bestSkill.chance or k.efficiency >= bestSkill.efficiency)) then
										bestSkill = k
									end
								else
									bestSkill = k
								end
							elseif(stepType == CraftingTool.actionType["1"]) then
								if(bestSkill ~= nil) then
									if (synth.description == "Excellent" or synth.description == "Good") then
										if(k.cost <= playerCP and k.efficiency >= bestSkill.efficiency and k.cost ~= 0) then
											bestSkill = k
										end
									elseif(k.cost == 0) then
										bestSkill = k
									end
								else
									bestSkill = k
								end
							elseif(stepType == CraftingTool.actionType["2"]) then
								if(synth.durabilitymax - synth.durability > 50) then
									if(k.chance > 50) then bestSkill = k end
								else
									if(k.chance < 50) then bestSkill = k end
								end
								if(bestSkill == nil) then
										bestSkill = k
								end
							elseif(stepType == CraftingTool.actionType["3"]) then
								if(not IfPlayerHasBuff(k.buffid) and k.cost <= playerCP) then
									bestSkill = k
								end
								if(bestSkill == nil) then
										bestSkill = k
								end
							elseif(stepType == CraftingTool.actionType["4"]) then
								if (k.id == 100098) then -- this is hackish, need to make it better (but who uses observe?)
									bestSkill = k
								end
								if(bestSkill == nil) then
										bestSkill = k
								end
							end
						end
					end
				end
			end
		end
	end
	d("STEP=>" .. stepType .. " SKILL=>" .. bestSkill.name)
	return bestSkill
end

function IfPlayerHasBuff(buffid)
	local buffs = Player.buffs
	local i,e = next (buffs)
	local haveBuff = false
	while ( i and e ) do
		if ( e.id == buffid ) then
			haveBuff = true
			break
		end
		i,e = next (buffs,i)
	end	
	return haveBuff
end

function UseSkill(Skill)
	for i,k in pairs(CraftingTool.Buffs[gCraftProf]) do
		k.length = ((k.length - 1 >= 0) and k.length - 1 or 0)
	end
	CraftingTool.WaitTime = 3000
	ActionList:Cast(Skill.id,0)
end

function StepsToFinish(Left)
	local steps = 0
	
	while(Left > 0 and CraftingTool.ProgressGain > 0) do
		Left = Left - CraftingTool.ProgressGain
		steps = steps + 1
	end
	
	return steps
end

-- formula based on http://www.bluegartr.com/threads/117684-The-crafting-thread.?p=5890541&viewfull=1#post5890541
-- needs testing for large differences ( > 15 && < -5)
function ProgressPrediction(level, ship)
	local diff = Player.level - level
	local corr = 1.55 -- cap is about 55%
	
	if ( diff <= 0 ) then -- this may not be correct for * and ** items
		corr = 1 + (0.10 * diff)
	elseif ( diff > 0 and diff <= 5 ) then
		corr = 1 + (0.05 * diff)
	elseif ( diff > 5 and diff <= 15 ) then
		corr = 1 + (0.022 * diff) + 0.15
	elseif ( diff > 15 and diff <= 25 ) then
		corr = 1 + (0.007 * diff) + 0.375 -- assuming linear, won't matter much because mostly 1-hit completions
	end
	
	return corr * ((0.21 * ship) + 1.6)
end

-- formula based on http://www.bluegartr.com/threads/117684-The-crafting-thread.
function QualityPrediction(level, cont)
	local diff = Player.level - level
	local corr = 1 -- no bonus for synths under your level
	
	if ( diff < 0 ) then -- is this appropriate for ** items?
		corr = 1 + (0.05 * diff)
	end
	
	return corr * ((0.36 * cont) + 34)
end

--register our function
RegisterEventHandler("Gameloop.Update", CraftingTool.Update) -- the normal pulse from the gameloop
RegisterEventHandler("Module.Initalize", CraftingTool.ModuleInit)
RegisterEventHandler("GUI.Update", CraftingTool.GUIVARUpdate)
