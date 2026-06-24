local tables =  require("__flib__.table")
local format = require("__flib__.format")
local util = require("util")
local flib_gui = require("__flib__.gui")
local spelevator_log_gui = require("gui/main_gui")
local utils = require("scripts/utils")
local mod_gui_button = require("gui/mod_gui_button")

function destroy_player_gui()
    -- game.get_player(data.player_index).gui.screen.children['spelevator-log-window'].destroy()  
    local c = game.player.gui.screen.children
    for _, i in pairs(c) do
        if i.name == 'spelevator-log-window' then
            i.destroy()
        end
    end

    mod_gui_button.add_mod_gui_button(game.player)

    reset_storage()
end

--- Surface Index differs from Zone Index.
--- Zone Index is the surface order starting from Calidus Orbit, 
--- then the first planet and its orbit, its moon (if any) and its orbit, 
--- and so on to the next star system,
--- whereas Surface Index increments on exploring a new surface.
--- /c game.print("Zone Index: "..serpent.block(
--- remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = game.player.surface.index}).index
--- ))
function reset_storage()
    for gui_id, gui_data in pairs(storage.guis) do
        gui_data.gui.destroy()
    end

    storage = {}
    ---@type table<string, GuiConfig>
    storage.guis = {}
    ---@type LogEntry[]
    storage.history = {}
    ---@type table<int, ElevatorZone>
    storage.zone_by_surface = {}
end

function check_storage()
    if not next(storage) then
        game.player.print("storage not initiated")
        return
    end
    game.player.print("History: "..table_size(storage.history).." entries")
    game.player.print("Surfaces: "..table_size(storage.zone_by_surface).." entries")
    game.player.print("Storage: "..table_size(storage.guis).." entries")
    -- game.player.print(serpent.dump(storage.zone_by_surface))
end

function print_last_entry()
    ---@type LogEntry
    local entry = storage.history[table_size(storage.history)]

    game.player.print(format.time(game.tick - entry.time, true).." ago")
    game.player.print("Contents:")
    for _,item in pairs(entry.contents) do
        game.player.print(item.name..": "..item.count)
    end

    game.player.print("Remaining Stops:")
    if entry.records then
        for _,record in pairs(entry.records) do
            game.player.print(record.station)
        end
    else
        print("No Records")
    end
    
end

function clear_storage_surfaces()
    storage.zone_by_surface = {}
end

function print_storage_surfaces()
    if table_size(storage.zone_by_surface) == 0 then
        game.player.print("Storage zone by surface is empty")
    end
    for i, j in pairs(storage.zone_by_surface) do
        -- game.player.print(j.name..", "..j.type..", "..j.zone_index)
        game.player.print(
            serpent.block(j, { compact=true })
        )
    end 
end

local function store_zone_pair(planet_surface_index, orbit_surface_index)
    --- Store zones from SE remote interface, with the key being surface index.
    --- Easier lookup, will still have to sort by zone index in toolbar drop down list.

    if storage.zone_by_surface[planet_surface_index] then
        assert(storage.zone_by_surface[orbit_surface_index])
        return
    end

    ---@type SEZoneType
    local planet_zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = planet_surface_index})
    ---@type SEZoneType
    local orbit_zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = orbit_surface_index})

    storage.zone_by_surface[planet_surface_index] = {
        name = utils.title(planet_zone.name),
        type = planet_zone.type,
        zone_index = planet_zone.index,
        surface_index = planet_surface_index,
        opposite = nil,
    }
    storage.zone_by_surface[orbit_surface_index] = {
        name = utils.title(orbit_zone.name),
        type = orbit_zone.type,
        zone_index = orbit_zone.index,
        surface_index = orbit_surface_index,
        opposite = storage.zone_by_surface[planet_surface_index],
    }
    storage.zone_by_surface[planet_surface_index].opposite = storage.zone_by_surface[orbit_surface_index]
end


---@param event TrainTeleportStartedEvent
function on_teleport_started(event)
    return
end


---@param event TrainTeleportFinishedEvent
function AddTrainLog(event) 
    ---@type LogEntry
    ---@diagnostic disable-next-line: missing-fields
    local log_entry = {
        time = game.tick,
        train = event.train,
        contents = event.train.get_contents(),
        teleporter_id = event.teleporter.unit_number
    }

    local schedule = event.train.get_schedule()
    local records = schedule.get_records()
    if records then
        log_entry.records = records
        log_entry.current = schedule.current
    end

    --- Insert surface names into storage here instead of iterating 
    --- every entry upon opening GUI because train logs will be very large.
    --- @type SpaceElevatorInfo
    local space_elevator_info = remote.call("space-exploration", "get_space_elevator_info", event.teleporter)

    log_entry.from_surface = space_elevator_info.opposite.surface_index
    log_entry.to_surface = space_elevator_info.main.surface_index
    local surface_name = utils.title(space_elevator_info.main.surface.name)
    -- local opposite_surface_name = utils.title(space_elevator_info.opposite.surface.name)

    if surface_name:find("Orbit") then
        store_zone_pair(space_elevator_info.opposite.surface_index, space_elevator_info.main.surface.index)
    else
        store_zone_pair(space_elevator_info.main.surface.index, space_elevator_info.opposite.surface_index)
    end

    table.insert(storage.history, log_entry)
end

-- function init_events()
--     script.on_event(defines.events.se_on_train_teleport_finished, AddTrainLog)
-- end

script.on_init(reset_storage)
-- script.on_load(init_events)
script.on_event(defines.events.se_on_train_teleport_finished, AddTrainLog)

-- For Custom Input defined in data.lua
script.on_event("open-custom-input", function (event)
    spelevator_log_gui.open_or_close_gui(game.players[event.player_index])
end)

commands.add_command("sl_reset_storage", nil, reset_storage)
commands.add_command("sl_check_storage", nil, check_storage)
commands.add_command("sl_last_entry", nil, print_last_entry)
commands.add_command("sl_print_storage_surfaces", nil, print_storage_surfaces)
commands.add_command("sl_destroy_existing_gui_element_in_parent", nil, destroy_player_gui)
commands.add_command("sl_clear_storage_surfaces", nil, clear_storage_surfaces)


flib_gui.handle_events()