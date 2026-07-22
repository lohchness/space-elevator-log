local gui_handlers = require("gui/handlers")

--- Handles clicking a sprite button in the contents column of an event row.
--- @param event EventData.on_gui_click
function gui_handlers.set_filter_sprite_button(event)
    local gui_config = storage.guis[event.element.tags.gui_id]

    -- Open factoriopedia here
    if event.alt and event.button == defines.mouse_button_type.left then
        if event.element.tags.item_type == "item" then
            game.players[event.player_index].open_factoriopedia_gui(prototypes.item[event.element.tags.name])
        elseif event.element.tags.item_type == "fluid" then
            game.players[event.player_index].open_factoriopedia_gui(prototypes.fluid[event.element.tags.name])
        end
        return
    end

    gui_config.toolbar.selected_item = nil
    gui_config.toolbar.selected_fluid = nil
    gui_config.toolbar.filter_item_button.elem_value = nil
    gui_config.toolbar.filter_fluid_button.elem_value = nil

    if event.element.tags.item_type == "item" then
        gui_config.toolbar.selected_item = event.element.tags.name
        gui_config.toolbar.filter_item_button.elem_value = event.element.tags.name
    elseif event.element.tags.item_type == "fluid" then
        gui_config.toolbar.selected_fluid = event.element.tags.name
        gui_config.toolbar.filter_fluid_button.elem_value = event.element.tags.name
    end

    gui_handlers.generic_refresh(event)
end

---@param item_type string
---@param name string
---@param amount int?
---@param gui_id string
---@param custom_handler function?
---@return flib.GuiElemDef
local function sprite_button(item_type, name, amount, gui_id, custom_handler)
    local sprite = item_type .. "/" .. name

    return {
        type = "sprite-button",
        style = "flib_slot_button_default",
        sprite = sprite,
        number = amount,
        handler = custom_handler or gui_handlers.set_filter_sprite_button,
        tags = { item_type = item_type, name = name, gui_id = gui_id },
        -- tooltip = tooltip
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
-- filtering out any key-value pairs for non-true results. Passes the index as second argument to the function.
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

return {
    sprite_button = sprite_button,
    title = title,
    find = find,
    any = any,
    filter = filter,
}
