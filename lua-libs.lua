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
    i=1
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

function string.split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end