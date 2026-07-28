local SpaceElevatorLogConstants = {
    unlock_tech_name = "se-space-elevator",
    root_gui_name = "space-elevator-log-window",
}


---@param player LuaPlayer
function SpaceElevatorLogConstants.get_gui_id(player)
    return "gui-" .. player.name
end

return SpaceElevatorLogConstants