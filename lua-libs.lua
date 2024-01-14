function get_first_key(dictionary)
    if not dictionary then
        return nil
    end
    for key,_ in pairs(dictionary) do
        return key
    end
    return nil
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

function remove_value(tab,val)
	table.remove(tab,get_index(tab,val))
end

function string.starts(str,startstr)
    return string.sub(str,1,str.len(startstr))==startstr
end

function string.ends(str,endstr)
    return endstr=='' or string.sub(str,-string.len(endstr))==endstr
end

function clone(inittable)	
    if not inittable or type(inittable)~='table' then
        return inittable
    end
    local result={}
    for key,value in pairs(inittable) do
        if type(key)~="string" or not string.starts(key,"_") then
            result[key]=clone(value)
        end
    end
    return result
end