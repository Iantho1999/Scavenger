Volt = Class{}

function Volt:init(x, y, lBoundary, hBoundary)
  self.x = x * TILE_SIZE
  self.y = (y * TILE_SIZE) - 9
  self.lBoundary = lBoundary * TILE_SIZE
  self.hBoundary = hBoundary * TILE_SIZE
  self.flipped = false
  self.velX = 100
  self.width = 16
  self.height = 16
  self.sprite = love.graphics.newImage("Sprites/Tiles/volt.png")
end

function Volt:update(dt)

  if self.x >= self.hBoundary then
    self.velX = -100
  elseif self.x <= self.lBoundary then
    self.velX = 100
  end


  self.x = self.x + (self.velX * dt)

  if player.x + player.width >= self.x and player.x <= self.x + self.width and player.y + player.height >= self.y and player.y <= self.y + self.height then
    level.sounds["death"]:play()
    level:reset(string.gsub(lvlName, ".txt", "", 1))
  end

end

function Volt:draw()
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.draw(self.sprite, self.x, self.y)
end
