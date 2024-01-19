custom_guis={}
local current_gui
local selected_entity_id
local _modname

local function get_or_select_gui_element_index(lua_gui_element,value)
    if value then
        lua_gui_element.selected_index=get_index(lua_gui_element.items,value)
    else
        return lua_gui_element.items[lua_gui_element.selected_index]
    end
end

local ELEMENTTYPE_VALUE={
    textfield={"text",tostring},
    progressbar={"value",tonumber},
    checkbox={"state"},
    radiobutton={"state"},
    sprite_button={"toggled"},
    drop_down=get_or_select_gui_element_index,
    list_box=get_or_select_gui_element_index,
    choose_elem_button={"elem_value"},
    text_box={"text",tostring},
    slider={"slider_value",tonumber},
    switch="switch_state",
    label={"caption",tostring}
}

local function set_lua_gui_element_data(lua_gui_element,data)
    local type_value=ELEMENTTYPE_VALUE[lua_gui_element.type:gsub("-","_")]
    if type(type_value)=="table" then
        lua_gui_element[type_value[1]]=type_value[2] and type_value[2](data) or data
    elseif type(type_value)=="function" then
        type_value(lua_gui_element,data)
    elseif lua_gui_element.tags.model then
        for _,child in pairs(data) do
            add_row(lua_gui_element,child)
        end
    end
end

local function get_lua_gui_element_data(lua_gui_element)
    local result
    local type_value=ELEMENTTYPE_VALUE[lua_gui_element.type:gsub("-","_")]
    if type(type_value)=="function"  then
        result=type_value(lua_gui_element)
    elseif type(type_value)=="table"  then
        result=lua_gui_element[type_value[1]]
    else
        result={}
        for _,child in pairs(lua_gui_element.children) do
            data,index=get_lua_gui_element_data(child)
            if data and index then
                result[index]=data
            end
        end
    end
    return result,lua_gui_element.tags.id
end

local function add_guielement(parent,gui_element,parent_data)
    local lua_gui_element=parent.add(gui_element)
    if lua_gui_element.tags.on_load then
        _G[lua_gui_element.tags.on_load](lua_gui_element)
    end
    if lua_gui_element.tags.id then
        if lua_gui_element.tags.model then
            add_guielement(lua_gui_element,{type="button",caption="+",tags={on_action="add_row"},style="slot_button_that_fits_textline"})
        end
        data=parent_data and parent_data[lua_gui_element.tags.id]
        if data then
            pcall(set_lua_gui_element_data,lua_gui_element,data)
        end
    else
        for _,child in pairs(lua_gui_element.tags.children or {}) do
            add_guielement(lua_gui_element,child,parent_data)
        end
    end
    return lua_gui_element
end

function get_gui_modname()
    return _modname
end

function open_gui(entity)
    local gui,index=get_custom_gui(entity)
    if not gui then
        return
    end
    selected_entity_id=get_unitid(index=="train" and entity.train or entity)
    -- Create custom_entity if necessary
    if not global.custom_entities[selected_entity_id] then
        on_built(entity)
    end
    global.custom_entities[selected_entity_id].control_behavior=global.custom_entities[selected_entity_id].control_behavior or {}
    _modname=modname
    current_gui=add_guielement(game.get_player(1).gui[gui.position],gui.gui,global.custom_entities[selected_entity_id].control_behavior)
end

function add_row(lua_gui_element,data)
    local lua_gui_table=not data and lua_gui_element.parent or lua_gui_element
    local lua_gui_frame=add_guielement(lua_gui_table,{type="flow",direction="horizontal",tags={id=#lua_gui_table.children}})
    for _,child in pairs(lua_gui_table.tags.model) do
        add_guielement(lua_gui_frame,child,data)
    end
    add_guielement(lua_gui_frame,{type="button",caption="-",tags={on_action="remove_row"},style="slot_button_that_fits_textline"})
    if not data then
        update_control_behavior()
    end
end

function remove_row(lua_gui_element)
    lua_gui_table=lua_gui_element.parent.parent
    lua_gui_element.parent.destroy()
    update_control_behavior(lua_gui_table  )
end


function update_control_behavior()
    global.custom_entities[selected_entity_id].control_behavior,index=get_lua_gui_element_data(current_gui)
    if global.custom_entities[selected_entity_id].on_gui_changed then
        global.custom_entities[selected_entity_id]:on_gui_changed()
    end
end

function on_gui_closed()
    if current_gui then
        current_gui.destroy()
    end
end