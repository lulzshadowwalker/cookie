require 'drawable'

Character = Drawable:extend()

function Character:new(x, y, imagePath)
  Character.super.new(self, x, y, imagePath)
  self.speed = 100
end
