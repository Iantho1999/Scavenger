Beam = Class{}

function Beam:init(x, y)
  self.x = x * TILE_SIZE
  self.y = y * TILE_SIZE
end

function Beam:draw()
  love.graphics.setColor(1.0, 0.0, 1.0, 0.3)
  love.graphics.rectangle("fill", self.x, self.y, TILE_SIZE, TILE_SIZE)
end
