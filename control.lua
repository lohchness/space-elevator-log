local tables =  require("__flib__.table")
local format = require("__flib__.format")
local util = require("util")

script.on_init(reset_storage)

function reset_storage()
    storage = {}
    storage.guis = {}
    storage.history = {}
    storage.trains = {}
end

function check_storage()
    if not next(storage) then
        game.print("storage.guis not initiated")
        return
    end
    game.print(#storage.history)
end

function print_last_entry()
    ---@type LogEntry
    local entry = storage.history[#storage.history]

    game.print(format.time(entry.time, true).." ago")
    game.print("Contents:")
    for _,item in pairs(entry.contents) do
        game.print(item.name..": "..item.count)
    end

    game.print("Remaining Stops:")
    -- if entry.schedule then
    --     local records = entry.schedule.get_records()
    --     local current = entry.current
    --     for i=current, #records, 1 do
    --         game.print(records[i].station)
    --     end
    -- end
    for _,record in pairs(records) do
        game.print(record.station)
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
    local log_entry = {
        time = game.tick,
        train = event.train,
        contents = event.train.get_contents(),
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

function init_events()
    -- local train_teleport_start = remote.call("space-exploration", "get_on_train_teleport_started_event")
    local train_teleport_end = remote.call("space-exploration", "get_on_train_teleport_finished_event")
    -- script.on_event(train_teleport_start, AddTrainLog)
    script.on_event(train_teleport_end, AddTrainLog)
end

script.on_load(init_events)


commands.add_command("sl_reset_storage", nil, reset_storage)
commands.add_command("sl_check_storage", nil, check_storage)
commands.add_command("sl_last_entry", nil, print_last_entry)