Fuel = Class{}

function Fuel:init(x, y)
  self.x = x * TILE_SIZE
  self.y = y * TILE_SIZE
  self.activated = false
end

function Fuel:update(dt)
  if player.x + player.width >= self.x and player.x <= self.x + TILE_SIZE and player.y + player.height >= self.y and player.y <= self.y + TILE_SIZE then
    level.sounds["fuel"]:play()
    player.fuel = player.fuel + 1
    self.activated = true
  end
end
