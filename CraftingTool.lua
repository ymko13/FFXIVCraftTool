-- Create a new table for our code:
CraftingTool={ }

--some variables
CraftingTool.doCraft = false

CraftingTool.LastSkillUseTime = 0
CraftingTool.WaitTime = 3000

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
	--Craft GUI gCraftProf
	GUI_NewField("CraftingTool","Profession","gCraftProf", "Crafting")
	GUI_NewField("CraftingTool","Item ID","itemID", "Crafting")
	GUI_NewField("CraftingTool","Steps To Finish","stepsLeft", "Crafting")
	GUI_NewField("CraftingTool","Crafting","cCraft", "Crafting")
	GUI_NewField("CraftingTool","CraftLog Open","clOpen", "Crafting")
	GUI_NewButton("CraftingTool", "Start\\Stop", "CraftingTool.Craft","Crafting") 
	RegisterEventHandler("CraftingTool.Craft", CraftingTool.Craft)
	
	--DO NOT OPEN
	GUI_NewField("CraftingTool", "Artifact Fix", "artfixvar","Don't open this(fix)")
	--Win Size
	GUI_SizeWindow("CraftingTool",300,200)
	
	Initialise()
	--Init Values
	
	if (Settings.CraftingTool.gCraftProf == nil) then
		Settings.CraftingTool.gCraftProf = "0"
	end
	gCraftProf = Settings.CraftingTool.gCraftProf
end

function Initialise()
	local localLookUp = {
		["WVR"] = {
			["100060"] = { ["actionType"] = "Progress", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Basic Synthesis", ["level"] = "1", ["cost"] = "0" },
			["100061"] = { ["actionType"] = "Quality", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Basic Touch", ["level"] = "1", ["cost"] = "0"  },
			["100062"] = { ["actionType"] = "Durability", ["chance"] = "30", ["buffid"] = "0", ["name"] = "Master's Mend", ["level"] = "1", ["cost"] = "0"  },
			["248"] = { ["actionType"] = "Buff", ["chance"] = "0", ["buffid"] = "253", ["name"] = "Steady Hand", ["level"] = "1", ["cost"] = "0"  },
			["256"] = { ["actionType"] = "Buff", ["chance"] = "0", ["buffid"] = "251", ["name"] = "Inner-Quiet", ["level"] = "1", ["cost"] = "0"  },
			["100070"] = { ["actionType"] = "Skip", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Observe", ["level"] = "1", ["cost"] = "0"  },
			["100063"] = { ["actionType"] = "Progress", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Careful Synthesis", ["level"] = "1", ["cost"] = "0"  },
			["100064"] = { ["actionType"] = "Quality", ["chance"] = "70", ["buffid"] = "0", ["name"] = "Standard Touch", ["level"] = "1", ["cost"] = "0"  },
			["264"] = { ["actionType"] = "Buff", ["chance"] = "90", ["buffid"] = "254", ["name"] = "Great Strides", ["level"] = "1", ["cost"] = "0"  },
			["100065"] = { ["actionType"] = "Durability", ["chance"] = "60", ["buffid"] = "0", ["name"] = "Master's Mend II", ["level"] = "1", ["cost"] = "0"  },
			["100067"] = { ["actionType"] = "Progress", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Standard Synthesis", ["level"] = "1", ["cost"] = "0"  },
			["100066"] = { ["actionType"] = "Progress", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Brand of Lightning", ["level"] = "1", ["cost"] = "0"  },
			["100068"] = { ["actionType"] = "Quality", ["chance"] = "90", ["buffid"] = "0", ["name"] = "Advanced Touch", ["level"] = "1", ["cost"] = "0"  },
			["100069"] = { ["actionType"] = "Progress", ["chance"] = "100", ["buffid"] = "0", ["name"] = "Careful Synthesis II", ["level"] = "1", ["cost"] = "0"  }
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

--[[

function CraftingTool.GUIVARUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if (k == "sCraft" or k == "hqCraft" or k == "Observe" or k == "oneStep")  then
			Settings.FFXIVMINION[tostring(k)] = v
		end
	end
	GUI_RefreshWindow("CraftingTool")
end

function CraftingTool.Update(Event, ticks)
	cCraft = tostring(CraftingTool.doCraft)
	clOpen = tostring(Crafting:IsCraftingLogOpen())
	
	if(not CraftingTool.Init) then
		CraftingTool.Init = true
		Initialise()
	end
	
	if(sCraft == "1" and hqCraft == "1") then --makes sure that you dont select both crafts
		sCraft = "0"
		hqCraft = "0"
	end
	
	if(CraftingTool.doCraft and (sCraft == "1" or hqCraft == "1")) then
		 --
		--d("" .. tostring(ticks - CraftingTool.LastSkillUseTime))
		if(ticks - CraftingTool.LastSkillUseTime > CraftingTool.WaitTime) then
			local synth = Crafting:SynthInfo()
			if ( synth ) then
				itemID = synth.itemid
				stepsLeft = tostring(StepsToFinish(synth.progressmax - synth.progress))
				--if Simple Craft only use Basic Synthesis
				--if HQ craft use Carefull Synthesis to determine the amount of turn needed
				--then use Great Strides then if Good or better use Standard Touch\Basic Touch if enough CP else Carefull Synthesis(used first to determine no of steps to finish)
				--When 1 step left to finish only use Great Strides + Standard Touch\BasicTouch.
				if(sCraft == "1") then
					if(not synth.progress == 0 and not CraftingTool.FirstUse and oneStep == "0") then
						CraftingTool.FirstUse = true
						CraftingTool.ProgressGain = synth.progress
					end
					MakeStep(NextStepID(synth))
				elseif(hqCraft == "1") then
					
				end
			else
				if (not Crafting:IsCraftingLogOpen()) then
					Crafting:ToggleCraftingLog()
				else
					Crafting:CraftSelectedItem()
					Crafting:ToggleCraftingLog()
					CraftingTool.ProgressGain = 0
					CraftingTool.FirstUse = false
					CraftingTool.WaitTime = 3000
				end
			end
			CraftingTool.LastSkillUseTime = ticks
		end
	end
end

function StepsToFinish(Left)
	local steps = 0
	if(oneStep == "1") then
		return 1
	end
	while(Left > 0 and CraftingTool.ProgressGain > 0) do
		Left = Left - CraftingTool.ProgressGain
		steps = steps + 1
	end
	return steps
end

function NextStepID(Synth)
	if(sCraft == "1") then
		--Returns the value of simplest skill in the chosen proffesion
		return SelectSkill(CraftingTool.Skills[gCraftProf])
	end
	if(hqCraft == "1") then

	end
end

function SelectSkill(skills)
	if(skills) then
		local i,e = next (skills)
		while ( i and e ) do
			if ( e.Base.level == 1 ) then
				return e.Base.id
			end
			i,e = next (skills,i)
		end	
	else
		return 0
	end	
end

--264/Great-Strides 100063/Careful-Synthesis 100064/Standard-Touch 100061/Basic-Touch 100060/Basic-Synthesis 100070/Observe
function MakeStep(SkillID)
	
	CraftingTool.WaitTime = 2500
end
]]--
--register our function
RegisterEventHandler("Gameloop.Update", CraftingTool.Update) -- the normal pulse from the gameloop
RegisterEventHandler("Module.Initalize", CraftingTool.ModuleInit)
RegisterEventHandler("GUI.Update", CraftingTool.GUIVARUpdate)