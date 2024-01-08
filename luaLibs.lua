function getFirstKey(dictionary)
    if not dictionary then
        return nil
    end
    for key,_ in pairs(dictionary) do
        return key
    end
    return nil
    end
end

has_value =function(tab, val)
    for _, value in ipairs (tab) do
        if value == val then
            return true
        end
    end
    return false
end

get_index=function(tab,val)
	while tab[i]~=nil and tab[i]~=val do
		i=i+1
	end
	if tab[i]==nil then
		return nil
	else
		return i
	end
end

function removeVal(tab,val)
	table.remove(tab,get_index(tab,val))
end

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
 end
 
 function string.ends(String,End)
    return End=='' or string.sub(String,-string.len(End))==End
 end
 
 function clone(initTable)	
     if not initTable or type(initTable)~='table' then
         return initTable
     end
     local result={}
     for key,value in pairs(initTable) do
         if not string.starts(key,"_") then
             result[key]=clone(value)
         end
     end
     return result
 end 