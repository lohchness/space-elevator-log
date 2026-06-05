local time_filter = require("scripts/filter-time")
local gui_handlers = {}
local utils = require("scripts/utils")


local function update_filters(filter_guis)
    -- local old_surface = filter_guis.surface_list.get_item(filter_guis.surface_list.selected_index)
    -- local new_surface_index = 1

    -- for k,v in pairs(storage.surfaces) do
    --     if old_surface == k then
    --         new_surface_index = 
    --     end
    -- end

    if table_size(storage.surfaces) == 0 then
        return
    end

    -- Save currently selected surface before rebuilding dropdown so it can be restored if it exists
    -- local old_selected_index = storage.surfaces.get_item()
    local new_surface_index = 0
    local old_selected_surface_name = filter_guis.surface_list.selected_name

    local new_surface_list = {}
    for planet, orbit in pairs(storage.surfaces) do
        table.insert(new_surface_list, utils.title(planet))
    end

    for index, surface in pairs(new_surface_list) do
        if old_selected_surface_name and old_selected_surface_name:lower() == surface:lower() then
            new_surface_index = index
        end
    end

    filter_guis.surface_list.items = new_surface_list
    filter_guis.surface_list.selected_index = new_surface_index
end

local function refresh(filter_guis)
    filter_guis.item.tooltip = (
        filter_guis.item.elem_value and 
        prototypes.item[filter_guis.item.elem_value] and
        prototypes.item[filter_guis.item.elem_value].localised_name
    ) or ""

    update_filters(filter_guis)
end


local function create_toolbar()
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
                        name = "filter_surface_list",
                        items = {},
                        -- selected_name = "",
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
            }
        }
    }
end

return {
    create_toolbar = create_toolbar,
    refresh = refresh,
}