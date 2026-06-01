local tables =  require("__flib__.table")
local format = require("__flib__.format")
local util = require("util")
local flib_gui = require("__flib__.gui")
local spelevator_log_gui = require("gui/main_gui")

function reset_storage()
    storage = {}
    ---@type table<string, GuiConfig>
    storage.guis = {}
    ---@type LogEntry[]
    storage.history = {}
    -- storage.trains = {}
end

function check_storage()
    if not next(storage) then
        game.print("storage.guis not initiated")
        return
    end
    game.print(table_size(storage.history))
end

function print_last_entry()
    ---@type LogEntry
    local entry = storage.history[table_size(storage.history)]

    game.print(format.time(game.tick - entry.time, true).." ago")
    game.print("Contents:")
    for _,item in pairs(entry.contents) do
        game.print(item.name..": "..item.count)
    end

    game.print("Remaining Stops:")
    if entry.schedule then
        local records = entry.schedule.get_records()
        for _,record in pairs(records) do
            game.print(record.station)
        end
    end
    
end

-- defines.events.se_on_train_teleport_started
--[[
Event data:
      {
        train = carriage_new_train, -- newly created train consisting of the first carriage to be transferred
        old_train_id_1 = struct.old_train_id, -- id of train behind which is about to be invalidated
        old_surface_index = struct.surface.index,
        teleporter = struct.main -- space elevator entity doing the transferring
      })
]]


-- defines.events.se_on_train_teleport_finished
--[[
Event data:
      {
        train = carriage_ahead.train, -- fully built newly created train post transfer
        old_train_id_1 = struct.old_train_id, -- id of the train prior to transer start
        stranded = elevator.train_behind, --optional: only if train is split due to incomplete transfer
        old_surface_index = struct.surface.index,
        teleporter = struct.main, -- space elevator entity doing the transferring
      })
]]
---@param event TrainTeleportFinishedEvent
function AddTrainLog(event) 
    game.print("Inserting log entry")

    local schedule = util.table.deepcopy(event.train.get_schedule())
    ---@type LogEntry
    ---@diagnostic disable-next-line: missing-fields
    local log_entry = {
        time = game.tick,
        train = event.train,
        contents = event.train.get_contents(), -- is a new copy
        teleporter = event.teleporter
    }

    if schedule then
        log_entry.schedule = schedule
        log_entry.current = schedule.current
    end

    -- game.print(event.train)
    -- local train = game.train_manager.get_train_by_id(event.train)
    -- local contents = event.train.get_contents()
    -- for i,_ in pairs(contents) do
    --     game.print(contents[i].name.." "..contents[i].count)
    -- end
    
    table.insert(storage.history, log_entry)
end

-- function init_events()
--     script.on_event(defines.events.se_on_train_teleport_finished, AddTrainLog)
-- end

script.on_init(reset_storage)
-- script.on_load(init_events)
script.on_event(defines.events.se_on_train_teleport_finished, AddTrainLog)

-- For Custom Input defined in data.lua
script.on_event("space-log-open", function (event)
    spelevator_log_gui.open_or_close_gui(game.players[event.player_index])
end)

commands.add_command("sl_reset_storage", nil, reset_storage)
commands.add_command("sl_check_storage", nil, check_storage)
commands.add_command("sl_last_entry", nil, print_last_entry)


flib_gui.handle_events()