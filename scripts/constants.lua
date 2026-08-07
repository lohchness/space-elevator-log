local SpaceElevatorLogConstants = {
    mod_base_path = "__space-elevator-log__/",
    unlock_tech_name = "se-space-elevator",
    window_name = "space-elevator-log-window",
    button_name = "space-elevator-log-mod-gui-button",
    button_sprite = "space-elevator-log-mod-gui-button-sprite",
    custom_input_name = "space-elevator-log-toggle-window-input",
    custom_input_key_sequence = "CONTROL + H",
    space_elevator_filename = "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
    invalid_train_filename = "graphics/invalid-train.png",
    invalid_train = "space-elevator-log-invalid-train",
}

---@param player LuaPlayer
function SpaceElevatorLogConstants.get_gui_id(player)
    return "gui-" .. player.name
end

return SpaceElevatorLogConstants
