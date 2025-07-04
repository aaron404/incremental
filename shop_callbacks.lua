local function update_res_mult(mult)
    storage.ui.res_mult = tonumber(mult)
    for i, v in ipairs(storage.ui.res_buttons) do
        local res = v.tags.key
        local upg = storage.upgrades.resource.entries[res]
        local cost = upg.cost_func:sum(upg.level, storage.ui.res_mult)
        upg.current_cost = cost
        v.caption = string.format("[item=coin] %d", cost)
    end

    for i, v in ipairs(storage.ui.log_buttons) do
        local log = v.tags.key
        local upg = storage.upgrades.logistic.entries[log]
        local cost = upg.cost_func:sum(upg.level, mult)
        upg.current_cost = cost
        v.caption = string.format("[item=coin] %d", cost)
    end
end

local function buy_res(res)
    game.print("buying " .. res)
    local upg = storage.upgrades.resource.entries[res]
    local cost = upg.current_cost
    upg.level = upg.level + storage.ui.res_mult
    update_res_mult(storage.ui.res_mult)
    add_money(-cost)
end

local item_names = {
    linked_chest = "linked-chest",
    linked_belt = "linked-belt",
}
local function buy_item(item)
    game.print("buying " .. item)
    local player = game.players[storage.player]
    local inv = player.get_main_inventory()
    if inv.insert(
            { name = item_names[item], count = 1 }) == 0 then
        game.print("Cannot insert item, inventory full")
    else
        game.print("Inserted item: " .. item)
        local upg = storage.upgrades.logistic.entries[item]
        local cost = upg.current_cost
        upg.level = upg.level + storage.ui.res_mult
        update_res_mult(storage.ui.res_mult)
        add_money(-cost)
    end
end

local function set_mult(mult)
    update_res_mult(mult)
    -- force update of button enable states
    add_money(0)
end

local shop_callbacks = {
    buy_res = buy_res,
    buy_item = buy_item,
    set_mult = set_mult,
}

local function on_gui_click(event)
    local name = event.element.name
    if not name or name == "" then
        return
    end

    local s, e = name:find(" ")
    func = name:sub(1, s - 1)
    param = name:sub(e + 1, -1)

    shop_callbacks[func](param)
end

script.on_event(defines.events.on_gui_click, on_gui_click)
