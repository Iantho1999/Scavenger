Sign = Class{}

function Sign:init(x, y)
  self.x = x * TILE_SIZE
  self.y = y * TILE_SIZE + 14
  self.sprite = love.graphics.newImage("Sprites/Tiles/sign.png")
end

function Sign:draw()
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.draw(self.sprite, self.x, self.y)
end
