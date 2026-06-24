local time_filter = require("scripts/filter-time")
local gui_handlers = require("gui/handlers")
local utils = require("scripts/utils")


local function update_filters(toolbar)
    if table_size(storage.zone_by_surface) == 0 then
        return
    end

    -- Save currently selected surface before rebuilding dropdown so it can be restored if it exists
end

local function refresh(toolbar)
    toolbar.item.tooltip = (
        toolbar.item.elem_value and 
        prototypes.item[toolbar.item.elem_value] and
        prototypes.item[toolbar.item.elem_value].localised_name
    ) or ""

    update_filters(toolbar)
end

function gui_handlers.switch_view(event)
    -- TODO Figure out why this fires twice, 
    -- first with on_gui_checked_state_changed, 
    -- and next with on_gui_click
    local gui_id = event.element.tags.gui_id

    local toolbar = storage.guis[gui_id].toolbar
    for _, radio in pairs(toolbar.views.children) do
        radio.state = false
    end
    event.element.state = true

    -- local function reverse_event(id)
    -- for name, event_id in pairs(defines.events) do
    --     if id == event_id then
    --     return name
    --     end
    -- end
    -- end
    -- game.players[event.player_index].print(reverse_event(event.name))

    refresh(toolbar)
end


local function create_toolbar(gui_id)
    return {
        type = "flow",
        direction = "vertical",
        name = "toolbar",

        children = {
            {
                type = "flow",
                direction = "horizontal",
                name = "row1",

                children = {
                    {
                        type = "sprite",
                        sprite = "rocket-log-clock-white",
                    },

                    {
                        type = "drop-down",
                        name = "filter_time_period",
                        items = time_filter.time_period_items,
                        selected_index = time_filter.default_index,
                        tooltip = { "spelevator-log.filter-time-period-label" },
                        handler = gui_handlers.refresh,
                    },

                    {
                        type = "sprite-button",
                        sprite = "utility/refresh",
                        style = "item_and_count_select_confirm",
                        tooltip = { "spelevator-log.refresh" },
                        handler = gui_handlers.refresh,
                    },
                },
            },
            {
                type = "flow",
                direction = "horizontal",
                name = "row2",

                children = {
                    {
                        type = "sprite-button",
                        sprite = "entity/se-space-elevator",
                        tooltip = "spelevator-log.filter-surface-label",
                    },
                    {
                        type = "drop-down",
                        name = "filter_zone_list",
                        items = {},
                        selected_index = 0,
                        handler = gui_handlers.refresh,
                    },

                    {
                        type = "sprite",
                        sprite = "utility/search",
                        tooltip = { "spelevator-log.filter-item-label" },
                    },
                    {
                        type = "choose-elem-button",
                        elem_type = "item",
                        name="filter_item",
                        handler = gui_handlers.refresh,
                    }
                }
            },
            {
                type = "flow",
                direction = "horizontal",
                name = "row3",

                children = {
                    {
                        type = "radiobutton",
                        state = "true",
                        name = "incoming",
                        caption = { "spelevator-log.incoming" },
                        handler = gui_handlers.switch_view,
                        tags = {gui_id = gui_id},
                    },
                    {
                        type = "radiobutton",
                        state = "false",
                        name = "outgoing",
                        caption = { "spelevator-log.outgoing" },
                        handler = gui_handlers.switch_view,
                        tags = {gui_id = gui_id},
                    },
                    {
                        type = "radiobutton",
                        state = "false",
                        name = "combined",
                        caption = { "spelevator-log.combined" },
                        handler = gui_handlers.switch_view,
                        tags = {gui_id = gui_id},
                    },
                }
            }
        }
    }
end

return {
    create_toolbar = create_toolbar,
    refresh = refresh,
}