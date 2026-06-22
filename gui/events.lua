local format = require("__flib__.format")
local flib_gui = require("__flib__.gui")

local function sprite_button_name_amount(name, amount)
    local prototype = prototypes.item[name]
    local sprite = "item/"..name

    return {
        type = "sprite-button",
        style = "flib_slot_button_default",
        sprite = sprite,
        number = amount,
        -- handler = gui_handlers.set_filter_item,
        -- tags = {filter = item_type, value = name, gui_id = gui_id},
        -- tooltip = tooltip
    }
end


---comment
---@param entry LogEntry
---@param children table
local function create_row(entry, children)
    local departure_time = entry.time
    local relative_time = game.tick - departure_time

    local timestamp = {
        type = "label",
        caption = format.time(relative_time, true)
    }

    local contents_children = {}
    if entry.contents then
        for i, item in pairs(entry.contents) do
            table.insert(contents_children, sprite_button_name_amount(item.name, item.count))
        end
    end
    local contents_flow = {
        type = "flow",
        direction = "horizontal",
        children = contents_children
    }
    table.insert(children, timestamp)
    table.insert(children, contents_flow)
end

---comment
---@param entries LogEntry[]
---@param columns string[]
---@return table, integer
local function create_result_guis(entries, columns)
    local children = {}
    local count = 0

    for _, col in pairs(columns) do
        table.insert(children, {
            type = "label",
            caption = { "spelevator-log.table-header-"..col }
        })
    end

    for _, log_entry in pairs(entries) do
        create_row(log_entry, children)
        count = count + 1
    end
    return children, count
end

---Does not filter by forces because I think that is silly
---@param spelevator_log_gui GuiConfig
local function create_events_table(spelevator_log_gui)

    --- Destroys children to prevent event_contents.children from
    --- being populated with the same information because
    --- destroy_gui() does not destroy the GUI elements (yet?)
    --- and open_gui() re-calls create_events_table()
    spelevator_log_gui.events_contents.clear()
    spelevator_log_gui.summary_contents.clear()

    local columns = { "timestamp", "contents"}

    local children_guis, count = create_result_guis(storage.history, columns)


    flib_gui.add(spelevator_log_gui.events_contents, {
        {
            type = "scroll-pane",
            style = "flib_naked_scroll_pane_no_padding",
            ref = { "scroll_pane" },
            vertical_scroll_policy = "always",
            style_mods = {width = 1000, height = 600, padding = 6},
            children = {
                {
                type = "table",
                name = "events_table",
                column_count = table_size(columns),
                draw_vertical_lines = true,
                draw_horizontal_line_after_headers = true,
                vertical_centering = true,
                style_mods = {right_cell_padding = 3, left_cell_padding = 3},
                children = children_guis
                }
            }
        }
    })
end

return {
    create_events_table = create_events_table
}