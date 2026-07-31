local SpaceElevatorLogConstants = {
    unlock_tech_name = "se-space-elevator",
    window_name = "space-elevator-log-window",
    button_name = "space-elevator-log-mod-gui-button",
    button_sprite = "space-elevator-log-mod-gui-button-sprite",
    custom_input_name = "space-elevator-log-toggle-window-input"
}

---@param player LuaPlayer
function SpaceElevatorLogConstants.get_gui_id(player)
    return "gui-" .. player.name
end

return SpaceElevatorLogConstants