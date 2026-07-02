local flib_table = require("__flib__.table")

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
    if event.contents then
        for _, item in pairs(event.contents) do
            summary_data.items[item.name] = summary_data.items[item.name]
                or {
                    name = item.name,
                    count = 0,
                }
            summary_data.items[item.name].count = summary_data.items[item.name].count + item.count
        end
    end
end

local function create_gui_from_data(summary_data)
    -- Array of sprite-buttons
    local top_items = {}
    table.sort(summary_data.items, function(a, b) return a.count > b.count end)
    for name, item in pairs(summary_data.items) do
        table.insert(top_items,
        {
            type = "sprite-button",
            sprite = "item/"..name,
            number = item.count,
        }
    )
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
            children = {},
        },
    }
    return summary_contents
end

return {
    create_new_summary = create_new_summary,
    create_gui_from_data = create_gui_from_data,
    add_event = add_event,
}
