local buyables = {
    {
        label = "Resources",
        name = "resources_panel",
        action = "inc_buy_resource",
        elements = {
            { name = "coal",        cost = 5 },
            { name = "stone",       cost = 5 },
            { name = "iron-ore",    cost = 10 },
            { name = "copper-ore",  cost = 10 },
            { name = "uranium-ore", cost = 100 },
        }
    },
    {
        label = "Supply Lines",
        name = "belts_panel",
        action = "inc_buy_belt",
        elements = {
            { name = "transport-belt",         cost = 5 },
            { name = "fast-transport-belt",    cost = 10 },
            { name = "express-transport-belt", cost = 5 },
        }
    },
    {
        label = "Smelting",
        name = "smelting_panel",
        action = "inc_buy_furnace",
        elements = {
            { name = "stone-furnace",    cost = 5 },
            { name = "steel-furnace",    cost = 10 },
            { name = "electric-furnace", cost = 15 },
        }
    },
    {
        label = "Automation",
        name = "automation_panel",
        action = "inc_buy_assembler",
        elements = {
            { name = "assembling-machine-1", cost = 5 },
            { name = "assembling-machine-2", cost = 5 },
            { name = "assembling-machine-3", cost = 5 },
        }
    },
}

local miner_dirs = { defines.direction.south, defines.direction.north }
local MINERS_PER_ROW = 27

local function spawn_belt(player, belt_name)
    local mining_surface = game.get_surface("mining")
    local nauvis_surface = game.get_surface("nauvis")

    local x = global.belt_count
    local y = -8

    local name = 'linked-belt'
    local loader_name = 'loader'
    if belt_name == 'fast-transport-belt' then
        name = 'fast-linked-belt'
        loader_name = 'fast-loader'
    elseif belt_name == 'express-transport-belt' then
        name = 'express-linked-belt'
        loader_name = 'express-loader'
    end

    player.print(name)

    local input = mining_surface.create_entity {
        name = name,
        position = { x = x, y = y },
        direction = defines.direction.north,
        force = player.force,
    }
    input.linked_belt_type = "input"


    local output = nauvis_surface.create_entity {
        name = name,
        position = { x = x, y = y },
        direction = defines.direction.south,
        force = player.force,
    }
    output.linked_belt_type = "output"
    output.destructible = false
    output.operable = false
    output.minable = false
    output.rotatable = false

    input.connect_linked_belts(output)

    mining_surface.create_entity {
        name = 'linked-chest',
        position = { x = x, y = y + 3 },
        link_id = 42069,
        force = player.force,
    }

    local loader = mining_surface.create_entity {
        name = loader_name,
        position = { x = x, y = y + 2 },
        direction = defines.direction.south,
        force = player.force,
    }
    loader.loader_type = "output"

    global.belt_count = global.belt_count + 1
end

local function spawn_miner(player, ore_name)
    local mining_surface = game.get_surface("mining")

    local count = global.miner_count

    local x = (3 * math.floor(count / 2)) % (3 * MINERS_PER_ROW)
    local y = 4 * (count % 2) + 7 * math.floor(count / (MINERS_PER_ROW * 2))
    local dir = miner_dirs[1 + (count % 2)]

    if count % 2 == 0 then
        mining_surface.create_entity {
            name = 'linked-chest',
            position = { x = x, y = y + 2 },
            link_id = 42069,
            force = player.force,
        }
    end

    if count % 6 == 0 then
        mining_surface.create_entity {
            name = 'medium-electric-pole',
            position = { x = x + 4, y = y + 2 },
            force = player.force,
        }
    end

    mining_surface.create_entity {
        name = ore_name,
        position = { x = x, y = y },
        amount = 4294967295,
    }

    local miner = mining_surface.create_entity {
        name = 'electric-mining-drill',
        position = { x = x, y = y },
        direction = dir,
        force = player.force,
    }

    if ore_name == "uranium-ore" then
        table.insert(global.uranium_miners, miner)
    end

    global.miner_count = count + 1
end

local function build_sprite_buttons(player)
    return
    -- local button_table = player.gui.screen.inc_main_frame.content_frame.resources_frame.button_table
    -- button_table.clear()

    -- local number_of_buttons = #resources
    -- for i = 1, number_of_buttons do
    --     local sprite_name = resources[i].name
    --     local button_style = "recipe_slot_button"
    --     local b = button_table.add { type = "sprite-button", sprite = ("item/" .. sprite_name), tags = { action = "inc_select_button", item_name = sprite_name }, style = button_style }
    --     b.add { type = "label", caption = resources[i].cost, style = "inc_button_text" }
    -- end
end

local function build_interface(player)
    local screen_element = player.gui.screen
    local main_frame = screen_element.add { type = "frame", name = "inc_main_frame", caption = { "inc.shop_title" } }
    main_frame.style.size = { 385, 500 }
    main_frame.auto_center = false

    player.opened = main_frame

    local vflow = main_frame.add { type = "flow", name = "panels", direction = "vertical", vertical_spacing = 12 }

    local resources_panel = vflow.add { type = "frame", name = "resources", direction = "horizontal", style = "inside_shallow_frame_with_padding", caption = "Resources" }
    local shop_panel = vflow.add { type = "frame", name = "shop", direction = "vertical", style = "inside_shallow_frame_with_padding", caption = "Shop" }

    resources_panel.add { type = "label", name = "money_amount", caption = "[item=coin]" .. global.coins }

    for i, buyable in ipairs(buyables) do
        shop_panel.add { type = "label", caption = buyable.label }
        local panel = shop_panel.add { type = "frame", name = "buyable_" .. i, direction = "horizontal", style = "inc_deep_frame" }
        local buttons = panel.add { type = "table", name = "buttons", column_count = #buyable.elements, style = "filter_slot_table" }
        for j = 1, #buyable.elements do
            local button = buttons.add {
                type = "sprite-button", sprite = ("item/" .. buyable.elements[j].name),
                tags = {
                    action = buyable.action,
                    item_name = buyable.elements[j].name,
                    resource_id = { i, j },
                },
                style = "recipe_slot_button",
                enabled = global.coins >= buyable.elements[j].cost,
                caption = buyable.elements[j].cost,
            }
            -- button.add { type = "label", caption = buyable.elements[j].cost, style = "inc_button_text" }
        end
    end
end

local function initialize_global(player)

end

local function toggle_interface(player)
    local main_frame = player.gui.screen.inc_main_frame

    if main_frame == nil then
        build_interface(player)
    else
        main_frame.destroy()
    end
end

local function update_interface()
    local player = global.player
    if player.gui.screen.inc_main_frame ~= nil then
        player.gui.screen.inc_main_frame.destroy()
        build_interface(player)
    end
end

-- Make sure the intro cinematic of freeplay doesn't play every time we restart
-- This is just for convenience, don't worry if you don't understand how this works
script.on_init(function()
    local freeplay = remote.interfaces["freeplay"]
    if freeplay then -- Disable freeplay popup-message
        if freeplay["set_skip_intro"] then remote.call("freeplay", "set_skip_intro", true) end
        if freeplay["set_disable_crashsite"] then remote.call("freeplay", "set_disable_crashsite", true) end
    end

    print("initializing script")
    local _, p = next(game.connected_players)
    if p == nil then
        log("player is nil")
    else
        log("player found")
    end

    global = {
        coins = 0,
        belt_count = 0,
        miner_count = 0,
        uranium_miners = {},
        player = p,
    }
end)

require "market"

local function earn_coins(amount)
    global.coins = global.coins + amount
    update_interface()
end

script.on_event(defines.events.on_tick, function(event)
    if event.tick % 60 == 0 then
        -- feed the uranium miners
        for _, miner in ipairs(global.uranium_miners) do
            miner.insert_fluid { name = 'sulfuric-acid', amount = 1 }
        end
    end

    if event.tick % 60 == 30 then
        -- sell items in the depot
        local inventory = game.get_entity_by_tag("depot").get_inventory(defines.inventory.chest)
        for item, count in pairs(inventory.get_contents()) do
            -- game.print(item .. "  " .. count)
            local price = SELL_PRICES[item]
            if price ~= nil then
                earn_coins(price * count)
            end
        end
    end
end)

script.on_event("inc_toggle_interface", function(event)
    local player = game.get_player(event.player_index)
    toggle_interface(player)
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.element and event.element.name == "inc_main_frame" then
        local player = game.get_player(event.player_index)
        toggle_interface(player)
    end
end)


script.on_event(defines.events.on_gui_click, function(event)
    if event.element.tags.action == "inc_buy_resource" then
        local player = game.get_player(event.player_index)

        local clicked_item_name = event.element.tags.item_name

        build_sprite_buttons(player)

        if event.control then
            for i = 1, 10 do
                spawn_miner(player, clicked_item_name)
            end
        else
            spawn_miner(player, clicked_item_name)
        end

        local res_id = event.element.tags.resource_id
        global.coins = global.coins - buyables[res_id[1]].elements[res_id[2]].cost
        update_interface(player)
    elseif event.element.tags.action == "inc_buy_belt" then
        local player = game.get_player(event.player_index)

        local clicked_item_name = event.element.tags.item_name

        build_sprite_buttons(player)

        if event.control then
            for i = 1, 10 do
                spawn_belt(player, clicked_item_name)
            end
        else
            spawn_belt(player, clicked_item_name)
        end
        local res_id = event.element.tags.resource_id
        global.coins = global.coins - buyables[res_id[1]].elements[res_id[2]].cost
        update_interface(player)
    elseif event.element.tags.action == "inc_buy_furnace" then
        -- give the player a furnace
        local player = game.get_player(event.player_index)
        local item_name = event.element.tags.item_name
        player.get_main_inventory().insert({ name = item_name, count = 1 })
        local res_id = event.element.tags.resource_id
        global.coins = global.coins - buyables[res_id[1]].elements[res_id[2]].cost
        update_interface(player)
    elseif event.element.tags.action == "inc_buy_assembler" then
        -- give the player a furnace
        local player = game.get_player(event.player_index)
        local item_name = event.element.tags.item_name
        local res_id = event.element.tags.resource_id
        player.get_main_inventory().insert({ name = item_name, count = 1 })
        global.coins = global.coins - buyables[res_id[1]].elements[res_id[2]].cost
        update_interface(player)
    end
end)

script.on_event(defines.events.on_gui_value_changed, function(event)
    if event.element.name == "inc_controls_slider" then
    end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
    if event.element.name == "inc_controls_textfield" then
    end
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
    if event.entity.name == "coin-ore" then
        local player = game.get_player(event.player_index)
        event.buffer.clear()
        global.coins = global.coins + 1

        update_interface(player)

        -- player.gui.screen.inc_main_frame.panels.resources.money_amount.caption = "[item=coin]" .. global.coins

        -- for i, buyable in ipairs(player.gui.screen.inc_main_frame.panels.shop.children) do
        --     if i % 2 == 1 then
        --         goto continue
        --     end
        --     i = i / 2
        --     player.print("  " .. buyable.name .. "  " .. buyable.type)

        --     -- for j, c in ipairs(buyable.children) do
        --     --     player.print("    " .. j .. c.name .. "  " .. c.type)
        --     -- end
        --     if buyable.buttons ~= nil then
        --         for j, button in ipairs(buyable.buttons.children) do
        --             player.print("      cost: " .. buyables[i].elements[j].cost)
        --             button.enabled = true
        --             if buyables[i].elements[j].cost > global.coins then
        --                 button.enabled = false
        --             end
        --         end
        --     end

        --     ::continue::
        -- end
    end
end)
-- game.player.gui.screen.inc_main_frame.panels.shop.buyable_1.buttons.children[1].enabled = false
