local format = require("__flib__.format")
local utils = require("scripts/utils")
local constants = require("scripts/constants")
local gui_handlers = require("gui/handlers")


---@param event sel.EventRow
---@return flib.GuiElemDef
local function render_timestamp(event, _)
    local relative_time = game.tick - event.time
    return {
        type = "label",
        caption = format.time(relative_time, true)
    }
end


---@param event sel.EventRow
---@param gui_id string
---@return flib.GuiElemDef
local function render_train(event, gui_id)
    local entry = event.entries[1]
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


---@param event sel.EventRow
---@param gui_id string
---@return flib.GuiElemDef
local function render_contents(event, gui_id)
    local entry = event.entries[1]
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

---@param entries sel.LogEntry[]
---@return sel.EventRow[]
local function transform_entries_single(entries)
    local rows = {}
    for _, entry in pairs(entries) do
        table.insert(rows, {
            entries = { entry },
            time = entry.time,
            count = 1,
        })
    end
    return rows
end


---@param event sel.EventRow
local function render_group_entry_count(event, _)
    return {
        type = "label",
        caption = event.count,
    }
end


---@param event sel.EventRow
---@param gui_id string
local function render_group_content(event, gui_id)
    return utils.sprite_button {
        item_type = event.type,
        name = event.name,
        amount = event.amount,
        gui_id = gui_id,
    }
end


---@param entries sel.LogEntry[]
---@return sel.EventRow[]
local function transform_entries_by_content(entries)
    local grouped_rows = {}

    local function group_by_content(entry, content_type, name, amount)
        local key = content_type .. ":" .. name

        local row = grouped_rows[key] ---@type sel.EventRow
        if not row then
            row = {
                entries = {},
                time = entry.time,
                count = 0,
                type = content_type,
                name = name,
                amount = 0,
            }
            grouped_rows[key] = row
        end

        row.count = row.count + 1
        row.amount = row.amount + amount
    end

    for _, entry in pairs(entries) do
        for _, item in pairs(entry.contents) do
            group_by_content(entry, "item", item.name, item.count)
        end
        for i, j in pairs(entry.fluid_contents) do
            group_by_content(entry, "fluid", i, j)
        end
    end

    local sorted_rows = {}
    for _, v in pairs(grouped_rows) do
        table.insert(sorted_rows, v)
    end
    table.sort(sorted_rows, function(a, b) return a.count > b.count end)

    return sorted_rows
end

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
        transform_entries = transform_entries_single,
    },
    {
        group_by = "content",
        columns = {
            {
                caption = { "se-log.table-header-num-trains" },
                render = render_group_entry_count,
            },
            {
                caption = { "se-log.table-header-content" },
                render = render_group_content,
            },
            {
                caption = { "se-log.table-header-last-train-time" },
                render = render_timestamp,
            },
        },
        transform_entries = transform_entries_by_content,
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
