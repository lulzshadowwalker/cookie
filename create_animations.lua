local animate = require 'animate'

local function createAnimations(grid, states, facing) 
    local animations = {}

    for i, state in ipairs(states) do
        local s, onLoop = state:match('(%a+):(%a+)')
        onLoop = onLoop or function() end
        state = s or state

        animations[state] = {}
        local offset = (i - 1) * #facing
        for j, facing in ipairs(facing) do
            animations[state][facing] = animate.newAnimation(grid('1-8', offset + j), 0.1, onLoop)
        end
    end

    return animations
end

return createAnimations