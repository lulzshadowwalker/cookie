require 'character'
local anim8 = require 'animate'
local createAnimations = require 'create_animations'

--  NOTE: I think I would rather have simple characters and then controllers which control these characters forming i.e. a player 
--  but let's keep things simple.

Player = Character:extend()

function Player:new(x, y)
  --  NOTE: To self, please remember that zaya is not actually the playable character :) I keep on forgetting that.
  Player.super.new(self, x, y, 'assets/boy/sprite.png')

  --  NOTE: Cleanup and move some things into the character class
  self.grid = anim8.newGrid(48, 64, self.w, self.h)

  self.animations = createAnimations(self.grid, {'walk', 'idle', 'dash', 'dead:pauseAtEnd'}, {'down', 'downLeft', 'upLeft', 'up', 'upRight', 'downRight'})
  self.animations.walk.left = self.animations.walk.downLeft
  self.animations.walk.right = self.animations.walk.downRight
  self.animations.idle.left = self.animations.idle.downLeft
  self.animations.idle.right = self.animations.idle.downRight
  self.animations.dead.left = self.animations.dead.downLeft
  self.animations.dead.right = self.animations.dead.downRight

  self.animation = self.animations.dead.down
  self.scale = 4
  self.direction = { x = 0, y = 0 }
  self.facing = 'down'
  self.dashing = false
  self.dead = false
end

function Player:update(dt)
  self.animation = self.animations[self:getState()][self.facing]
  self.animation:update(dt)
  self:move(dt)
end

function Player:draw()
  self.animation:draw(self.image, self.x, self.y, self.rotation, self.scale, self.scale)
end

function Player:move(dt)
  if self.dead then
    return
  end

  local dx, dy = 0, 0

  if love.keyboard.isDown('up') then
      dy = -1
  elseif love.keyboard.isDown('down') then
      dy = 1
  end

  if love.keyboard.isDown('left') then
      dx = -1
  elseif love.keyboard.isDown('right') then
      dx = 1
  end

  -- Normalize to prevent faster diagonal movement
  local length = math.sqrt(dx * dx + dy * dy)
  if length > 0 then
      dx, dy = dx / length, dy / length
  end

  -- Set direction and move
  self.direction.x = dx
  self.direction.y = dy

  if dx ~= 0 or dy ~= 0 then
    self.facing = self:getFacing()
  end

  self.x = self.x + dx * self.speed * dt
  self.y = self.y + dy * self.speed * dt
end

function Player:getFacing()
    if self.direction.x == 0 and self.direction.y == 0 then
      return 'down'
      -- return 'idle'
  elseif self.direction.y < 0 and self.direction.x == 0 then
      return 'up'
  elseif self.direction.y > 0 and self.direction.x == 0 then
      return 'down'
  elseif self.direction.x < 0 and self.direction.y == 0 then
      return 'left'
  elseif self.direction.x > 0 and self.direction.y == 0 then
      return 'right'
  elseif self.direction.x < 0 and self.direction.y < 0 then
      return 'upLeft'
  elseif self.direction.x > 0 and self.direction.y < 0 then
      return 'upRight'
  elseif self.direction.x < 0 and self.direction.y > 0 then
      return 'downLeft'
  elseif self.direction.x > 0 and self.direction.y > 0 then
      return 'downRight'
  end
end

function Player:getState()
    if self.dead then
        return 'dead'
    elseif self.dashing then
        return 'dash'
    elseif self.direction.x == 0 and self.direction.y == 0 then
        return 'idle'
    else
        return 'walk'
    end
end

function Player:keypressed(key)
  -- if key == 'space' then
  --   self.dashing = true 
  -- else 
  --   self.dashing = false
  -- end

  if key == 'z' then
    self.dead = true
  end
end