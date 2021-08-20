PhPlatform = Class{}

function PhPlatform:init(x, y)
  self.x = x * TILE_SIZE
  self.y = y * TILE_SIZE
  self.timer = Timer()
  self.activated = false
  self.alpha = 1.0
  self.color = {0.5, 0.0, 1.0}
  self.transparent = false
end

function PhPlatform:update(dt)
  self.color = {0.5, 0.0, 1.0, self.alpha}
  self.timer:update(dt)

  if player.y + player.height >= self.y and player.y <= self.y + TILE_SIZE - 16
  and player.x + TILE_SIZE >= self.x + 18 and player.x <= self.x + TILE_SIZE - 2 then
    self.activated = true
    if self.alpha == 1 then
      self.transparent = true
    end
  end

  if self.alpha < 0.3 then
    level.tilemap[(self.y / TILE_SIZE) + 1][(self.x / TILE_SIZE) + 1] = "."
    if self.timer.seconds == 0 then
      self.timer.seconds = 1.0
    end
  else
    level.tilemap[(self.y / TILE_SIZE) + 1][(self.x / TILE_SIZE) + 1] = "#"
  end

  if self.transparent == true then
    self.alpha = math.max(self.alpha - 1 * dt, 0)
  else
    self.alpha = math.min(self.alpha + 1 * dt, 1)
  end

  if self.alpha == 1 then
    self.activated = false
  end

  if self.timer.seconds < 0 then
    self.transparent = false
    self.timer.seconds = 0
  end
end

function PhPlatform:phase(dt)

end

function PhPlatform:draw()
  love.graphics.setColor(self.color)
  love.graphics.draw(level.phaseSprite, self.x, self.y)
end
