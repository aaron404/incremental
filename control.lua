local growth_funcs = require('growth_funcs')
local shop_callbacks = require('shop_callbacks')

local mapgen_settings = {
    autoplace_controls = {},
    default_enable_all_autoplace_controls = false,
    width = 256,
    height = 256,
}

local function upgrade_linear(label, item, start, step)
    local cost_func = growth_funcs.linear:new(start, step)
    local upg = {
        label = label,
        item = item,
        sprite = "item/" .. item,
        cost_func = cost_func,
        current_cost = cost_func:nth(0),
        level = 0,
    }
    return upg
end

local function upgrade_quadratic(label, item, a, b, c)
    local cost_func = growth_funcs.quadratic:new(c, b, a)
    local upg = {
        label = label,
        item = item,
        sprite = "item/" .. item,
        cost_func = cost_func,
        current_cost = cost_func:nth(0),
        level = 0,
    }
    return upg
end

script.on_init(function()
    storage.money = 0
    storage.belt_count = 0
    storage.sell_chests = {}
    storage.nauvis_surface = game.get_surface("nauvis")
    storage.mining_surface = game.create_surface("mining", mapgen_settings)

    storage.linked_chest = storage.mining_surface.create_entity({
        name = "linked-chest",
        position = { x = -5, y = 0 },
        link_id = 42069,
        force = game.forces[1],
    })
    if not storage.linked_chest then
        error("Could not create linked chest")
    end

    storage.upgrades = {
        resource = {
            label = "Resource Generation",
            callback = "buy_res",
            entries = {
                iron    = upgrade_linear("Iron", "iron-ore", 10, 5),
                coal    = upgrade_linear("Coal", "coal", 15, 10),
                copper  = upgrade_linear("Copper", "copper-ore", 20, 15),
                uranium = upgrade_linear("Uranium", "uranium-ore", 1000, 500),
            }
        },
        logistic = {
            label = "Logistics",
            callback = "buy_item",
            entries = {
                linked_belt = upgrade_quadratic("Supply Line", "underground-belt", 1, 1, 1),
                linked_chest = upgrade_quadratic("Shipping Crate", "linked-chest", 1, 1, 1),
            }
        }
    }

    storage.ui = {}
    storage.ui.money_label = {}
    storage.ui.res_buttons = {}
    storage.ui.log_buttons = {}
    storage.ui.res_mult = 1
end)

local function generate_upg_section(section, flow, button_table)
    subheader_flow = flow.add({ type = "flow", })
    subheader_flow.add({ type = "label", caption = section.label })
    subheader_flow.add({ type = "empty-widget", style = "draggable_space" })
    -- add resource upgrades
    local upgrade_flow = flow.add({ type = "flow", direction = "vertical" })
    for key, entry in pairs(section.entries) do
        local entry_flow = upgrade_flow.add({ type = "flow" })
        entry_flow.add({ type = "sprite", sprite = entry.sprite })
        entry_flow.add({ type = "label", caption = entry.label })
        local caption = string.format("Buy Iron (%d x) [item=coin] %d", 1, entry.current_cost)
        table.insert(button_table, entry_flow.add(
            {
                type = "button",
                caption = caption,
                tags = { key = key },
                name = string.format("%s %s", section.callback, key),
                enabled = storage.money >= entry.current_cost
            }
        ))
    end
end

local function inc_toggle_interface(event)
    local player = game.players[event.player_index]

    if not player then
        return
    end

    if not storage.ui.root then
        storage.ui.root = player.gui.screen.add({ type = "frame", visible = false })
        local vflow = storage.ui.root.add({ type = "flow", direction = "vertical" })
        -- add header
        local header_flow = vflow.add({ type = "flow", })
        storage.ui.money_label = header_flow.add(
            { type = "label", caption = string.format("Money: [item=coin] %d", 0) }
        )

        -- add upgrade sections
        generate_upg_section(storage.upgrades.resource, vflow, storage.ui.res_buttons)
        generate_upg_section(storage.upgrades.logistic, vflow, storage.ui.log_buttons)

        -- add footer
        local footer_flow = vflow.add({ type = "flow", style = "player_input_horizontal_flow" })
        for _, mult in ipairs({ 1, 5, 10, 25, 100 }) do
            footer_flow.add({
                type = "button",
                caption = string.format("%dx", mult),
                style = "tool_button",
                name = string.format("set_mult %d", mult)
            })
        end
    end

    storage.ui.root.visible = not storage.ui.root.visible
end

function add_money(amount)
    storage.money = storage.money + amount
    storage.ui.money_label.caption = string.format("Money: [item=coin] %d", storage.money)

    for i, v in ipairs(storage.ui.res_buttons) do
        local res = v.tags.key
        local upg = storage.upgrades.resource.entries[res]
        v.enabled = storage.money >= upg.current_cost
    end

    for i, v in ipairs(storage.ui.log_buttons) do
        local log = v.tags.key
        local upg = storage.upgrades.logistic.entries[log]
        v.enabled = storage.money >= upg.current_cost
    end
end

local function inc_cheat()
    add_money(10000)

    for k, v in pairs(storage.upgrades.resource.entries) do
        local vals = k
        for i = 0, 10, 1 do
            vals = vals .. " " .. tostring(v.cost_func:nth(i))
        end
        game.print(vals)
    end
end

script.on_event("inc_toggle_interface", inc_toggle_interface)
script.on_event("inc_cheat", inc_cheat)

local function on_linked_belt_built(event)
    -- game.print("Built entity: " .. event.entity.name)
    local force = game.players[event.player_index].force
    local belt = event.entity
    belt.linked_belt_type = "output"

    local loader_name = "loader"

    if belt.name == "linked-belt" then
        loader_name = "loader"
    elseif belt.name == "fast-linked-belt" then
        loader_name = "fast-loader"
    elseif belt.name == "express-linked-belt" then
        loader_name = "express-loader"
    elseif belt.name == "turbo-linked-belt" then
        loader_name = "turbo-loader"
    else
        game.print("Invalid linked belt type: " .. belt.name)
        return
    end

    -- spawn neighbor belt
    local spawn_x = storage.belt_count
    local input_belt = storage.mining_surface.create_entity({
        name = belt.name,
        position = { x = spawn_x, y = 0 },
        direction = defines.direction.north,
        force = force,
    })
    if not input_belt then
        game.print("Failed to create input belt for " .. belt.name)
        return
    end
    input_belt.linked_belt_type = "input"
    input_belt.connect_linked_belts(belt)

    local lane_splitter = storage.mining_surface.create_entity({
        name = "lane-splitter",
        position = { x = spawn_x, y = 1 },
        direction = defines.direction.north,
        force = force,
    })
    if not lane_splitter then
        game.print("Failed to lane splitter")
        input_belt.destroy()
        return
    end

    local loader = storage.mining_surface.create_entity({
        name = loader_name,
        position = { x = spawn_x, y = 3 },
        direction = defines.direction.north,
        force = force,
    })

    if not loader then
        game.print("Failed to create loader for " .. belt.name)
        input_belt.destroy()
        lane_splitter.destroy()
        return
    end

    linked_chest = storage.mining_surface.create_entity({
        name = "linked-chest",
        position = { x = spawn_x, y = 4 },
        link_id = 42069,
        force = force,
    })
    if not linked_chest then
        game.print("Failed to create linked chest for " .. belt.name)
        input_belt.destroy()
        loader.destroy()
        lane_splitter.destroy()
        return
    end

    storage.belt_count = storage.belt_count + 1
end

local function on_linked_belt_mined(event)
    game.print("Mined entity: " .. event.entity.name)
end

local function on_linked_chest_built(event)
    -- register the linked chest so we can check contents on tick
    table.insert(storage.sell_chests, event.entity)

    local i = 0
    for i, s in ipairs(storage.sell_chests) do
        game.print(i)
    end
end

local function on_linked_chest_mined(event)

end

local function on_built_entity(event)
    if string.find(event.entity.name, "linked%-belt") then
        on_linked_belt_built(event)
    elseif string.find(event.entity.name, "linked%-chest") then
        on_linked_chest_built(event)
    end
end

local expected_resource_rate = 1 -- per second
local rem = 0
local function on_tick(event)
    local max_items_to_sell = 7
    local items_removed = 0

    if event.tick % 10 == 0 then
        for i, chest in ipairs(storage.sell_chests) do
            local inv = chest.get_inventory(defines.inventory.chest)
            if inv.get_item_count() > 0 then
                local contents = inv.get_contents()
                for j, item_stack in ipairs(contents) do
                    local remove_count = math.min(item_stack.count, max_items_to_sell - items_removed)
                    inv.remove({ name = item_stack.name, count = remove_count })
                    items_removed = items_removed + remove_count
                    if items_removed == max_items_to_sell then
                        return
                    end
                end
            end
        end
    end

    -- compute number of resources to spawn using inverse CDF of exponential distribution
    if event.tick % 1 == 0 then
        for _, v in pairs(storage.upgrades.resource.entries) do
            local lvl = v.level
            if lvl > 0 then
                local e = v.level / 60 / 5
                local spawn_amt = -math.log(1 - math.random()) * e + rem
                spawn_amt, rem = math.modf(spawn_amt)

                if spawn_amt > 0 then
                    storage.linked_chest.get_inventory(defines.inventory.chest).insert({
                        name = v.item, count = spawn_amt
                    })
                end
            end
        end
    end
end

-- capture events regarding creation/destruction of linked belts
-- TODO: handle cases where the item is destroyed/lost
--  - item placed in chest/wagon that is destroyed
--  - player dies
--  - item on ground is destroyed
--  - dropped into space/lava
script.on_event(defines.events.on_built_entity, on_built_entity)
-- script.on_event(defines.events.on_robot_built_entity, on_linked_belt_built, linked_belt_event_filter)
-- script.on_event(defines.events.on_player_mined_entity, on_linked_belt_mined, linked_belt_event_filter)
-- script.on_event(defines.events.on_robot_mined_entity, on_linked_belt_mined, linked_belt_event_filter)

-- capture events regarding creation/mining/destruction of linked chests
-- script.on_event(defines.events.on_built_entity, on_linked_chest_built, linked_chest_event_filter)
-- script.on_event(defines.events.on_robot_built_entity, on_linked_chest_built, linked_chest_event_filter)
-- script.on_event(defines.events.on_player_mined_entity, on_linked_chest_mined, linked_chest_event_filter)
-- script.on_event(defines.events.on_robot_mined_entity, on_linked_chest_mined, linked_chest_event_filter)

script.on_event(defines.events.on_tick, on_tick)

local function on_player_joined_game(event)
    storage.player = event.player_index
    assert(storage.player, "Player is nil")
end

script.on_event(defines.events.on_player_joined_game, on_player_joined_game)
