local flib_table = require("__flib__.table")
local utils = require("scripts/utils")

---@return SummaryData
local function create_new_summary()
    return {
        items = {},
        fluids = {},
        trains = {},
        stations = {},
    }
end

---@param summary_data SummaryData
---@param event LogEntry
local function add_event(summary_data, event)
    for _, item in pairs(event.contents) do
        summary_data.items[item.name] = summary_data.items[item.name]
            or {
                name = item.name,
                count = 0,
            }
        summary_data.items[item.name].count = summary_data.items[item.name].count + item.count
    end

    for name, amount in pairs(event.fluid_contents) do
        summary_data.fluids[name] = summary_data.fluids[name] or 0
        summary_data.fluids[name] = summary_data.fluids[name] + amount
    end
end


---@param summary_data SummaryData
---@param gui_id string
local function create_gui_from_data(summary_data, gui_id)
    -- Array of sprite-buttons
    local top_items = {}
    local top_fluids = {}

    table.sort(summary_data.items, function(a, b) return a.count > b.count end)
    table.sort(summary_data.fluids, function(a, b) return a > b end)

    for _, item in pairs(summary_data.items) do
        table.insert(top_items, utils.sprite_button(
            "item",
            item.name,
            item.count,
            gui_id
        ))
    end

    for name, amount in pairs(summary_data.fluids) do
        table.insert(top_fluids, utils.sprite_button(
            "fluid",
            name,
            amount,
            gui_id
        ))
    end

    local summary_contents = {
        {
            type = "label",
            caption = { "spelevator-log.summary-top-items" },
        },
        {
            type = "table",
            column_count = 10,
            children = top_items,
        },
        {
            type = "label",
            caption = { "spelevator-log.summary-top-fluids" },
        },
        {
            type = "table",
            column_count = 10,
            children = top_fluids,
        },
    }
    return summary_contents
end

return {
    create_new_summary = create_new_summary,
    create_gui_from_data = create_gui_from_data,
    add_event = add_event,
}
