Spike = Class{}

function Spike:init(x, y)
  self.x = x * TILE_SIZE
  self.y = y * TILE_SIZE
end

function Spike:draw()
  love.graphics.setColor(0.1, 0.1, 0.1)
  love.graphics.rectangle("fill", self.x, self.y, TILE_SIZE, TILE_SIZE)
end
