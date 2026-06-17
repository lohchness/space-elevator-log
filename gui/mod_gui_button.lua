local mod_gui = require("__core__.lualib.mod-gui")
local flib_gui = require("__flib__.gui")
local gui_handlers = require("gui/handlers")

--- This must be loaded with require() AFTER main_gui for gui_handlers.mod_gui_button_click

local UNLOCK_TECH_NAME = "se-space-elevator"

local function add_mod_gui_button(player)
    local flow = mod_gui.get_button_flow(player)

    if flow.space_elevator_log then return end

    flib_gui.add(
        flow,
        {
            type = "sprite-button",
            name = "space_elevator_log",
            style = "flib_slot_button_default",
            sprite = "space-elevator-log-gui-button",
            handler = gui_handlers.mod_gui_button_click,
            tooltip = { "spelevator-log.mod-gui-tooltip" }
        }
    )
end

return {
    add_mod_gui_button = add_mod_gui_button
}