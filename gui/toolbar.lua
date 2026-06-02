local time_filter = require("scripts/filter-time")
local gui_handlers = {}

local function create_toolbar()
    return {
        type = "flow",
        direction = "vertical",
        name = "toolbar",

        children = {
            type = "flow",
            direction = "horizontal",

            children = {
                {
                    type = "sprite",
                    sprite = "spelevator-log-clock-white",
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

            {
                type = "flow",
                direction = "horizontal",

                children = {
                    {
                        type = "sprite-button",
                        sprite = "entity/se-space-elevator",
                        tooltip = "spelevator.filter-surface-label",
                    },
                    {
                        type = "drop-down",
                        name = "filter_surface_list",
                        items = {},
                        selected_index = 1,
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
            }
        }
    }
end

return {
    create_toolbar = create_toolbar
}