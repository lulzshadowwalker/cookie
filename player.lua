require("character")
local animate = require("animate")
local createAnimations = require("create_animations")

--  NOTE: I think I would rather have simple characters and then controllers which control these characters forming i.e. a player
--  but let's keep things simple.

Player = Character:extend()
-- Footstep audio
local footsteps = {}
local gunshot = {}

function Player:new(x, y)
	--  NOTE: To self, please remember that zaya is not actually the playable character :) I keep on forgetting that.
	Player.super.new(self, x, y, "assets/boy/sprite.png")

	--  NOTE: Cleanup and move some things into the character class
	self.grid = animate.newGrid(48, 64, self.w, self.h)

	self.animations = createAnimations(
		self.grid,
		{
			idle = { "none", "gun", "spear" },
			walk = { "none", "gun", "spear" },
			run = { "none", "gun", "spear" },
			reload = { "gun" },
			attack = { "gun", "spear" },
			["dead:pauseAtEnd:0.14"] = { "none", "gun", "spear" },
		},
		{ "down", "downLeft", "upLeft", "up", "upRight", "downRight", "left", "right" },
		{ "idle", "walk", "run", "reload", "attack", "dead:pauseAtEnd:0.14" }
	)

	--   TODO: Double check corner attack animations
	--  NOTE: For some reason they are flipped not sure why that is.
	self.animations.gun.attack.right, self.animations.gun.attack.left =
		self.animations.gun.attack.left, self.animations.gun.attack.right
	self.animations.spear.attack.right, self.animations.spear.attack.left =
		self.animations.spear.attack.left, self.animations.spear.attack.right

	self.animations.gun.run.right, self.animations.gun.run.left =
		self.animations.gun.run.left, self.animations.gun.run.right
	self.animations.spear.run.right, self.animations.spear.run.left =
		self.animations.spear.run.left, self.animations.spear.run.right

	for i = 3, 3 do
		table.insert(footsteps, love.audio.newSource("assets/footsteps/footstep-grass-00" .. i .. ".ogg", "static"))
	end

	gunshot.sound = love.audio.newSource("assets/gunshot/single-shot.wav", "static")
	gunshot.firerate = 0.15
	gunshot.timer = gunshot.firerate

	self.animation = self.animations.none.idle.down
	self.scale = 4
	self.direction = { x = 0, y = 0 }
	self.facing = "down"
	self.running = false
	self.dead = false
	self.attacking = false
	self.weapon = "none"
	self.maxAmmo = 10
	self.extraAmmo = 20
	self.ammo = self.maxAmmo

	self.reloadTimer = 0
	self.reloadTime = 1
	self.reloading = false
end

function Player:update(dt)
	self.animation = self.animations[self.weapon][self:getState()][self.facing]
	self.animation:update(dt)
	self:move(dt)

	if self.reloading then
		self.reloadTimer = self.reloadTimer + dt
		if self.reloadTimer >= self.reloadTime then
			self:completeReload()
		end
	end

	if self.attacking then
		self:attack(dt)
	end
end

function Player:draw()
	self.animation:draw(self.image, self.x, self.y, self.rotation, self.scale, self.scale)
	love.graphics.print("Ammo: " .. self.ammo .. "/" .. self.maxAmmo, 10, 10, 0, 2, 2)
	love.graphics.print("Extra Ammo: " .. self.extraAmmo, 10, 40, 0, 2, 2)

	if self.reloading then
		love.graphics.print("Reloading...", 10, 70, 0, 2, 2)
	end
end

local stepTimer = 0
local stepInterval = 0.2
function Player:move(dt)
	if self.dead or self.attacking then
		return
	end

	local dx, dy = 0, 0

	if love.keyboard.isDown("up") then
		dy = -1
	elseif love.keyboard.isDown("down") then
		dy = 1
	end

	if love.keyboard.isDown("left") then
		dx = -1
	elseif love.keyboard.isDown("right") then
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

		stepTimer = stepTimer + dt
		if stepTimer >= stepInterval then
			local r = love.math.random(1, #footsteps)
			local sound = footsteps[r]
			sound:setPitch(0.9 + love.math.random() * 0.6)
			sound:setVolume(0.8 + love.math.random() * 0.5)
			sound:play()
			stepTimer = 0
		end
	else
		stepTimer = 0
	end

	self.x = self.x + dx * self.speed * dt
	self.y = self.y + dy * self.speed * dt
end

function Player:getFacing()
	if self.direction.x == 0 and self.direction.y == 0 then
		return "down"
	-- return 'idle'
	elseif self.direction.y < 0 and self.direction.x == 0 then
		return "up"
	elseif self.direction.y > 0 and self.direction.x == 0 then
		return "down"
	elseif self.direction.x < 0 and self.direction.y == 0 then
		return "left"
	elseif self.direction.x > 0 and self.direction.y == 0 then
		return "right"
	elseif self.direction.x < 0 and self.direction.y < 0 then
		return "upLeft"
	elseif self.direction.x > 0 and self.direction.y < 0 then
		return "upRight"
	elseif self.direction.x < 0 and self.direction.y > 0 then
		return "downLeft"
	elseif self.direction.x > 0 and self.direction.y > 0 then
		return "downRight"
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
		return "attack"
	elseif self.dead then
		return "dead"
	-- elseif self.running and self.reloading then
	--     return 'run-reload'
	elseif self.running then
		return "run"
	elseif self.direction.x == 0 and self.direction.y == 0 then
		return "idle"
	else
		return "walk"
	end
end

function Player:keypressed(key)
	if key == "space" then
		self.running = true
		stepInterval = stepInterval / 2
		self.speed = 170
	end

	if key == "z" then
		self.dead = true
	end

	if key == "x" then
		-- if self.weapon == 'gun' then
		--   self.animation = self.animations.gun.reload.down
		-- end

		if self.weapon == "none" then
			print("No weapon selected")
		else
			if self.weapon == "gun" and self:outOfAmmo() then
				print("Out of ammo")
				return
			end

			self.attacking = true
		end
	end
end

function Player:keyreleased(key)
	if key == "space" then
		self.running = false
		self.speed = 100 --  TODO: Use self.default.speed
	end

	if key == "z" then
		self.dead = false
	end

	if key == "x" then
		self.attacking = false
		gunshot.timer = gunshot.firerate
	end

	if key == "1" then
		self.weapon = "none"
	elseif key == "2" then
		self.weapon = "gun"
	elseif key == "3" then
		self.weapon = "spear"
	end

	if key == "t" then
		self:reload()
	end
end

function Player:attack(dt)
	if self.weapon == "gun" then
		self:shoot(dt)
	elseif self.weapon == "spear" then
		self:stab(dt)
	end
end

function Player:shoot(dt)
	gunshot.timer = gunshot.timer + dt
	if gunshot.timer >= gunshot.firerate then
		if self.ammo <= 0 then
			print("Out of ammo")
			self.attacking = false
			return
		end

		self.ammo = self.ammo - 1

		gunshot.sound:setPitch(1 + love.math.random() * 0.3)
		gunshot.sound:setVolume(0.9 + love.math.random() * 0.5)
		love.audio.play(gunshot.sound:clone())
		gunshot.timer = 0
	end
end

function Player:stab() end

function Player:reload()
	if not self.reloading and self.ammo < self.maxAmmo and self.extraAmmo > 0 then
		self.reloading = true
		self.reloadTimer = 0
	end
end

function Player:completeReload()
	local missingAmmo = self.maxAmmo - self.ammo
	local reloadableAmmo = math.min(missingAmmo, self.extraAmmo)

	self.ammo = self.ammo + reloadableAmmo
	self.extraAmmo = self.extraAmmo - reloadableAmmo

	self.reloading = false
end

function Player:outOfAmmo()
	return self.ammo <= 0
end
