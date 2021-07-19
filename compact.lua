inspect = require("inspect")

c = peripheral.wrap("right")

filled_slots = {}
for i, stack in pairs(c.list()) do
    if stack ~= nil then
        table.insert(filled_slots, i)
    end
end
table.sort(filled_slots)

function pullAllItems(old_slot)
    local stack = c.getItemDetail(old_slot)
    print(inspect(stack))
    for i=1,stack.count do
        print("push")
        c.pushItems("top", old_slot, 1)
    end
    for i=1,stack.count do
        print("pull")
        c.pullItems("top", 2)
    end
end

for new_slot, old_slot in ipairs(filled_slots) do
    pullAllItems(old_slot, new_slot)
end