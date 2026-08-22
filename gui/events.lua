local format = require("__flib__.format")
local flib_gui = require("__flib__.gui")
local time_filter = require("scripts/filter-time")
local summary = require("gui/summary")
local filter_group = require("scripts/filter-group")


---@param entry sel.LogEntry
---@param events_rows table
---@param columns sel.GroupColumn[]
---@param gui_id string
local function create_row(entry, events_rows, columns, gui_id)
    for _, col in pairs(columns) do
        table.insert(events_rows, col.render(entry, gui_id))
    end
end


---@param log_entry sel.LogEntry
---@param toolbar_state sel.ToolbarState
local function matches_filter(log_entry, toolbar_state)
    local check_item = (toolbar_state.selected_item ~= nil)
    local check_fluid = (toolbar_state.selected_fluid ~= nil)
    local matches_content = not (check_item or check_fluid)

    local check_radio = toolbar_state.selected_radio
    local check_empty_train = toolbar_state.hide_empty_trains.state

    if check_radio == "incoming" then
        if not (log_entry.to_zone == toolbar_state.selected_zone_index) then return false end
    elseif check_radio == "outgoing" then
        if not (log_entry.from_zone == toolbar_state.selected_zone_index) then return false end
    elseif check_radio == "combined" then
        -- virtual-signal/signal-input
        -- virtual-signal/signal-output
        if not (
                (log_entry.to_zone == toolbar_state.selected_zone_index) or
                (log_entry.from_zone == toolbar_state.selected_zone_index)
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
            if i.name == toolbar_state.selected_item then
                matches_content = true
                break
            end
        end
    end
    if check_fluid then
        for i, j in pairs(log_entry.fluid_contents) do
            if i == toolbar_state.selected_fluid then
                matches_content = true
                break
            end
        end
    end

    return matches_content
end


---@param entries sel.LogEntry[]
---@param toolbar_state sel.ToolbarState
---@param group_def sel.GroupByDef
---@param gui_id string
---@return table, table, integer
local function create_events_rows(entries, toolbar_state, group_def, gui_id)
    local events_rows = {}
    local summary_data = summary.create_new_summary() ---@type sel.Summary
    local count = 0

    -- First row is column names
    for _, col in pairs(group_def.columns) do
        table.insert(events_rows, {
            type = "label",
            caption = col.caption,
        })
    end

    local time_period = game.tick - time_filter.ticks(toolbar_state.time_period.selected_index)
    for i = table_size(entries), 1, -1 do
        local log_entry = entries[i]
        if log_entry.time < time_period then
            break
        end
        if matches_filter(log_entry, toolbar_state) then
            create_row(log_entry, events_rows, group_def.columns, gui_id)
            summary.add_event(summary_data, log_entry)
            count = count + 1
        end
    end
    return events_rows, summary_data, count
end

---Does not filter by forces because I think that is silly
---@param gui_state sel.GuiState
local function create_events_table(gui_state)
    --- Destroys children to prevent persistent data when refreshing
    gui_state.events_contents.clear()
    gui_state.summary_contents.clear()

    local toolbar_state = gui_state.toolbar

    --- TODO: Refactor toolbar to contain an extra table
    --- for easy access to gui elements like elem-buttons
    --- and for filters only (with gui id)
    --- to avoid atrocious gui_id drilling below

    ---@type sel.GroupByDef
    local group_def = filter_group.get_group_columns(gui_state.toolbar.group_by_list.selected_index)
    local events_rows, summary_data, count = create_events_rows(storage.history, toolbar_state, group_def,
        gui_state.gui_id)

    toolbar_state.display_stats.caption = { "se-log.display_stats", count, table_size(storage.history) }

    flib_gui.add(gui_state.events_contents, {
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
                    column_count = table_size(group_def.columns),
                    draw_vertical_lines = true,
                    draw_horizontal_line_after_headers = true,
                    vertical_centering = true,
                    style_mods = { right_cell_padding = 3, left_cell_padding = 3 },
                    children = events_rows
                }
            }
        }
    })

    local summary_children = summary.create_gui_from_data(summary_data, gui_state.gui_id)
    flib_gui.add(gui_state.summary_contents, {
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
