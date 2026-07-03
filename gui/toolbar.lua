local time_filter = require("scripts/filter-time")
local gui_handlers = require("gui/handlers")
local events_table = require("gui/events")
local utils = require("scripts/utils")

---@param toolbar ToolbarGui
local function update_filters(toolbar)
    if table_size(storage.zone_by_surface) == 0 then
        return
    end

    -- Handle first time opening when selected_surface_index is 0
    if toolbar.selected_surface_index == 0 then
        for i, _ in pairs(storage.zone_by_surface) do
            toolbar.selected_surface_index = i
            break
        end
    end

    -- Save currently selected surface before rebuilding dropdown so it can be restored if it exists
    local old_index = toolbar.zone_list.selected_index
    local old_selected =
        toolbar.zone_list.items and
        old_index ~= 0 and
        toolbar.zone_list.get_item(old_index)
        or 1

    local new_index = 1

    local new_zone_list = {}
    local count = 1
    for i, j in pairs(storage.zone_by_surface) do
        table.insert(new_zone_list, j.name)
        if j.name == old_selected then
            new_index = count
            toolbar.selected_surface_index = i
        end
        count = count + 1
    end

    toolbar.zone_list.items = new_zone_list
    toolbar.zone_list.selected_index = new_index
end

local function update_toolbar(toolbar)
    toolbar.item.tooltip = (
        toolbar.item.elem_value and 
        prototypes.item[toolbar.item.elem_value] and
        prototypes.item[toolbar.item.elem_value].localised_name
    ) or ""

    update_filters(toolbar)
end

local function refresh(gui_config)
    update_toolbar(gui_config.toolbar)
    events_table.create_events_table(gui_config)
end

function gui_handlers.select_radio(event)
    local gui_id = event.element.tags.gui_id
    local gui_config = storage.guis[gui_id]

    local toolbar = gui_config.toolbar
    for _, radio in pairs(toolbar.radios.children) do
        radio.state = false
    end
    event.element.state = true
    toolbar.selected_radio = event.element.name

    refresh(gui_config)
end

function gui_handlers.refresh_handler(event)
    refresh(storage.guis[event.element.tags.gui_id])
end

function gui_handlers.select_item(event)
    local gui_config = storage.guis[event.element.tags.gui_id]
    gui_config.toolbar.selected_item = nil

    if event.element.elem_value then
        gui_config.toolbar.selected_item = event.element.elem_value

        event.element.parent.filter_fluid.elem_value = nil
        gui_config.toolbar.selected_fluid = nil
    end

    refresh(gui_config)
end

function gui_handlers.select_fluid(event)
    local gui_config = storage.guis[event.element.tags.gui_id]

    gui_config.toolbar.selected_fluid = nil
    if event.element.elem_value then
        gui_config.toolbar.selected_fluid = event.element.elem_value

        event.element.parent.filter_item.elem_value = nil
        gui_config.toolbar.selected_item = nil
    end

    refresh(gui_config)
end

function gui_handlers.set_filter_sprite_button(event)
    local gui_config = storage.guis[event.element.tags.gui_id]

    if event.alt and event.button == defines.mouse_button_type.left then return end

    gui_config.toolbar.selected_item = nil
    gui_config.toolbar.selected_fluid = nil
    gui_config.toolbar.filter_item_button.elem_value = nil
    gui_config.toolbar.filter_fluid_button.elem_value = nil

    if event.element.tags.item_type == "item" then
        gui_config.toolbar.selected_item = event.element.tags.name
        gui_config.toolbar.filter_item_button.elem_value = event.element.tags.name
    elseif event.element.tags.item_type == "fluid" then
        gui_config.toolbar.selected_fluid = event.element.tags.name
        gui_config.toolbar.filter_fluid_button.elem_value = event.element.tags.name
    end
    refresh(gui_config)
end

local function create_toolbar(gui_id)
    local radio_handler = {[defines.events.on_gui_checked_state_changed] = gui_handlers.select_radio}
    local drop_down_handler = {[defines.events.on_gui_selection_state_changed] = gui_handlers.refresh_handler}
    local select_item_handler = {[defines.events.on_gui_elem_changed] = gui_handlers.select_item}
    local select_fluid_handler = {[defines.events.on_gui_elem_changed] = gui_handlers.select_fluid}
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
                        handler = drop_down_handler,
                        tags = {gui_id = gui_id},
                    },
                    {
                        type = "sprite-button",
                        sprite = "utility/refresh",
                        style = "item_and_count_select_confirm",
                        tooltip = { "spelevator-log.refresh" },
                        handler = gui_handlers.refresh_handler,
                        tags = {gui_id = gui_id},
                    },
                },
            },
            {
                type = "flow",
                direction = "horizontal",
                name = "row2",

                children = {
                    {
                        type = "sprite",
                        sprite = "entity/se-space-elevator",
                        tooltip = { "spelevator-log.filter-surface-label" },
                    },
                    {
                        type = "drop-down",
                        name = "filter_zone_list",
                        items = {},
                        handler = drop_down_handler,
                        tags = {gui_id = gui_id},
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
                        handler = select_item_handler,
                        tags = {gui_id = gui_id},
                    },
                    {
                        type = "choose-elem-button",
                        elem_type = "fluid",
                        name="filter_fluid",
                        handler = select_fluid_handler,
                        tags = {gui_id = gui_id},
                    },
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
                        handler = radio_handler,
                        tags = {gui_id = gui_id},
                    },
                    {
                        type = "radiobutton",
                        state = "false",
                        name = "outgoing",
                        caption = { "spelevator-log.outgoing" },
                        handler = radio_handler,
                        tags = {gui_id = gui_id},
                    },
                    {
                        type = "radiobutton",
                        state = "false",
                        name = "combined",
                        caption = { "spelevator-log.combined" },
                        handler = radio_handler,
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