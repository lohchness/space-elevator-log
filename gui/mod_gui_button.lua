local mod_gui = require("__core__.lualib.mod-gui")
local flib_gui = require("__flib__.gui")
local gui_handlers = require("gui/handlers")
local constants = require("scripts/constants")

---@param player LuaPlayer
local function remove_mod_gui_button(player)
    local flow = mod_gui.get_button_flow(player)

    for _, i in pairs(flow.children) do
        if i.name == constants.button_name then
            i.destroy()
        end
    end
end

---@param player LuaPlayer
local function add_mod_gui_button(player)
    if not player.force.technologies[constants.unlock_tech_name].researched then return end

    local flow = mod_gui.get_button_flow(player)
    if flow[constants.button_name] then return end

    flib_gui.add(
        flow,
        {
            type = "sprite-button",
            name = constants.button_name,
            style = "flib_slot_button_default",
            sprite = constants.button_sprite,
            handler = gui_handlers.mod_gui_button_click,
            tooltip = { "spelevator-log.mod-gui-tooltip" }
        }
    )
end

---@param player LuaPlayer
local function refresh_mod_gui_button(player)
    remove_mod_gui_button(player)
    add_mod_gui_button(player)
end

local function bulk_refresh_mod_gui_button()
    for _, player in pairs(game.players) do
        refresh_mod_gui_button(player)
    end
end

---@param event EventData.on_player_joined_game
script.on_event(defines.events.on_player_joined_game, function(event)
    refresh_mod_gui_button(game.players[event.player_index])
end)

---@param event EventData.on_research_finished
script.on_event(defines.events.on_research_finished, function(event)
    if event.research.name == constants.unlock_tech_name then
        bulk_refresh_mod_gui_button()
    end
end)

---@param event EventData.on_research_reversed
script.on_event(defines.events.on_research_reversed, function(event)
    if event.research.name == constants.unlock_tech_name then
        bulk_refresh_mod_gui_button()
    end
end)

return {
    add_mod_gui_button = add_mod_gui_button,
    remove_mod_gui_button = remove_mod_gui_button,
    refresh_mod_gui_button = refresh_mod_gui_button,
    bulk_refresh_mod_gui_button = bulk_refresh_mod_gui_button,
}
