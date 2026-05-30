---@meta

---@class TrainTeleportFinishedEvent
---@field train LuaTrain                  fully built newly created train post transfer
---@field old_train_id_1 uint32           id of the train prior to transer start
---@field stranded? uint32                optional: only if train is split due to incomplete transfer
---@field old_surface_index uint32        ??
---@field teleporter SpaceElevatorStruct  space elevator entity doing the transferring

---@class LogEntry
---@field time MapTick                       tick of event
---@field train LuaTrain                      
---@field contents ItemWithQualityCount[]    copy of contents at the time
---@field schedule LuaSchedule               copy of schedule
---@field current uint32                     schedule index of destination
---@field teleporter SpaceElevatorStruct     