require 'character'
local animate = require 'animate'
local createAnimations = require 'create_animations'

--  NOTE: I think I would rather have simple characters and then controllers which control these characters forming i.e. a player 
--  but let's keep things simple.

Player = Character:extend()

function Player:new(x, y)
  --  NOTE: To self, please remember that zaya is not actually the playable character :) I keep on forgetting that.
  Player.super.new(self, x, y, 'assets/boy/sprite.png')

  --  NOTE: Cleanup and move some things into the character class
  self.grid = animate.newGrid(48, 64, self.w, self.h)

  self.animations = createAnimations(self.grid, 
    { 
      idle = { 'none', 'gun', 'spear' }, 
      walk = { 'none', 'gun', 'spear' },
      run = { 'none', 'gun', 'spear' },
      reload = { 'gun' },
      attack = { 'gun', 'spear' },
      ['dead:pauseAtEnd:0.14'] = { 'none', 'gun', 'spear' },
    }, 
    { 'down', 'downLeft', 'upLeft', 'up', 'upRight', 'downRight', 'left', 'right' },
    { 'idle', 'walk', 'run', 'reload', 'attack', 'dead:pauseAtEnd:0.14' }
  )

  --   TODO: Double check corner attack animations
  --  NOTE: For some reason they are flipped not sure why that is.
  self.animations.gun.attack.right, self.animations.gun.attack.left = self.animations.gun.attack.left, self.animations.gun.attack.right
  self.animations.spear.attack.right, self.animations.spear.attack.left = self.animations.spear.attack.left, self.animations.spear.attack.right

  self.animation = self.animations.none.idle.down
  self.scale = 4
  self.direction = { x = 0, y = 0 }
  self.facing = 'down'
  self.running = false
  self.dead = false
  self.attacking = false
  self.weapon = 'none'
end

function Player:update(dt)
  self.animation = self.animations[self.weapon][self:getState()][self.facing]
  self.animation = self.animations.gun.attack.right
  self.animation:update(dt)
  self:move(dt)
end

function Player:draw()
  self.animation:draw(self.image, self.x, self.y, self.rotation, self.scale, self.scale)
end

function Player:move(dt)
  if self.dead or self.attacking then
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

  local length = math.sqrt(dx * dx + dy * dy)
  if length > 0 then
      dx, dy = dx / length, dy / length
  end

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

-- idle:                      normal, gun, spear
-- walk:                      normal, gun, spear
-- run:                       normal, gun, spear
-- reload:                            gun
-- attack:                            gun, spear
-- death:                     normal, gun, spear
function Player:getState()
    if self.attacking then
        return 'attack'
    elseif self.dead then
        return 'dead'
    -- elseif self.running and self.reloading then
    --     return 'run-reload' 
    elseif self.running then
        return 'run'
    elseif self.direction.x == 0 and self.direction.y == 0 then
        return 'idle'
    else
        return 'walk'
    end
end

function Player:keypressed(key)
  if key == 'space' then
    self.running = true 
  end

  if key == 'z' then
    self.dead = true
  end

  if key == 'x' then
    -- if self.weapon == 'gun' then
    --   self.animation = self.animations.gun.reload.down
    -- end

    if self.weapon == 'none' then
      print('No weapon selected')
    else
      self.attacking = true
    end
  end
end

function Player:keyreleased(key)
  if key == 'space' then
    self.running = false
  end

  if key == 'z' then
    self.dead = false
  end

  if key == 'x' then
    self.attacking = false
  end

  if key == '1' then
    self.weapon = 'none'
  elseif key == '2' then
    self.weapon = 'gun'
  elseif key == '3' then
    self.weapon = 'spear'
  end
end
