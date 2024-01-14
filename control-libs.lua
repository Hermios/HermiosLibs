require "data-libs"

global.custom_entities=global.custom_entities or {}
custom_events={}
custom_prototypes={}

script.on_init(function()
	init_custom_data()
	if initlocaldata then initlocaldata() end
	if initguilibs then initguilibs(true) end
	if initguibuild then initguibuild() end
	if initcommands then initcommands() end
	if initremote then initremote() end
	initevents()
end)

script.on_load(function()
	init_custom_data()
	if initlocaldata then initlocaldata() end
	if initguilibs then initguilibs() end
	if initguibuild then initguibuild() end
	if initcommands then initcommands() end
	if initremote then initremote() end
	initevents()
end)

---------------------------------------------------
--tick
---------------------------------------------------
function on_tick(event)
	if game.players[1].mod_settings[modname.."check_delay"] and event.tick%game.players[1].mod_settings[modname.."_check_delay"].value>0 then
		return
	end
	if mod_on_tick then mod_on_tick(event.tick) end
end

---------------------------------------------------
-- ENTITY
---------------------------------------------------
-- On entity built
function on_robot_built_entity(event)
	if mod_on_built then
		mod_on_built(event.created_entity)
	end
	on_built(event.created_entity)
end

function on_built_entity(event)
	if mod_on_built then
		mod_on_built(event.created_entity)
	end
	on_built(event.created_entity)
end

-- On entity removed
function on_robot_pre_mined(event)
	entity=global.custom_entities[event.entity.unit_number]
	if entity then
		if entity.on_removed then
			entity:on_removed()
		end
		global.custom_entities[event.entity.unit_number]=nil
	end
end

function on_entity_destroyed(event)
	entity=global.custom_entities[event.entity.unit_number]
	if entity then
		if entity.on_removed then
			entity:on_removed()
		end
		global.custom_entities[event.entity.unit_number]=nil
	end
end

function on_entity_died(event)
	entity=global.custom_entities[event.entity.unit_number]
	if entity then
		if entity.on_removed then
			entity:on_removed()
		end
		global.custom_entities[event.entity.unit_number]=nil
	end
end

function on_pre_player_mined_item(event)
	entity=global.custom_entities[event.entity.unit_number]
	if entity then
		if entity.on_removed then
			entity:on_removed()
		end
		global.custom_entities[event.entity.unit_number]=nil
	end
end

-- On equipment placed
function on_player_placed_equipment(event)
	local custom_prototype=get_custom_prototype(event.equipment)
	if custom_prototype.on_equipment_placed then
		custom_prototype.on_equipment_placed(event.equipment)
	end
end

-- On equipment removed
function on_player_removed_equipment(event)
	local custom_prototype=get_custom_prototype(event.equipment)
	if custom_prototype.on_equipment_removed then
		custom_prototype.on_equipment_removed(event.equipment)
	end
end

-- On Custom key fired
function initevents()
	for eventname,_ in pairs(defines.events) do
		script.on_event(defines.events[eventname], function(event)
			if custom_technology and not game.players[1].force.technologies[custom_technology].researched then
				return
			end
			if _G[eventname] then
				_G[eventname](event)
			end
		end)
	end
	for eventName,called_function in pairs(custom_events) do
		script.on_event(eventName,function(event)
			if custom_technology and not game.players[1].force.technologies[custom_technology].researched then
				return
			end
			if called_function then called_function(event) end
		end)
	end
end

function on_built(entity)
	local custom_prototype,index=get_custom_prototype(entity)
	if custom_prototype then
		local custom_entity=
			custom_prototype.new and custom_prototype:new(entity) or
			{entity=entity}
		custom_entity.prototype_index=index
		setmetatable(custom_entity, custom_prototype)
		custom_prototype.__index=custom_prototype
		global.custom_entities[custom_entity.entity.unit_number]=custom_entity
		if custom_entity.on_built then
			custom_entity:on_built()
		end
	end
end