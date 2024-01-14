local key_to_update={"name","place_result","corpse","result","icon","placed_as_equipment_result"}
local invisible_keys_to_update={
	x=1,
	y=1,
	height=1,
	width=1,
	frame_count=1,
	line_length=1,
	direction_count=1,
	connection_points={{shadow ={},wire ={copper = {0, 0},green = {0, 0},red = {0, 0}}}},
	copper={0,0},
	green={0,0},
	red={0,0},
	shift={0,0},
	icon="__HermiosLibs__/graphics/icons/empty.png",
	flags={"hidden"},
	filename="__HermiosLibs__/graphics/entity/empty.png",
	drawing_box = {{0,0},{0,0}},
	collision_box = {{0,0},{0,0}},
    selection_box = {{0,0},{0,0}},
	corpse=nil
}

local function copy_data_table_recursively(oldtable,oldstring,newstring,hide)
	local newtable={}
	for k,d in pairs(oldtable) do
		if hide and invisible_keys_to_update[k] and (k~="filename" or string.ends(d,"png")) then
			newtable[k]=invisible_keys_to_update[k]
		elseif type(d)=="table" then
			newtable[k]=copy_data_table_recursively(d,oldstring,newstring,hide)
		elseif has_value(key_to_update,k) and string.find(d,oldstring,1,true) then	
			newtable[k]=d:gsub(oldstring:gsub("%-","%%-"),newstring):gsub("__base__","__"..modname.."__")
		else
			newtable[k]=d
		end
	end
	return newtable
end

createdata=function(objecttype,original,newname,newdata,hide)
	newentity=copy_data_table_recursively(data.raw[objecttype][original],original,newname,hide)
	for k,d in pairs(newdata or {}) do
		newentity[k]=d
	end
	data:extend({newentity})
	return newentity
end