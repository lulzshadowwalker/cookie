require 'player'

local player

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')  
  player = Player(100, 100)
end

function love.update(dt)
  player:update(dt)
end

function love.draw()
  player:draw()
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'r' then
    love.event.quit('restart')  
  end

  player:keypressed(key)
end