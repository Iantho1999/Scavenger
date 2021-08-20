Wall = Class{}

function Wall:init(x, y)
  self.x = x * TILE_SIZE
  self.y = (y * TILE_SIZE)
end
