local tables = require("__flib__.table")

local time_period_items = {
    {
        time = 60 * 15,
        text = { "spelevator-log.time-minutes", 15 }
    },
    {
        time = 60 * 60 * 1,
        text = { "spelevator-log.time-hours", 1 }
    },
    {
        time = 60 * 60 * 4,
        text = { "spelevator-log.time-hours", 4 }
    },
    {
        time = 60 * 60 * 12,
        text = { "spelevator-log.time-hours", 12 }
    },
    {
        time = 60 * 60 * 24,
        text = { "spelevator-log.time-hours", 24 }
    },
    {
        time = 60 * 60 * 48,
        text = { "spelevator-log.time-hours", 48 }
    },
    {
        time = 60 * 60 * 96,
        text = { "spelevator-log.time-hours", 96 }
    },
}
local time_period_default_index = 2

local function ticks(time_period_index)
    return time_period_items[time_period_index].time * 60
end

return {
    time_period_items = tables.map(time_period_items, function(v) return v.text end),
    default_index = time_period_default_index,
    ticks = ticks
}
