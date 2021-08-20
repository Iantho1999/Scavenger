OneWayPlatform = Class{}

function OneWayPlatform:init(x, y)
  self.x = x * TILE_SIZE
  self.y = y * TILE_SIZE
end

function OneWayPlatform:update(dt)
  if player.y + player.height >= self.y and player.y + player.height - 8 <= self.y
  and player.x + TILE_SIZE >= self.x + 18 and player.x <= self.x + TILE_SIZE - 2 and player.velY <= 0 then
    player.velY = 0
    player.y = self.y - player.height
  end
end
