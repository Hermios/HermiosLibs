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

function get_filtered_signal_prototypes(array_filter)
	local result={}
	for _,signal in pairs(game.virtual_signal_prototypes) do
		local is_ok=false
		for _,filter in pairs(array_filter) do
			local signal_filter=(signal[filter.filter].name or signal[filter.filter])
			local local_is_ok=filter.invert and signal_filter~=filter[filter.filter] or signal_filter==filter[filter.filter]
			if filter.mode=="and" then
				is_ok=is_ok and local_is_ok
			else
				is_ok=is_ok or local_is_ok
			end
		end
		if is_ok then table.insert(result,signal) end
	end
	return result
end

function get_spritepath_from_signal(signal)
	local type=signal.type=="virtual" and "virtual-signal" or signal.type
	return type.."/"..signal.name
end

function get_signal_from_spritepath(spritepath)
	if not spritepath or spritepath=="" then
		return
	end
	local sprite_data=string.split(spritepath,"/")
	sprite_data[1]=sprite_data[1]=="virtual-signal" and "virtual" or sprite_data[1]
	return {name=sprite_data[2],type=sprite_data[1]}
end

function get_spritepath_from_item(item)
	local type=
		item.object_name=="LuaSignalVirtuelPrototype" and "virtual-signal" or
		item.object_name=="LuaFluidPrototype" and "fluid" or
		item.object_name=="LuaItemPrototype" and "item"
	return type.."/"..item.name
end

function get_item_from_spritepath(spritepath)
	if not spritepath or spritepath=="" then
		return
	end
	local sprite_data=string.split(spritepath,"/")
	return
		sprite_data[1]=="virtual-signal" and game.virtual_signal_prototypes[sprite_data[2]] or
		sprite_data[1]=="fluid" and game.fluid_prototypes[sprite_data[2]] or
		sprite_data[1]=="item" and game.item_prototypes[sprite_data[2]]
end

function get_item_from_signal(signal)
	return
		signal.type=="virtual" and game.virtual_signal_prototypes[signal.name] or
		signal.type=="fluid" and game.fluid_prototypes[signal.name] or
		signal.type=="item" and game.item_prototypes[signal.name]
end

function get_signal_from_item(item)
	local type=
		item.object_name=="LuaSignalVirtuelPrototype" and "virtual" or
		item.object_name=="LuaFluidPrototype" and "fluid" or
		item.object_name=="LuaItemPrototype" and "item"
	return {type=type,name=item.name}
end

function compare_data(value1,comparator,value2)
	if not value1 or not comparator or not value2 then
		return false
	end
	local special_comp={}
	special_comp["="]="=="
	special_comp["!="]="~="
	special_comp["≠"]="~="
	special_comp["≤"]="<="
	special_comp["≥"]=">="
	local script="return function() return "..value1..(special_comp[comparator] or comparator)..value2.. " end"
	local length = #script
	local func, err = load(script)
	local ok, compare = pcall(func)
	return compare()
end