require 'entity'

Drawable = Entity:extend()

function Drawable:new(x, y, imagePath)
  Drawable.super.new(self, x, y)
  self.image = love.graphics.newImage(imagePath)
  self.w = self.image:getWidth()
  self.h = self.image:getHeight()
  self.scale = 1
  self.rotation = 0
end

function Drawable:draw()
  love.graphics.draw(self.image, self.x, self.y, self.rotation, self.scale, self.scale, self.w / 2, self.h / 2)
end
