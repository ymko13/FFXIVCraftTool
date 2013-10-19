-- Create a new table for our code:
CraftingTool={ }

--some variables
CraftingTool.doCraft = false

CraftingTool.LastSkillUseTime = 0
CraftingTool.WaitTime = 3000

CraftingTool.prevItemId = 0
CraftingTool.ProgressGain = 0
CraftingTool.BuffTime = 0

CraftingTool.FirstUse = false

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

-- Initializing function, we create a new Window for our module that has 1 button and 1 field to display data:
function CraftingTool.ModuleInit()
	GUI_NewWindow("CraftingTool",600,200,300,200)
	--Crafting proffesion
	GUI_NewComboBox("CraftingTool","Profession","gCraftProf", "Profession Selection", "None")
	GUI_UnFoldGroup("CraftingTool","Profession Selection")
	--Crafting
	GUI_NewField("CraftingTool","Item ID","itemID", "Crafting")
	GUI_NewField("CraftingTool","Steps To Finish","stepsLeft", "Crafting")
	GUI_NewField("CraftingTool","Last Skill Used","lSkill", "Crafting")
	GUI_NewField("CraftingTool","Crafting","cCraft", "Crafting")
	GUI_NewField("CraftingTool","CraftLog Open","clOpen", "Crafting")
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
	for i,e in pairs(CraftingTool.cLookUpProf) do
		if(e.init) then
			gCraftProf_listitems = gCraftProf_listitems..","..i
		end
		d(i .. " init: " .. tostring(e.init))
	end
	
	if (Settings.CraftingTool.gCraftProf == nil) then
		Settings.CraftingTool.gCraftProf = "WVR"
	end
	gCraftProf = Settings.CraftingTool.gCraftProf
	
	
end

function Initialise()
	local localLookUp = {
		["WVR"] = {
			["100060"] = { ["actionType"] = "Progress", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Basic Synthesis", ["level"] = "1", ["cost"] = "0" },
			["100061"] = { ["actionType"] = "Quality", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Basic Touch", ["level"] = "5", ["cost"] = "18"  },
			["100062"] = { ["actionType"] = "Durability", ["chance"] = "30", ["buffid"] = "0", ["name"] = "Master's Mend", ["level"] = "7", ["cost"] = "92"  },
			["248"] = { ["actionType"] = "Buff", ["chance"] = "0", ["buffid"] = "253", ["name"] = "Steady Hand", ["level"] = "9", ["cost"] = "22"  },
			["256"] = { ["actionType"] = "Buff", ["chance"] = "0", ["buffid"] = "251", ["name"] = "Inner-Quiet", ["level"] = "11", ["cost"] = "18"  },
			["100070"] = { ["actionType"] = "Skip", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Observe", ["level"] = "13", ["cost"] = "14"  },
			["100063"] = { ["actionType"] = "Progress", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Careful Synthesis", ["level"] = "15", ["cost"] = "0"  },
			["100064"] = { ["actionType"] = "Quality", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Standard Touch", ["level"] = "18", ["cost"] = "32"  },
			["264"] = { ["actionType"] = "Buff", ["chance"] = "90", ["buffid"] = "254", ["name"] = "Great Strides", ["level"] = "21", ["cost"] = "32"  },
			["100065"] = { ["actionType"] = "Durability", ["chance"] = "60", ["buffid"] = "0", ["name"] = "Master's Mend II", ["level"] = "25", ["cost"] = "160"  },
			["100067"] = { ["actionType"] = "Progress", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Standard Synthesis", ["level"] = "31", ["cost"] = "15"  },
			["100066"] = { ["actionType"] = "Progress", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Brand of Lightning", ["level"] = "37", ["cost"] = "15"  },
			["100068"] = { ["actionType"] = "Quality", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Advanced Touch", ["level"] = "43", ["cost"] = "48"  },
			["100069"] = { ["actionType"] = "Progress", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Careful Synthesis II", ["level"] = "50", ["cost"] = "0"  }
		}
	}
	for z=8,15 do
		local skilllist = ActionList("type=1,job="..z)
		local theProf = getProf(z)
		CraftingTool.Skills[theProf] = {}
		local index = 0
		if(localLookUp[theProf]) then
			local i,e = next (localLookUp[theProf])
			while ( i and e ) do
				local sName = "S" .. index
				CraftingTool.Skills.WVR[sName] = {}
				local found = false
				local skill = skilllist[tonumber(i)]
				if(skill) then
					CraftingTool.Skills.WVR[sName] = {
					["id"] = skill.id,
					["name"] = skill.name, 
					["cost"] = skill.cost, 
					["level"] = skill.level,
					["actionType"] = e.actionType,
					["chance"] = e.chance,
					["buffid"] = e.buffid
					}
					found = true
				else
					CraftingTool.Skills.WVR[sName] = {
					["id"] = i,
					["name"] = e.name, 
					["cost"] = e.cost, 
					["level"] = e.level,
					["actionType"] = e.actionType,
					["chance"] = e.chance,
					["buffid"] = e.buffid
					}
				end
				d( sName .. " -> " .. " ID: " .. i .. " Name:" .. e.name .. " Cost:" .. e.cost .. " Level:" .. e.level .. " Type:" .. e.actionType .. " Chance:" .. e.chance .. " BuffID:" .. e.buffid .. " -> F:" .. tostring(found))
				index = index + 1
				i,e = next (localLookUp[theProf],i)
			end
			d("Initialised the " .. theProf .. " profession")
			CraftingTool.cLookUpProf[theProf].init = true
		else
			d("No skill list found for " .. theProf)
		end
	end
end

function getProf(id)
	local localLookUp = {
		["8"] = "CRP",
		["9"] = "BSM",
		["10"] = "ARM",
		["11"] = "GSM",
		["12"] = "LTW",
		["13"] = "WVR",
		["14"] = "ALC",
		["15"] = "CUL"
	}
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
		GUI_DeleteGroup("CraftingTool", k.."Skills")
	end
	GUI_DeleteGroup("CraftingTool","Fix")	
	
	for i=0,13 do
		local skill = CraftingTool.Skills[gCraftProf]["S"..i]
		if(skill) then
			local skillHandle = gCraftProf.."-S"..skill
			GUI_NewCheckbox("CraftingTool",skill.name,skillHandle, skill.actionType .. "Skills")
			if(Settings.CraftingTool[skillHandle] == nil) then
				Settings.CraftingTool[skillHandle] = 0
			end
			d("Name: " .. skill.name .. " Handle: " .. skillHandle)
		end
	end
	
	for i,k in pairs(CraftingTool.actionType) do
		GUI_UnFoldGroup("CraftingTool", k.."Skills")
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
				if(prevItemId ~= synth.itemid) then
					CraftingTool.prevItemId = synth.itemid
					CraftingTool.ProgressGain = 0
					CraftingTool.FirstUse = false
				end
				if(CraftingTool.FirstUse) then
					
				end
				local skill = SelectSkill(synth)
				lSkill = skill.name
			else
				if (not Crafting:IsCraftingLogOpen()) then
					Crafting:ToggleCraftingLog()
				elseif(Crafting:CanCraftSelectedItem())
					Crafting:CraftSelectedItem()
					Crafting:ToggleCraftingLog()
					CraftingTool.BuffTime = 0
					CraftingTool.WaitTime = 3000
				end
			end
		end
	end
end

function SelectStepType(synth)
	local progress = synth.progress
	local progressmax = synth.progressmax
	local quality = synth.quality
	local qualitymax = synth.qualitymax
	local durability = synth.durablity
	local durabilitymax = synth.durablitymax
	local description = synth.description
	local playerLevel = Player.level
	local playerCP = Player.current.cp
	
	local stepsToFinish = StepsToFinish(progressmax - progress)
	
	if(not CraftingTool.FirstUse and stepsToFinish ~= 1) then
		return CraftingTool.actionType["0"] --Craft
	elseif(durability == 10 and playerCP > 91)
		return CraftingTool.actionType["2"] --Durability
	elseif(durability == stepsToFinish * 10)
		return CraftingTool.actionType["0"] --Craft
	elseif()
		
	end
end

function SelectSkill(synth)
	local stepType = SelectStepType(synth)
	
	
end

function StepsToFinish(Left)
	local steps = 0
	
	while(Left > 0 and CraftingTool.ProgressGain > 0) do
		Left = Left - CraftingTool.ProgressGain
		steps = steps + 1
	end
	
	return steps
end

--register our function
RegisterEventHandler("Gameloop.Update", CraftingTool.Update) -- the normal pulse from the gameloop
RegisterEventHandler("Module.Initalize", CraftingTool.ModuleInit)
RegisterEventHandler("GUI.Update", CraftingTool.GUIVARUpdate)