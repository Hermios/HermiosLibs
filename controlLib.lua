listCustomEvents={}
EventsControl={}

require "data"

script.on_init(function(event)
		if initDataLibs then initDataLibs(true) end
		if initLocalData then initLocalData() end
		if InitGuiLibs then InitGuiLibs(true) end
		if InitGuiBuild then InitGuiBuild() end
		if InitCommands then InitCommands() end
		if InitRemote then InitRemote() end
		if InitListCustomEvents then InitListCustomEvents() end
		if InitCustomEvents then InitCustomEvents() end
	end)

script.on_load(function(event)
		if initDataLibs then initDataLibs() end
		if initLocalData then initLocalData() end
		if InitGuiLibs then InitGuiLibs() end
		if InitGuiBuild then InitGuiBuild() end
		if InitCommands then InitCommands() end
		if InitRemote then InitRemote() end
		if InitListCustomEvents then InitListCustomEvents() end
		if InitCustomEvents then InitCustomEvents() end
	end)

---------------------------------------------------
--tick
---------------------------------------------------
script.on_event(defines.events.on_tick, function(event)
	if technologyName and not game.players[1].force.technologies[technologyName].researched then			
		return		
	end
	if game.players[1].mod_settings[ModName.."check_delay"] and event.tick%game.players[1].mod_settings[ModName.."_check_delay"].value>0 then
		return
	end	
	if OnTick then OnTick(event.tick) end
end)

---------------------------------------------------
-- ENTITY
---------------------------------------------------
-- On entity built
script.on_event(defines.events.on_robot_built_entity, function(event)
	if technologyName and not game.players[1].force.technologies[technologyName].researched then			
		return		
	end
	local eventsControl=getEntityEvent(event.created_entity)
	if eventsControl.OnBuilt then
		eventsControl.OnBuilt(event.created_entity)
	end	
end)

script.on_event(defines.events.on_built_entity, function(event)
	if technologyName and not game.players[1].force.technologies[technologyName].researched then			
		return		
	end
	local eventsControl=getEntityEvent(event.created_entity)
	if eventsControl.OnBuilt then
		eventsControl.OnBuilt(event.created_entity)
	end	
end)

-- On entity removed
script.on_event(defines.events.on_robot_pre_mined, function(event)
	if technologyName and not game.players[1].force.technologies[technologyName].researched then			
		return		
	end
	local eventsControl=getEntityEvent(event.entity)
	if eventsControl.OnRemoved then
		eventsControl.OnRemoved(event.entity)
	end	
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
	if technologyName and not game.players[1].force.technologies[technologyName].researched then			
		return		
	end
	local eventsControl=getEntityEvent(event.entity)
	if eventsControl.OnRemoved then
		eventsControl.OnRemoved(event.entity)
	end	
end)

-- On equipment placed
script.on_event(defines.events.on_player_placed_equipment, function(event)
	if technologyName and not game.players[1].force.technologies[technologyName].researched then			
		return		
	end
	local eventsControl=getEntityEvent(event.equipment)
	if eventsControl.OnEquipmentPlaced then
		eventsControl.OnEquipmentPlaced(event.equipment)
	end	
end)

-- On equipment removed
script.on_event(defines.events.on_player_removed_equipment, function(event)
	if technologyName and not game.players[1].force.technologies[technologyName].researched then			
		return		
	end	
	local eventsControl=getEntityEvent(event.equipment)
	if eventsControl.OnEquipmentRemoved then
		eventsControl.OnEquipmentRemoved(event.equipment)
	end
end)

--On train created
script.on_event(defines.events.on_train_created, function(event)
	if technologyName and not game.players[1].force.technologies[technologyName].researched then			
		return		
	end
	if OnTrainCreated then OnTrainCreated(event) end
end)

--On train state changed
script.on_event(defines.events.on_train_changed_state, function(event)
	if technologyName and not game.players[1].force.technologies[technologyName].researched then			
		return		
	end
	if OnTrainStateChanged then OnTrainStateChanged(event) end
end)

-- On copy paste
script.on_event(defines.events.on_pre_entity_settings_pasted, function(event)
	if (technologyName and not game.players[1].force.technologies[technologyName].researched)
		or not GuiEntities then			
		return		
	end
	local reference
	if GuiEntities[event.destination.name] then
		reference="name"
	elseif GuiEntities[event.destination.type] then
		reference="type"
	end
	if not reference then
		return
	end
	local guiEntities=GuiEntities[event.destination[reference]]
	if event.source[reference]==event.destination[reference] and (guiEntities.data[getUnitId(event.source)] or {}).globalData and (guiEntities.data[getUnitId(event.destination)] or {}).globalData then
		guiEntities.data[getUnitId(event.destination)].globalData.guiData=clone(guiEntities.data[getUnitId(event.source)].globalData.guiData)		
	end
end)

-- On research finished
script.on_event(defines.events.on_research_finished, function(event)
	if event.research.name==technologyName and OnResearchFinished then			
		OnResearchFinished()
	end
end)

-- On Custom key fired
function InitCustomEvents()
	for eventName,calledFunction in pairs(listCustomEvents) do
		script.on_event(eventName,function(event)
			if technologyName and not game.players[1].force.technologies[technologyName].researched then			
				return		
			end
			if calledFunction then calledFunction(event) end
		end)
	end
end