local constants = require("scripts/constants")

data:extend {
    {
        type = "custom-input",
        name = constants.custom_input_name,
        key_sequence = constants.custom_input_key_sequence,
        enabled_while_spectating = true,
        localised_name = { "se-log.open-custom-input" },
    },
    {
        type = "sprite",
        name = constants.button_sprite,
        filename = constants.space_elevator_filename,
        size = 64,
    },
    {
        type = "sprite",
        name = constants.invalid_train,
        filename = constants.mod_base_path .. constants.invalid_train_filename,
        size = 64,
    }
}

data.raw["gui-style"]["default"]["sel_events_table"] =
{
  type = "table_style",
    odd_row_graphical_set = {
        filename = "__core__/graphics/gui-new.png",
        position = {472, 25},
        size = 1
    }
}
