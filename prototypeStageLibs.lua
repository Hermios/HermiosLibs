ListPrototypesData={}
changing_keys={"name","place_result","corpse","result","icon","filename","placed_as_equipment_result"}
local listKeysSetTo1={"x","y","height","width","frame_count","line_length","direction_count"}

local function recursiveSetEntityAsInvisible(entityTable)
	for key,value in pairs (entityTable) do
		if key=="connection_points" then
			entityTable[key] =
			{
				{
					shadow ={},
					wire =
					{
						copper = {0, 0},
						green = {0, 0},
						red = {0, 0}
					}
				},
			}
		elseif key=="red" or key=="green" or key=="copper" or (type(value)=="table" and string.find(key,"offset")) then
			entityTable[key]={0,0}
		elseif key=="shift" then
			entityTable[key]=nil
		elseif type(value)=="table" then
			entityTable[key]=recursiveSetEntityAsInvisible(value)
		elseif key=="icon" then
			entityTable[key] = "__HermiosLibs__/graphics/icons/empty.png"
		elseif key=="filename" and string.ends(value,"png") then
			entityTable[key]="__HermiosLibs__/graphics/entity/empty.png"
		elseif type(value)=="number" and has_value(listKeysSetTo1,key) then
			entityTable[key]=1
		end
	end
	return entityTable
end

function setEntityAsInvisible(entity)
	recursiveSetEntityAsInvisible(entity)
	entity.drawing_box = nil
	entity.collision_box = nil
    entity.selection_box = nil
	entity.corpse=nil
	return entity
end

local function recursiveCopyDataTable(oldTable,oldString,newString)
	local newTable={}
	for k,d in pairs(oldTable) do
		if not d then
			newTable[k]=nil
		elseif type(d)=="table" then
			newTable[k]=recursiveCopyDataTable(d,oldString,newString) 
		elseif type(d)=="string" and has_value(changing_keys,k) then
			newTable[k]=d
			if string.ends(newTable[k],"/"..oldString..".png") then
				newTable[k]=string.gsub(newTable[k],"__%a-__/(.+)","__"..ModName.."__/%1")
			end
			if string.find(newTable[k],"__"..ModName.."__") or not string.find(newTable[k],"__%a-__") then
				newTable[k]=newTable[k]:gsub(oldString:gsub("%-","%%-"),newString)		
			end
		else
			newTable[k]=d
		end
	end
	return newTable
end

createData=function(objectType,original,newName,newData)
	local newEntity=table.deepcopy(data.raw[objectType][original])
	if newEntity == nil then
		err("could not overwrite content of "..original.." with new content: "..serpent.block(newContent))
		return nil
	end
	newEntity=recursiveCopyDataTable(newEntity,original,newName)
	if newData then
		for k,d in pairs(newData) do
				newEntity[k]=d
		end
	end
	data:extend({newEntity})	
	return newEntity
end