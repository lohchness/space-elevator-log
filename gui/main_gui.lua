local flib_gui = require("__flib__.gui")
local Toolbar = require("gui/toolbar")
local gui_handlers = require("gui/handlers")
local constants = require("scripts/constants")


---Create Header GuiELemDef for flib
---@param gui_id string
---@return flib.GuiElemDef
local function header(gui_id)
    return {
        type = "flow",
        name = "titlebar",
        children = {
            { type = "label",        style = "frame_title",               caption = { "se-log.header" }, ignored_by_interaction = true },
            { type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true },
            {
                type = "sprite-button",
                style = "frame_action_button",
                sprite = "utility/close",
                hovered_sprite = "utility/close_black",
                clicked_sprite = "utility/close_black",
                handler = gui_handlers.close_window,
                tags = {
                    gui_id = gui_id
                }
            }
        }
    }
end


--- @param player LuaPlayer
local function open_gui(player)
    local gui_id = "gui-" .. player.name
    if not storage.guis[gui_id] then
        ---@type flib.GuiElemDef[]
        local gui_contents = {
            {
                type = "frame",
                direction = "vertical",
                name = constants.window_name,
                children = {
                    header(gui_id),
                    Toolbar.create_toolbar(gui_id),
                    {
                        type = "tabbed-pane",
                        name = "tabs_pane",
                        children = {
                            {
                                tab = {
                                    type = "tab",
                                    caption = { "se-log.tab-events" }
                                },
                                content = {
                                    type = "flow",
                                    direction = "vertical",
                                    name = "events_contents"
                                }
                            },
                            {
                                tab = {
                                    type = "tab",
                                    caption = { "se-log.tab-summary" }
                                },
                                content = {
                                    type = "flow",
                                    direction = "vertical",
                                    name = "summary_contents"
                                }
                            }
                        }
                    },
                }
            }
        }
        ---@type table<string,LuaGuiElement>, LuaGuiElement
        local _, new_gui = flib_gui.add(player.gui.screen, gui_contents)
        log(new_gui.name)
        ---@type sel.ToolbarState
        local toolbar_state = {
            time_period = new_gui.toolbar.row1.filter_time_period,
            display_stats = new_gui.toolbar.row1.display_stats,
            zone_list = new_gui.toolbar.row2.filter_zone_list,
            radios = new_gui.toolbar.row3,
            filter_item_button = new_gui.toolbar.row2.filter_item,
            filter_fluid_button = new_gui.toolbar.row2.filter_fluid,
            selected_zone_index = 0,
            selected_radio = new_gui.toolbar.row3.incoming.name,
            hide_empty_trains = new_gui.toolbar.row3.hide_empty_trains,
            selected_item = nil,
            selected_fluid = nil,
            group_by_list = new_gui.toolbar.row3.groupby,
        }
        ---@type sel.GuiState
        storage.guis[gui_id] = {
            gui_id = gui_id,
            gui = new_gui,
            player = player,
            toolbar = toolbar_state,
            events_contents = new_gui.tabs_pane.events_contents,
            summary_contents = new_gui.tabs_pane.summary_contents
        }
    end

    local gui_state = storage.guis[gui_id]
    if player.opened and player.opened ~= gui_state.gui then
        player.opened = nil
    end

    gui_state.gui.visible = true
    gui_state.gui.titlebar.drag_target = gui_state.gui
    gui_state.gui.force_auto_center()
    player.opened = gui_state.gui

    Toolbar.refresh(gui_state)
end


---@param player LuaPlayer
local function close_player_gui(player)
    local gui_id = constants.get_gui_id(player)
    if storage.guis[gui_id] then
        storage.guis[gui_id].gui.visible = false
    end
end


---@param player LuaPlayer
local function open_or_close_gui(player)
    local gui_id = constants.get_gui_id(player)
    if storage.guis[gui_id] and storage.guis[gui_id].gui.visible then
        storage.guis[gui_id].player.opened = nil
    else
        open_gui(player)
    end
end


function gui_handlers.close_window(event)
    local gui_id = event.element.tags.gui_id
    storage.guis[gui_id].player.opened = nil
end

function gui_handlers.mod_gui_button_click(event)
    local player = game.players[event.player_index]
    open_or_close_gui(player)
end

---@param event EventData.on_lua_shortcut
script.on_event(constants.custom_input_name, function(event)
    open_or_close_gui(game.players[event.player_index])
end)


--- Triggered by player.opened = nil
---@param event EventData.on_gui_closed
script.on_event(defines.events.on_gui_closed, function(event)
    local player = game.players[event.player_index]
    if player and event.element and event.element.name == constants.window_name then
        close_player_gui(player)
    end
end)


---@param event EventData.on_gui_click
function gui_handlers.view_train_position(event)
    ---@diagnostic disable-next-line param-type-mismatch
    local train = game.train_manager.get_train_by_id(event.element.tags.train_id)
    local player = game.players[event.player_index]

    if not player then return end
    if not train then
        player.print("Train not valid anymore")
        toolbar.refresh(constants.get_gui_id(player))
        return
    end

    local gui_id = constants.get_gui_id(player)
    storage.guis[gui_id].player.opened = nil
    player.opened = train.front_stock
end

flib_gui.add_handlers(gui_handlers, function(e, handler) handler(e) end)


return {
    open_or_close_gui = open_or_close_gui,
    close_player_gui = close_player_gui,
}
