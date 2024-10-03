-- These are some style prototypes that the tutorial uses
-- You don't need to understand how these work to follow along
local styles = data.raw["gui-style"].default

styles["inc_content_frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    vertically_stretchable = "on"
}

styles["inc_controls_flow"] = {
    type = "horizontal_flow_style",
    vertical_align = "center",
    horizontal_spacing = 16
}

styles["inc_controls_textfield"] = {
    type = "textbox_style",
    width = 36
}

styles["inc_deep_frame"] = {
    type = "frame_style",
    parent = "slot_button_deep_frame",
    vertically_stretchable = "on",
    horizontally_stretchable = "on",
    top_margin = 16,
    left_margin = 8,
    right_margin = 8,
    bottom_margin = 4
}

styles["inc_button_text"] = {
    type = "label_style",
    horizontal_align = "right",
    vertical_align = "bottom",
    font = "count-font",
}

data:extend({
    {
        type = "custom-input",
        name = "inc_toggle_interface",
        key_sequence = "CONTROL + E",
        order = "a"
    }
})

local coin = util.table.deepcopy(data.raw["resource"]["copper-ore"])
coin.name = "coin-ore"
coin.icon = "__base__/graphics/icons/coin.png"
coin.minable.mining_particle = "spark-particle"
coin.minable.result = "coin"
coin.stages.sheet.filename = "__incremental__/assets/coins.png"
coin.stages.sheet.hr_version.filename = "__incremental__/assets/hr-coins.png"
coin.map_color = { r = 0.8, g = 0.7, b = 0.1, a = 1.0 }
data:extend({ coin })

-- Update linked belt graphics to use yellow color, create red/blue versions with faster speeds
local fast_linked_belt_item = util.table.deepcopy(data.raw["item"]["linked-belt"])
fast_linked_belt_item.name = "fast-linked-belt"
fast_linked_belt_item.order = "b[items]-b[linked-belt]-b"
fast_linked_belt_item.place_result = "fast-linked-belt"
data:extend({ fast_linked_belt_item })

local express_linked_belt = util.table.deepcopy(data.raw["item"]["linked-belt"])
express_linked_belt.name = "express-linked-belt"
express_linked_belt.order = "b[items]-b[linked-belt]-c"
express_linked_belt.place_result = "express-linked-belt"
data:extend({ express_linked_belt })

local fast_linked_belt = util.table.deepcopy(data.raw["linked-belt"]["linked-belt"])
fast_linked_belt.name = "fast-linked-belt"
fast_linked_belt.speed = 0.0625
fast_linked_belt.minable = { mining_time = 0.1, result = "fast-linked-belt" }
fast_linked_belt.belt_animation_set = fast_belt_animation_set
fast_linked_belt.structure.back_patch = data.raw["underground-belt"]["fast-underground-belt"].structure.back_patch
fast_linked_belt.structure.front_patch = data.raw["underground-belt"]["fast-underground-belt"].structure.front_patch
fast_linked_belt.structure.direction_in.sheet.filename =
"__base__/graphics/entity/fast-underground-belt/fast-underground-belt-structure.png"
fast_linked_belt.structure.direction_out.sheet.filename =
"__base__/graphics/entity/fast-underground-belt/fast-underground-belt-structure.png"
fast_linked_belt.structure.direction_in_side_loading.sheet.filename =
"__base__/graphics/entity/fast-underground-belt/fast-underground-belt-structure.png"
fast_linked_belt.structure.direction_out_side_loading.sheet.filename =
"__base__/graphics/entity/fast-underground-belt/fast-underground-belt-structure.png"
fast_linked_belt.structure.direction_in.sheet.hr_version.filename =
"__base__/graphics/entity/fast-underground-belt/hr-fast-underground-belt-structure.png"
fast_linked_belt.structure.direction_out.sheet.hr_version.filename =
"__base__/graphics/entity/fast-underground-belt/hr-fast-underground-belt-structure.png"
fast_linked_belt.structure.direction_in_side_loading.sheet.hr_version.filename =
"__base__/graphics/entity/fast-underground-belt/hr-fast-underground-belt-structure.png"
fast_linked_belt.structure.direction_out_side_loading.sheet.hr_version.filename =
"__base__/graphics/entity/fast-underground-belt/hr-fast-underground-belt-structure.png"
data:extend({ fast_linked_belt })

local express_linked_belt = util.table.deepcopy(data.raw["linked-belt"]["linked-belt"])
express_linked_belt.name = "express-linked-belt"
express_linked_belt.speed = 0.09375
express_linked_belt.belt_animation_set = express_belt_animation_set
express_linked_belt.minable = { mining_time = 0.1, result = "express-linked-belt" }
express_linked_belt.structure.back_patch = data.raw["underground-belt"]["express-underground-belt"].structure.back_patch
express_linked_belt.structure.front_patch = data.raw["underground-belt"]["express-underground-belt"].structure
    .front_patch
express_linked_belt.structure.direction_in.sheet.filename =
"__base__/graphics/entity/express-underground-belt/express-underground-belt-structure.png"
express_linked_belt.structure.direction_out.sheet.filename =
"__base__/graphics/entity/express-underground-belt/express-underground-belt-structure.png"
express_linked_belt.structure.direction_in_side_loading.sheet.filename =
"__base__/graphics/entity/express-underground-belt/express-underground-belt-structure.png"
express_linked_belt.structure.direction_out_side_loading.sheet.filename =
"__base__/graphics/entity/express-underground-belt/express-underground-belt-structure.png"
express_linked_belt.structure.direction_in.sheet.hr_version.filename =
"__base__/graphics/entity/express-underground-belt/hr-express-underground-belt-structure.png"
express_linked_belt.structure.direction_out.sheet.hr_version.filename =
"__base__/graphics/entity/express-underground-belt/hr-express-underground-belt-structure.png"
express_linked_belt.structure.direction_in_side_loading.sheet.hr_version.filename =
"__base__/graphics/entity/express-underground-belt/hr-express-underground-belt-structure.png"
express_linked_belt.structure.direction_out_side_loading.sheet.hr_version.filename =
"__base__/graphics/entity/express-underground-belt/hr-express-underground-belt-structure.png"
data:extend({ express_linked_belt })

data.raw["linked-belt"]["linked-belt"].structure.direction_in.sheet.filename =
"__base__/graphics/entity/underground-belt/underground-belt-structure.png"
data.raw["linked-belt"]["linked-belt"].structure.direction_out.sheet.filename =
"__base__/graphics/entity/underground-belt/underground-belt-structure.png"
data.raw["linked-belt"]["linked-belt"].structure.direction_in_side_loading.sheet.filename =
"__base__/graphics/entity/underground-belt/underground-belt-structure.png"
data.raw["linked-belt"]["linked-belt"].structure.direction_out_side_loading.sheet.filename =
"__base__/graphics/entity/underground-belt/underground-belt-structure.png"
data.raw["linked-belt"]["linked-belt"].structure.direction_in.sheet.hr_version.filename =
"__base__/graphics/entity/underground-belt/hr-underground-belt-structure.png"
data.raw["linked-belt"]["linked-belt"].structure.direction_out.sheet.hr_version.filename =
"__base__/graphics/entity/underground-belt/hr-underground-belt-structure.png"
data.raw["linked-belt"]["linked-belt"].structure.direction_in_side_loading.sheet.hr_version.filename =
"__base__/graphics/entity/underground-belt/hr-underground-belt-structure.png"
data.raw["linked-belt"]["linked-belt"].structure.direction_out_side_loading.sheet.hr_version.filename =
"__base__/graphics/entity/underground-belt/hr-underground-belt-structure.png"
