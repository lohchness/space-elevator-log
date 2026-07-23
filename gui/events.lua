local format = require("__flib__.format")
local flib_gui = require("__flib__.gui")
local time_filter = require("scripts/filter-time")
local summary = require("gui/summary")
local utils = require("scripts/utils")
local gui_handlers = require("gui/handlers")

---@param entry LogEntry
---@param events_rows table
local function create_row(entry, events_rows, gui_id)
    local relative_time = game.tick - entry.time

    local timestamp = {
        type = "label",
        caption = format.time(relative_time, true)
    }

    local train = {}
    if entry.train.valid then
        train = utils.sprite_button("item", entry.train.front_stock.prototype.name, nil, gui_id,
            gui_handlers.view_train_position, entry.train.id)
    else
        train = utils.sprite_button("virtual-signal", "signal-no-entry", nil, gui_id)
    end

    local contents_children = {}
    for _, item in pairs(entry.contents) do
        table.insert(contents_children, utils.sprite_button("item", item.name, item.count, gui_id))
    end
    for i, j in pairs(entry.fluid_contents) do
        table.insert(contents_children, utils.sprite_button("fluid", i, j, gui_id))
    end
    local contents_flow = {
        type = "flow",
        direction = "horizontal",
        children = contents_children
    }
    table.insert(events_rows, timestamp)
    table.insert(events_rows, train)
    table.insert(events_rows, contents_flow)
end

---@param log_entry LogEntry
---@param toolbar ToolbarGui
local function matches_filter(log_entry, toolbar)
    local time_period = game.tick - time_filter.ticks(toolbar.time_period.selected_index)
    if log_entry.time < time_period then return false end

    local check_item = (toolbar.selected_item ~= nil)
    local check_fluid = (toolbar.selected_fluid ~= nil)
    local matches_content = not (check_item or check_fluid)

    local check_radio = toolbar.selected_radio
    local check_empty_train = toolbar.hide_empty_trains.state

    if check_radio == "incoming" then
        if not (log_entry.to_surface == toolbar.selected_surface_index) then return false end
    elseif check_radio == "outgoing" then
        if not (log_entry.from_surface == toolbar.selected_surface_index) then return false end
    elseif check_radio == "combined" then
        -- virtual-signal/signal-input
        -- virtual-signal/signal-output
        if not (
                (log_entry.to_surface == toolbar.selected_surface_index) or
                (log_entry.from_surface == toolbar.selected_surface_index)
            ) then
            return false
        end
    end

    if check_empty_train then
        if table_size(log_entry.contents) == 0
            and table_size(log_entry.fluid_contents) == 0
        then
            return false
        end
    end

    if check_item then
        for _, i in pairs(log_entry.contents) do
            if i.name == toolbar.selected_item then
                matches_content = true
                break
            end
        end
    end
    if check_fluid then
        for i, j in pairs(log_entry.fluid_contents) do
            if i == toolbar.selected_fluid then
                matches_content = true
                break
            end
        end
    end

    return matches_content
end

---@param entries LogEntry[]
---@param columns string[]
---@return table, table, integer
local function create_events_rows(entries, toolbar, columns, gui_id)
    local events_rows = {}
    local summary_data = summary.create_new_summary() ---@type SummaryData
    local count = 0

    -- First row is column names
    for _, col in pairs(columns) do
        table.insert(events_rows, {
            type = "label",
            caption = { "spelevator-log.table-header-" .. col }
        })
    end

    for i = table_size(entries), 1, -1 do
        local log_entry = entries[i]
        if matches_filter(log_entry, toolbar) then
            create_row(log_entry, events_rows, gui_id)
            summary.add_event(summary_data, entries[i])
            count = count + 1
        end
    end
    return events_rows, summary_data, count
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
    local toolbar = spelevator_log_gui.toolbar

    --- TODO: Refactor toolbar to contain an extra table
    --- for easy access to gui elements like elem-buttons
    --- and for filters only (with gui id)
    --- to avoid atrocious gui_id drilling below

    local columns = { "timestamp", "train", "contents" }
    local events_rows, summary_data, count = create_events_rows(storage.history, toolbar, columns,
        spelevator_log_gui.gui_id)

    toolbar.display_stats.caption = { "spelevator-log.display_stats", count, table_size(storage.history) }

    flib_gui.add(spelevator_log_gui.events_contents, {
        {
            type = "scroll-pane",
            style = "flib_naked_scroll_pane_no_padding",
            ref = { "scroll_pane" },
            vertical_scroll_policy = "always",
            style_mods = { width = 650, height = 600, padding = 6 },
            children = {
                {
                    type = "table",
                    name = "events_table",
                    column_count = table_size(columns),
                    draw_vertical_lines = true,
                    draw_horizontal_line_after_headers = true,
                    vertical_centering = true,
                    style_mods = { right_cell_padding = 3, left_cell_padding = 3 },
                    children = events_rows
                }
            }
        }
    })

    local summary_children = summary.create_gui_from_data(summary_data, spelevator_log_gui.gui_id)
    flib_gui.add(spelevator_log_gui.summary_contents, {
        {
            type = "scroll-pane",
            style = "flib_naked_scroll_pane_no_padding",
            name = "scroll_pane",
            vertical_scroll_policy = "always",
            style_mods = { width = 650, height = 600, padding = 6 },
            children = {
                {
                    type = "flow",
                    direction = "vertical",
                    children = summary_children
                }
            }
        }
    })
end

return {
    create_events_table = create_events_table
}
