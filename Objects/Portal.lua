Portal = Class{}

function Portal:init(x, y)
  self.x = x * TILE_SIZE
  self.y = y * TILE_SIZE
  self.sprite = Animation("Sprites/Tiles/portal", 1, 8, 12)
end

function Portal:update(dt)
  self.sprite:update(dt)
  if player.x + player.width >= self.x and player.x <= self.x + TILE_SIZE and player.y + player.height >= self.y and player.y <= self.y + TILE_SIZE then
    level.sounds["portal"]:play()
    player.fuelBuffer = player.fuel
    changegamestate("clear")
  end
end

function Portal:draw()
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.draw(self.sprite.frames[self.sprite.index], self.x, self.y)
end
