local gui_handlers = require("gui/handlers")
local constants = require("scripts/constants")

--- Handles clicking a sprite button in the contents column of an event row.
--- @param event EventData.on_gui_click
function gui_handlers.set_filter_content(event)
    local gui_state = storage.guis[event.element.tags.gui_id]

    -- Open factoriopedia here
    if event.alt and event.button == defines.mouse_button_type.left then
        if event.element.tags.content_type == "item" then
            game.players[event.player_index].open_factoriopedia_gui(prototypes.item[event.element.tags.content_name])
        elseif event.element.tags.content_type == "fluid" then
            game.players[event.player_index].open_factoriopedia_gui(prototypes.fluid[event.element.tags.content_name])
        end
        return
    end

    gui_state.toolbar.selected_item = nil
    gui_state.toolbar.selected_fluid = nil
    gui_state.toolbar.filter_item_button.elem_value = nil
    gui_state.toolbar.filter_fluid_button.elem_value = nil

    if event.element.tags.content_type == "item" then
        gui_state.toolbar.selected_item = event.element.tags.content_name
        gui_state.toolbar.filter_item_button.elem_value = event.element.tags.content_name
    elseif event.element.tags.content_type == "fluid" then
        gui_state.toolbar.selected_fluid = event.element.tags.content_name
        gui_state.toolbar.filter_fluid_button.elem_value = event.element.tags.content_name
    end

    gui_handlers.generic_refresh(event)
end

---@param content sel.Content
---@param gui_id string
---@return flib.GuiElemDef
local function content_button(content, gui_id)
    local prototype ---@type LuaItemPrototype | LuaFluidPrototype
    if content.type == "item" then
        prototype = prototypes.item[content.name]
    else
        prototype = prototypes.fluid[content.name]
    end

    return {
        type = "sprite-button",
        style = "flib_slot_button_default",
        sprite = content.type .. "/" .. content.name,
        number = content.amount,
        handler = gui_handlers.set_filter_content,
        tags = {
            content_type = content.type,
            content_name = content.name,
            gui_id = gui_id,
        },
        tooltip = { "se-log.item_with_count", prototype.localised_name, content.amount },
    }
end

---@param sprite string
---@param train_id int
---@param gui_id string
---@return flib.GuiElemDef
local function train_button(sprite, train_id, gui_id)
    return {
        type = "sprite-button",
        style = "flib_slot_button_default",
        sprite = sprite,
        handler = gui_handlers.view_train_position,
        tags = {
            train_id = train_id,
            gui_id = gui_id,
        },
    }
end

---@param sprite string
---@param gui_id string
---@return flib.GuiElemDef
local function icon_button(sprite, gui_id)
    return {
        type = "sprite-button",
        style = "flib_slot_button_default",
        sprite = sprite,
        tags = {
            gui_id = gui_id,
        },
    }
end

--- initial word letters uppercase ('title case').
-- Here 'words' mean chunks of non-space characters.
---@param s string
---@return string a string with each word's first letter uppercase
local function title(s)
    return (s:gsub([[(%S)(%S*)]], function(f, r)
        return f:upper() .. r:lower()
    end))
end

--- Given a candidate search function, iterates over the table, calling the function
-- for each element in the table, and returns the first element the search function returned true.
-- Passes the index as second argument to the function.
---@param tbl table             the table to be searched
---@param func function         the function to use when searching for any matching element
---@param ... any? additional arguments passed to the function
---@return any, any|nil|?       the first found value
local function find(tbl, func, ...)
    for k, v in pairs(tbl) do if func(v, k, ...) then return v, k end end
    return nil
end

---Given a candidate search function, iterates over the table, calling the function
-- for each element in the table, and returns true if search function returned true.
-- Passes the index as second argument to the function.
---@param table table       the table to be searched
---@param func function     the function to use to search for any matching element
---@param ... any?          additional arguments passed to the function
---@return boolean true     if an element was found, false if none was found
local function any(table, func, ...)
    return find(table, func, ...) ~= nil
end

--- Given a filter function, creates a filtered copy of the table
-- by calling the function for each element in the table, and
-- filtering out any key-value pairs for non-true results.
-- Passes the index as second argument to the function.
---@param tbl table       the table to be filtered
---@param func function   the function to filter values
---@param ... any?        additional arguments passed to the function
---@return table          a new table containing the filtered key-value pairs
function filter(tbl, func, ...)
    local new_tbl = {}
    local add = table_size(tbl) > 0
    for k, v in pairs(tbl) do
        if func(v, k, ...) then
            if add then
                table.insert(new_tbl, v)
            else
                new_tbl[k] = v
            end
        end
    end
    return new_tbl
end

--- Given a mapping function, creates a transformed copy of the table
-- by calling the function for each element in the table, and using
-- the result as the new value for the key.
-- Passes the index as second argument to the function.
---@param tbl table       the table to be mapped to the transform
---@param func function   func the function to transform values
---@param ... any?        additional arguments
---@return table          a new table containing the keys and mapped values
function map(tbl, func, ...)
    local new_tbl = {}
    for k, v in pairs(tbl) do new_tbl[k] = func(v, k, ...) end
    return new_tbl
end

return {
    content_button = content_button,
    train_button = train_button,
    icon_button = icon_button,
    title = title,
    find = find,
    any = any,
    filter = filter,
    map = map,
}
