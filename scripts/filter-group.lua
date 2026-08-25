local format = require("__flib__.format")
local utils = require("scripts/utils")
local constants = require("scripts/constants")
local gui_handlers = require("gui/handlers")


---@param entry sel.LogEntry
---@return flib.GuiElemDef
local function render_timestamp(entry, _)
    local relative_time = game.tick - entry.time
    return {
        type = "label",
        caption = format.time(relative_time, true)
    }
end


---@param entry sel.LogEntry
---@param gui_id string
---@return flib.GuiElemDef
local function render_train(entry, gui_id)
    if not entry.train.valid then
        return utils.sprite_button {
            sprite_path = constants.invalid_train,
            gui_id = gui_id,
            hide_tooltip = true,
        }
    end

    return utils.sprite_button {
        item_type = "item",
        name = entry.train.front_stock.prototype.name,
        gui_id = gui_id,
        custom_handler = gui_handlers.view_train_position,
        train_id = entry.train.id,
        hide_tooltip = true,
    }
end


---@param entry sel.LogEntry
---@param gui_id string
---@return flib.GuiElemDef
local function render_contents(entry, gui_id)
    local children = {}

    for _, item in pairs(entry.contents) do
        table.insert(children, utils.sprite_button {
            item_type = "item",
            name = item.name,
            amount = item.count,
            gui_id = gui_id,
        })
    end
    for i, j in pairs(entry.fluid_contents) do
        table.insert(children, utils.sprite_button {
            item_type = "fluid",
            name = i,
            amount = j,
            gui_id = gui_id,
        })
    end

    return {
        type = "flow",
        direction = "horizontal",
        children = children,
    }
end

local function render_group_train_count() end
local function render_group_content() end

---@type sel.GroupByDef[]
local group_defs = {
    {
        group_by = "none",
        columns = {
            {
                caption = { "se-log.table-header-timestamp" },
                render = render_timestamp,
            },
            {
                caption = { "se-log.table-header-train" },
                render = render_train,
            },
            {
                caption = { "se-log.table-header-contents" },
                render = render_contents,
            },
        },
    },
    {
        group_by = "content",
        columns = {
            {
                caption = { "se-log.table-header-train-count" },
                render = render_group_train_count,
            },
            {
                caption = { "se-log.table-header-content" },
                render = render_group_content,
            },
            {
                caption = { "se-log.table-header-timestamp" },
                render = render_timestamp,
            },
        },
    },
}

---@param selected_index int
---@return sel.GroupByDef
local function get_group_def(selected_index)
    return group_defs[selected_index]
end

return {
    get_group_def = get_group_def,
}
