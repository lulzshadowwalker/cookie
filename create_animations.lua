local animate = require 'animate'

local function createAnimations(grid, states, facing, order)
    local animations = {}

    local counter = 0
    for i, order in ipairs(order) do
        for j, weapon in ipairs(states[order]) do
            local state = order
            local s, onLoop, interval = state:match('^([^:]+):?([^:]*):?(.*)$')

            s = s ~= '' and s or nil
            onLoop = onLoop ~= '' and onLoop or function() end
            interval = tonumber(interval) or 0.1
            state = s or state

            animations[weapon] = animations[weapon] or {}

            local offset = counter * #facing
            animations[weapon][state] = {}
            for j, dir in ipairs(facing) do
                animations[weapon][state][dir] = animate.newAnimation(grid('1-8', j + offset), interval, onLoop)
            end

            counter = counter + 1
        end
    end

    return animations
end

return createAnimations
