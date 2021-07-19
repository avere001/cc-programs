local inspect = require("inspect")

local storage = peripheral.wrap("right")
local trash = peripheral.wrap("left")

function pagedInspect(val)
    textutils.pagedPrint(inspect(val))
end

function discard(stack)
    print(string.format("Discarding %s...", stack.enchantments[1].displayName))
    for i = 1, stack.count do
        storage.pushItems("left", stack.slot)
    end
end

function getEnchantsByName()
    local stacks_by_enchant_name = {}
    local size = storage.size()
    -- local size = 10
    for i = 1, size do
        local stack = storage.getItemDetail(i)
        if stack ~= nil then
            local enchant = stack.enchantments[1]
            local stacks = stacks_by_enchant_name[enchant.name] or {}
            stack["slot"] = i
            stacks[#stacks + 1] = stack
            stacks_by_enchant_name[enchant.name] = stacks
        end
    end
    return stacks_by_enchant_name
end
local stacks_by_enchant_name = getEnchantsByName()

function discardLowerEnchants()
    for name, stacks in pairs(stacks_by_enchant_name) do
        table.sort(
            stacks,
            function(a, b)
                return a.enchantments[1].level > b.enchantments[1].level
            end
        )
        for i = 2, #stacks do
            discard(stacks[i])
        end
    end
end

function dumpAllEnchantmentNames()
    local names = {}
    for name, _ in pairs(stacks_by_enchant_name) do
        names[#names + 1] = name
    end
    table.sort(names)
    local nameDump = io.open(shell.resolve("enchants.txt"), "w")
    for _, name in ipairs(names) do
        nameDump:write(string.format("%s\n", name))
    end
    nameDump:close()
end

function discardBlacklistedEnchants()
    local blacklist = {}
    for line in io.lines(shell.resolve("enchants_blacklist.txt")) do
        blacklist[line] = true
    end
    for name, stacks in pairs(stacks_by_enchant_name) do
        if blacklist[name] == true then
            for _, stack in pairs(stacks) do
                discard(stack)
            end
        end
    end
end

function compact()
    local filled_slots = {}
    for i, stack in pairs(storage.list()) do
        if stack ~= nil then
            table.insert(filled_slots, i)
        end
    end
    table.sort(filled_slots)

    function pullAllItems(old_slot)
        local stack = storage.getItemDetail(old_slot)
        for i=1,stack.count do
            storage.pushItems("top", old_slot)
        end
        storage.pullItems("top", 2)
    end

    for new_slot, old_slot in ipairs(filled_slots) do
        pullAllItems(old_slot, new_slot)
    end
end

discardLowerEnchants()
dumpAllEnchantmentNames()
discardBlacklistedEnchants()
compact()