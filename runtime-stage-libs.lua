
function add_equipment_category(entitytype,categoryname)
	for _,prototype in pairs(data.raw[entitytype]) do
		if not prototype.equipment_grid then
			return
		end
		local equipmentgrid=data.raw["equipment-grid"][prototype.equipment_grid]
		equipmentgrid.equipment_categories=equipmentgrid.equipment_categories or {}
		for _, category in pairs(equipmentgrid.equipment_categories) do
			if category == categoryname then
				found = true
				break
			end
		end
		if not found then
			table.insert(data.raw["equipment-grid"][prototype.equipment_grid].equipment_categories, categoryname)
		end
	end
end

function distance(entity1, entity2)
	local position1=entity1.position
	local position2=entity2.position
	return ((position1.x - position2.x)^2 + (position1.y - position2.y)^2)^0.5
end

local function get_custom_table(entity,custom_table)
	if entity.object_name=="LuaEntity" then
		if custom_table[entity.name] then
			return custom_table[entity.name],entity.name
		end
		if custom_table[entity.type] then
			return custom_table[entity.type],entity.type
		end
		if entity.train and custom_table["train"] then
			return custom_table["train"],"train"
		end
	elseif entity.object_name=="LuaTrain" and custom_table["train"] then
		return custom_table["train"],"train"
	end
	return custom_table["any"],"any"
end

function get_custom_prototype(entity)
	return get_custom_table(entity,custom_prototypes)
end

function get_custom_gui(entity)
	return get_custom_table(entity,custom_guis)
end

function comparedata(comparator,firstdata,seconddata)
	firstdata=tonumber(firstdata)
	seconddata=tonumber(seconddata)
	if not firstdata or not seconddata or not comparator then
		return false
	end
	if comparator==">" then
		return firstdata>seconddata
	elseif comparator=="=" then
		return firstdata==seconddata
	elseif comparator=="<" then
		return firstdata<seconddata
	end
end

function connect_all_wires(ent1,ent2)
	if ent1 and ent2 then
		ent1.connect_neighbour{wire=defines.wire_type.red,target_entity=ent2}
		ent1.connect_neighbour{wire=defines.wire_type.green,target_entity=ent2}
		ent1.connect_neighbour(ent2)
	end
end

function get_unitid(entity)
	if not entity then
		return
	end
	return 
		(entity.object_name=="LuaTrain" and entity.id) or
		(entity.object_name=="LuaEntity" and entity.unit_number)
end

function init_custom_data()
	for _,entity in pairs(global.custom_entities or {}) do
		custom_prototype=custom_prototypes[entity.prototype_index]
		setmetatable(entity,custom_prototype)
		custom_prototype.__index=custom_prototype
	end
end