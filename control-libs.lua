require "custom-variables"
require "lua-libs"
require "runtime-stage-libs"
require "train-libs"
require "gui-libs"

global.custom_entities=global.custom_entities or {}
custom_prototypes={}
local on_gui_changed_array={
	"on_gui_checked_state_changed",
	"on_gui_click",
	"on_gui_elem_changed",
	"on_gui_selected_tab_changed",
	"on_gui_selection_state_changed",
	"on_gui_switch_state_changed",
	"on_gui_text_changed",
	"on_gui_value_changed"
}

local function init_events()
	for eventname,_ in pairs(defines.events) do
		if eventname~="on_tick" and eventname~="on_chunk_generated" and eventname~="on_entity_spawned" then 
		script.on_event(defines.events[eventname], function(event)
			if custom_technology and not game.players[1].force.technologies[custom_technology].researched then
				return
			end
			if has_value(on_gui_changed_array,eventname) and event.element.get_mod()==get_gui_modname() then
				if event.element.tags.id then
					update_control_behavior()
				end
				if event.element.tags.on_action then
					_G[event.element.tags.on_action](event.element)
				end
			end
			if _G[eventname] then
				_G[eventname](event)
			end
		end)
	end
	end
	for eventName,called_function in pairs(custom_events or {}) do
		script.on_event(eventName,function(event)
			if custom_technology and not game.players[1].force.technologies[custom_technology].researched then
				return
			end
			if called_function then called_function(event) end
		end)
	end
end

script.on_init(function()
	if initcommands then initcommands() end
	if mod_on_init then mod_on_init(true) end
	if init_remote then init_remote() end
	init_events()
end)

script.on_load(function()
	if initcommands then initcommands() end
	if mod_on_init then mod_on_init(false) end
	if init_remote then init_remote() end
	init_custom_data()
	init_events()
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
-- On entity built
---------------------------------------------------
function on_robot_built_entity(event)
	if event.created_entity and event.created_entity.valid==false then
		return
	end
	if mod_on_built then
		mod_on_built(event.created_entity)
	end
	on_built(event.created_entity)
end

function on_built_entity(event)
	if event.created_entity and event.created_entity.valid==false then
		return
	end
	if mod_on_built then
		mod_on_built(event.created_entity)
	end
	on_built(event.created_entity)
end

---------------------------------------------------
-- On entity removed
---------------------------------------------------
function on_robot_pre_mined(event)
	if not event.entity or event.entity.valid==false then
		return
	end
	if mod_on_removed then
		mod_on_removed(event.entity)
	end
	entity=global.custom_entities[event.entity.unit_number]
	if entity then
		if entity.on_removed then
			entity:on_removed()
		end
		global.custom_entities[event.entity.unit_number]=nil
	end
end

function on_entity_destroyed(event)
	if not event.entity or event.entity.valid==false then
		return
	end
	if mod_on_removed then
		mod_on_removed(event.entity)
	end
	entity=global.custom_entities[event.entity.unit_number]
	if entity then
		if entity.on_removed then
			entity:on_removed()
		end
		global.custom_entities[event.entity.unit_number]=nil
	end
end

function on_entity_died(event)
	if not event.entity or event.entity.valid==false then
		return
	end
	if mod_on_removed then
		mod_on_removed(event.entity)
	end
	entity=global.custom_entities[event.entity.unit_number]
	if entity then
		if entity.on_removed then
			entity:on_removed()
		end
		global.custom_entities[event.entity.unit_number]=nil
	end
end

function on_pre_player_mined_item(event)
	if not event.entity or event.entity.valid==false then
		return
	end
	if mod_on_removed then
		mod_on_removed(event.entity)
	end
	entity=global.custom_entities[event.entity.unit_number]
	if entity then
		if entity.on_removed then
			entity:on_removed()
		end
		global.custom_entities[event.entity.unit_number]=nil
	end
end

---------------------------------------------------
-- Train
---------------------------------------------------
function on_train_created(event)
	if mod_on_train_created then
		mod_on_train_created(event)
	end
	if event.old_train_id_1 then global.custom_entities[event.old_train_id_1]=nil end
    if event.old_train_id_2 then global.custom_entities[event.old_train_id_2]=nil end
	on_built(event.train)
	for _,locomotive in pairs(event.train.locomotives.front_movers) do
        on_built(locomotive)
    end
    for _,locomotive in pairs(event.train.locomotives.back_movers) do
        on_built(locomotive)
    end
end

---------------------------------------------------
-- Gui
---------------------------------------------------
function on_gui_opened(event)
	if not event.entity or event.entity.valid==false then
		return
	end
	if mod_open_gui then
		mod_open_gui(event)
	end
	open_gui(event.entity)
end


---------------------------------------------------
-- global functions
---------------------------------------------------
function on_built(entity)
	local custom_prototype,index=get_custom_prototype(entity)
	if custom_prototype then
		local custom_entity=
			custom_prototype.new and custom_prototype:new(entity) or
			{entity=entity}
		custom_entity.prototype_index=index
		setmetatable(custom_entity, custom_prototype)
		custom_prototype.__index=custom_prototype
		global.custom_entities[get_unitid(custom_entity.entity)]=custom_entity
		if custom_entity.on_built then
			custom_entity:on_built()
		end
	end
end