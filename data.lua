-- These are some style prototypes that the tutorial uses
-- You don't need to understand how these work to follow along
local styles = data.raw["gui-style"].default

-- styles["inc_content_frame"] = {
--     type = "frame_style",
--     parent = "inside_shallow_frame_with_padding",
--     vertically_stretchable = "on"
-- }

-- styles["inc_controls_flow"] = {
--     type = "horizontal_flow_style",
--     vertical_align = "center",
--     horizontal_spacing = 16
-- }

-- styles["inc_controls_textfield"] = {
--     type = "textbox_style",
--     width = 36
-- }

-- styles["inc_deep_frame"] = {
--     type = "frame_style",
--     parent = "slot_button_deep_frame",
--     vertically_stretchable = "on",
--     horizontally_stretchable = "on",
--     top_margin = 16,
--     left_margin = 8,
--     right_margin = 8,
--     bottom_margin = 4
-- }

-- styles["inc_button_text"] = {
--     type = "label_style",
--     horizontal_align = "right",
--     vertical_align = "bottom",
--     font = "count-font",
-- }

data:extend({
    {
        type = "custom-input",
        name = "inc_toggle_interface",
        key_sequence = "CONTROL + E",
        order = "a"
    },
    {
        type = "custom-input",
        name = "inc_cheat",
        key_sequence = "CONTROL + Q",
        order = "a"
    }
})

-- local coin = util.table.deepcopy(data.raw["resource"]["copper-ore"])
-- coin.name = "coin-ore"
-- coin.icon = "__base__/graphics/icons/coin.png"
-- coin.minable.mining_particle = "spark-particle"
-- coin.minable.result = "coin"
-- coin.stages.sheet.filename = "__incremental__/assets/coins.png"
-- coin.map_color = { r = 0.8, g = 0.7, b = 0.1, a = 1.0 }
-- data:extend({ coin })

-- sell chest
local sell_chest = util.table.deepcopy(data.raw["linked-container"]["linked-chest"])
sell_chest.name = "sell-chest"
sell_chest.minable = { mining_time = 0.1, result = "sell-chest" }
data:extend({ sell_chest })

local sell_chest_item = util.table.deepcopy(data.raw["item"]["linked-chest"])
sell_chest_item.name = "sell-chest"
sell_chest_item.order = "b[items]-e[sell-chest]"
sell_chest_item.place_result = "sell-chest"
data:extend({ sell_chest_item })

data.raw["linked-container"]["linked-chest"].inventory_size = 1000
