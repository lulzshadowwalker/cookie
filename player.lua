require 'character'

--  NOTE: I think I would rather have simple characters and then controllers which control these characters forming i.e. a player 
--  but let's keep things simple.

Player = Character:extend()

function Player:new(x, y)
  --  NOTE: To self, please remember that zaya is not actually the playable character :) I keep on forgetting that.
  Player.super.new(self, x, y, 'assets/zaya.png')
end

