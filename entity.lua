Object = require 'classic'

Entity = Object:extend()

function Entity:new(x, y)
  self.x = x
  self.y = y
end

function Entity:update(dt)
  --
end

function Entity:draw()
  --
end

function Entity:keypressed(key)
  --
end
