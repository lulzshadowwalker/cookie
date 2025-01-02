require 'player'

local player

function love.load()
  player = Player(100, 100)
end

function love.update(dt)
  player:update(dt)
end

function love.draw()
  player:draw()
end
