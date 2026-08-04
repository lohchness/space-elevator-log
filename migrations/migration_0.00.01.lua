if not storage.zone_by_surface then return end

-- Migrate log entries before migrating storage.zone_by_surface

for _, log_entry in pairs(storage.history) do
    log_entry.to_zone = storage.zone_by_surface[log_entry.to_surface].zone_index
    log_entry.from_zone = storage.zone_by_surface[log_entry.from_surface].zone_index
    log_entry.to_surface = nil
    log_entry.from_surface = nil
end

-- Migrate storage zone/surface entries to use Space Exploration's zone as index instead of surface

local new_zones = {}

---@type table<integer, ElevatorZone>
for _, zone_data in pairs(storage.zone_by_surface) do
    new_zones[zone_data.zone_index] = zone_data
end

---@deprecated
storage.zone_by_surface = nil

storage.zones = new_zones

-- bulk_reset_player_gui applied with on_configuration_changed
