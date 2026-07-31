local constants = require("scripts/constants")

data:extend {
    {
        type = "custom-input",
        name = constants.custom_input_name,
        key_sequence = "CONTROL + H",
        enabled_while_spectating = true,
    },

    {
        type = "sprite",
        name = constants.button_sprite,
        filename = "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
        size = 64,
    }
}
