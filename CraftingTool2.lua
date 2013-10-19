-- Create a new table for our code:
CraftingTool={ }

--some variables
CraftingTool.doCraft = false
CraftingTool.GreatStrideTime = 0
CraftingTool.LastSkillUseTime = 0
CraftingTool.WaitTime = 3000
CraftingTool.ProgressGain = 0
CraftingTool.FirstUse = false

function CraftingTool.Craft( dir )
	CraftingTool.doCraft = not CraftingTool.doCraft
end

-- Initializing function, we create a new Window for our module that has 1 button and 1 field to display data:
function CraftingTool.ModuleInit()
	GUI_NewWindow("CraftingTool",600,200,150,150)
	--Food GUI
	GUI_NewField("CraftingTool","Item ID","itemID", "Crafting")
	GUI_NewField("CraftingTool","Steps To Finish","stepsLeft", "Crafting")
	GUI_NewField("CraftingTool","Crafting","cCraft", "Crafting")
	GUI_NewField("CraftingTool","CraftLog Open","clOpen", "Crafting")
	GUI_NewCheckbox("CraftingTool", "Simple Craft", "sCraft","Crafting")
	GUI_NewCheckbox("CraftingTool", "HQ Craft(lvl21)", "hqCraft21","Crafting")
	GUI_NewCheckbox("CraftingTool", "Observe", "Observe","Crafting")
	GUI_NewCheckbox("CraftingTool", "One Step Craft", "oneStep","Crafting")
	GUI_NewButton("CraftingTool", "Start\\Stop", "CraftingTool.Craft","Crafting") 
	RegisterEventHandler("CraftingTool.Craft", CraftingTool.Craft)
	
	--DO NOT OPEN
	GUI_NewField("CraftingTool", "Artifact Fix", "artfixvar","Don't open this(fix)")
	--Win Size
	GUI_SizeWindow("CraftingTool",300,200)
	
	--Init Values
	if (Settings.FFXIVMINION.sCraft == nil) then
		Settings.FFXIVMINION.sCraft = "0"
	end
	sCraft = Settings.FFXIVMINION.sCraft
	
	if (Settings.FFXIVMINION.hqCraft21 == nil) then
		Settings.FFXIVMINION.hqCraft21 = "0"
	end
	hqCraft21 = Settings.FFXIVMINION.hqCraft21
	
	if (Settings.FFXIVMINION.Observe == nil) then
		Settings.FFXIVMINION.Observe = "0"
	end
	Observe = Settings.FFXIVMINION.oneStep
	if (Settings.FFXIVMINION.oneStep == nil) then
		Settings.FFXIVMINION.oneStep = "0"
	end
	oneStep = Settings.FFXIVMINION.oneStep
end

function CraftingTool.GUIVARUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if (k == "sCraft" or k == "hqCraft21" or k == "Observe" or k == "oneStep")  then
			Settings.FFXIVMINION[tostring(k)] = v
		end
	end
	GUI_RefreshWindow("CraftingTool")
end

function CraftingTool.Update(Event, ticks)
	cCraft = tostring(CraftingTool.doCraft)
	clOpen = tostring(Crafting:IsCraftingLogOpen())
	
	if(sCraft == "1" and hqCraft21 == "1") then --makes sure that you dont select both crafts
		sCraft = "0"
		hqCraft21 = "0"
	end
	
	if(CraftingTool.doCraft and (sCraft == "1" or hqCraft21 == "1")) then
		 --
		--d("" .. tostring(ticks - CraftingTool.LastSkillUseTime))
		if(ticks - CraftingTool.LastSkillUseTime > CraftingTool.WaitTime) then
			local synth = Crafting:SynthInfo()
			if ( synth ) then
				itemID = synth.itemid
				stepsLeft = tostring(StepsToFill(synth.progressmax - synth.progress))
				--if Simple Craft only use Basic Synthesis
				--if HQ craft use Carefull Synthesis to determine the amount of turn needed
				--then use Great Strides then if Good or better use Standard Touch\Basic Touch if enough CP else Carefull Synthesis(used first to determine no of steps to finish)
				--When 1 step left to finish only use Great Strides + Standard Touch\BasicTouch.
				if(sCraft == "1") then
					if(not synth.progress == 0 and not CraftingTool.FirstUse and oneStep == "0") then
						CraftingTool.FirstUse = true
						CraftingTool.ProgressGain = synth.progress
					end
					MakeStep(100060)
				elseif(hqCraft21 == "1") then
					if(not CraftingTool.FirstUse and oneStep == "0") then
						if(synth.progress == 0) then
							MakeStep(100063)
						else
							CraftingTool.FirstUse = true
							CraftingTool.ProgressGain = synth.progress
						end
					elseif(synth.durability == 10 and Player.cp.current > 91) then
						local duraDiff = synth.durabilitymax - synth.durability 
						if(duraDiff > 50) then
							MakeStep(100065)
						else
							MakeStep(100062)
						end
					elseif(synth.durability == 10 * StepsToFill(synth.progressmax - synth.progress)) then
						MakeStep(100063)
					elseif(CraftingTool.GreatStrideTime == 0 and synth.durability > 10 * StepsToFill(synth.progressmax - synth.progress) and Player.cp.current > 49) then
						ActionList:Cast(264,0)
						CraftingTool.GreatStrideTime = 3
					else
						if(Observe == "1") then
							if(Player.cp.current < 46) then
								if(Player.cp.current > 31) then
									MakeStep(100064)
								elseif(Player.cp.current > 17) then
									MakeStep(100061)
								else
									MakeStep(100063)
								end
							elseif((synth.description == "Good" or synth.description == "Excellent") or CraftingTool.GreatStrideTime == 1) then
								if(Player.cp.current > 31) then
									MakeStep(100064)
								elseif(Player.cp.current > 17) then
									MakeStep(100061)
								end
							else
								MakeStep(100070)
							end
						else
							if(Player.cp.current > 31) then
								MakeStep(100064)
							elseif(Player.cp.current > 17) then
								MakeStep(100061)
							else
								MakeStep(100063)
							end
						end
					end
				end
			else
				if (not Crafting:IsCraftingLogOpen()) then
					Crafting:ToggleCraftingLog()
				else
					Crafting:CraftSelectedItem()
					Crafting:ToggleCraftingLog()
					CraftingTool.ProgressGain = 0
					CraftingTool.FirstUse = false
					CraftingTool.GreatStrideTime = 0
					CraftingTool.WaitTime = 3000
				end
			end
			CraftingTool.LastSkillUseTime = ticks
		end
	end
end

function StepsToFill(Left)
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

--264/Great-Strides 100063/Careful-Synthesis 100064/Standard-Touch 100061/Basic-Touch 100060/Basic-Synthesis 100070/Observe
function MakeStep(SkillID)
	if(CraftingTool.GreatStrideTime > 0) then
		CraftingTool.GreatStrideTime = CraftingTool.GreatStrideTime - 1
	end
	ActionList:Cast(SkillID,0)
	local buffs = Player.buffs
	local i,e = next (buffs)
	local exists = false
	while ( i and e ) do
		if ( e.id == 254 ) then
			exists = true
			break
		end
		i,e = next (buffs,i)
	end	
	if(not exists) then
		CraftingTool.GreatStrideTime = 0
	end
	d("Use Skill: " .. tostring(SkillID) .. " GreatStride: " .. tostring(exists))
	
	CraftingTool.WaitTime = 2500
end

--register our function
RegisterEventHandler("Gameloop.Update", CraftingTool.Update) -- the normal pulse from the gameloop
RegisterEventHandler("Module.Initalize", CraftingTool.ModuleInit)
RegisterEventHandler("GUI.Update", CraftingTool.GUIVARUpdate)