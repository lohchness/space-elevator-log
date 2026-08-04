local format = require("__flib__.format")
local flib_gui = require("__flib__.gui")
local spelevator_log_gui = require("gui/main_gui")
local constants = require("scripts/constants")
local utils = require("scripts/utils")
local mod_gui_button = require("gui/mod_gui_button")

--- Destroys any splog gui elements and refreshes mod gui button.
---@param player LuaPlayer
local function reset_player_gui(player)
    for _, gui in pairs(player.gui.screen.children) do
        if gui.name == constants.window_name then
            gui.destroy()
        end
    end

    local gui_id = constants.get_gui_id(player)
    storage.guis[gui_id] = nil

    mod_gui_button.remove_mod_gui_button(player)
    mod_gui_button.add_mod_gui_button(player)
end


local function bulk_reset_player_gui()
    for _, player in pairs(game.players) do
        reset_player_gui(player)
    end
end

--- Surface Index differs from Zone Index.
--- Zone Index is SE's surface order starting from Calidus Orbit,
--- then the first planet and its orbit, its moon (if any) and its orbit,
--- and so on to the next star system,
--- whereas Surface Index increments on exploring a new surface.
--- Surface Index can be reused if the surface is deleted and a new surface is generated.
--- /c game.print("Zone Index: "..serpent.block(
--- remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = game.player.surface.index}).index
--- ))

--- Destroys any gui elements and all storage data.
local function destroy_storage()
    for _, gui in pairs(game.player.gui.screen.children) do
        if gui.name == constants.window_name then
            gui.destroy()
        end
    end

    storage = {}
    ---@type table<string, GuiConfig>
    storage.guis = {}
    ---@type LogEntry[]
    storage.history = {}
    ---@type table<int, ElevatorZone>
    storage.zones = {}
end


local function reset_all()
    bulk_reset_player_gui()
    destroy_storage()
end


function check_storage()
    if not next(storage) then
        game.player.print("storage not initiated")
        return
    end
    game.player.print("History: " .. table_size(storage.history) .. " entries")
    game.player.print("Surfaces: " .. table_size(storage.zones) .. " entries")
    game.player.print("Storage: " .. table_size(storage.guis) .. " entries")
end

function print_last_entry()
    ---@type LogEntry
    local entry = storage.history[table_size(storage.history)]

    game.player.print(format.time(game.tick - entry.time, true) .. " ago")
    game.player.print("Contents:")
    for _, item in pairs(entry.contents) do
        game.player.print(item.name .. ": " .. item.count)
    end

    game.player.print("Remaining Stops:")
    if entry.records then
        for _, record in pairs(entry.records) do
            game.player.print(record.station)
        end
    else
        print("No Records")
    end
end

function clear_storage_surfaces()
    storage.zones = {}
end

function print_storage_surfaces()
    if table_size(storage.zones) == 0 then
        game.player.print("Storage zones empty")
    end
    for i, j in pairs(storage.zones) do
        -- game.player.print(j.name..", "..j.type..", "..j.zone_index)
        game.player.print(
            serpent.block(j, { compact = true })
        )
    end
end

---Storing as a pair to ensure entries have a start and end zone
---@param solid_zone SEZoneType
---@param orbit_zone SEZoneType
local function store_solid_orbit_pair(solid_zone, orbit_zone)
    --- Store zones from SE remote interface, with the key being zone index.

    if storage.zones[solid_zone.index] then
        assert(storage.zones[orbit_zone.index])
        return
    end

    storage.zones[solid_zone.index] = {
        name = utils.title(solid_zone.name),
        type = solid_zone.type,
        zone_index = solid_zone.index,
        surface_index = solid_zone.surface_index,
        opposite = nil, ---@diagnostic disable-line: assign-type-mismatch
    }
    storage.zones[orbit_zone.index] = {
        name = utils.title(orbit_zone.name),
        type = orbit_zone.type,
        zone_index = orbit_zone.index,
        surface_index = orbit_zone.surface_index,
        opposite = storage.zones[solid_zone.index],
    }
    storage.zones[solid_zone.index].opposite = storage.zones[orbit_zone.index]
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
        fluid_contents = event.train.get_fluid_contents(),
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

    ---@type SEZoneType
    local from_zone = remote.call("space-exploration", "get_zone_from_surface_index",
        { surface_index = space_elevator_info.main.surface_index })
    ---@type SEZoneType
    local to_zone = remote.call("space-exploration", "get_zone_from_surface_index",
        { surface_index = space_elevator_info.opposite.surface_index })

    log_entry.from_zone = from_zone.index
    log_entry.to_zone = to_zone.index
    local surface_name = utils.title(from_zone.name)
    -- local opposite_surface_name = utils.title(space_elevator_info.opposite.surface.name)

    if surface_name:find("Orbit") then
        store_solid_orbit_pair(to_zone, from_zone)
    else
        store_solid_orbit_pair(from_zone, to_zone)
    end

    table.insert(storage.history, log_entry)
end

--- Migration applied, startup setting changed, prototypes changed, mod changed, game/mod version changed.
---@param config ConfigurationChangedData
local function on_configuration_changed(config)
    bulk_reset_player_gui()
end
script.on_configuration_changed(on_configuration_changed)


script.on_init(destroy_storage)
script.on_event(defines.events.se_on_train_teleport_finished, AddTrainLog)

commands.add_command("sl_destroy_storage", nil, destroy_storage)
commands.add_command("sl_check_storage", nil, check_storage)
commands.add_command("sl_last_entry", nil, print_last_entry)
commands.add_command("sl_print_storage_surfaces", nil, print_storage_surfaces)
commands.add_command("sl_reset_player_gui", nil, function() reset_player_gui(game.player) end)
commands.add_command("sl_clear_storage_surfaces", nil, clear_storage_surfaces)
commands.add_command("sl_reset_all", nil, reset_all)


flib_gui.handle_events()
