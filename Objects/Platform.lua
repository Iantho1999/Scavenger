Platform = Class{}

function Platform:init(x, y, moveX, moveY)
  self.x = x * TILE_SIZE
  self.y = y * TILE_SIZE - 1
  self.originX = self.x
  self.originY = self.y
  self.moveX = moveX
  self.moveY = moveY
  self.offsetX = 0
  self.offsetY = 0
  self.playerOffset = 0
  self.moved = false
  self.multiplier = 200
  self.timer = Timer()
  self.color = {1.0, 0.0, 1.0}
end

function Platform:update(dt)
  self.x = self.originX + self.offsetX
  self.y = self.originY + self.offsetY
  self.timer:update(dt)
  if player.x + TILE_SIZE >= self.x and player.x <= (self.x + TILE_SIZE - 16)
  and player.y + TILE_SIZE >= (self.y + 16) and player.y <= (self.y + TILE_SIZE - 16) then
    player.x = self.x - TILE_SIZE
  elseif player.x <= self.x + TILE_SIZE and player.x + TILE_SIZE - 16 >= self.x
  and player.y + TILE_SIZE >= self.y + 16 and player.y <= self.y + TILE_SIZE - 16 then
    player.x = self.x + TILE_SIZE
  elseif player.y - 1 + TILE_SIZE >= self.y and player.y + 1 <= self.y + TILE_SIZE - 16
  and player.x + TILE_SIZE >= self.x + 1 and player.x <= self.x + TILE_SIZE - 1 then
    player.y = self.y - TILE_SIZE + (self.playerOffset * dt)
    if player.collision ~= "w" then
      self.playerOffset = math.abs(self.multiplier)
    end
    player.velY = 0
    if self.timer.seconds == 0 then
      self.timer.seconds = 0.7
    end
  elseif player.y <= self.y + TILE_SIZE and player.y + TILE_SIZE - 16 >= self.y
  and player.x + TILE_SIZE >= self.x + 1 and player.x <= self.x + TILE_SIZE - 1 then
    player.y = self.y + TILE_SIZE
    player.velY = -1
  end

  if self.timer.seconds > 0 then
    self.color = {1.0, 1.0, 1.0}
  elseif self.timer.seconds < 0 then
    self.color = {1.0, 0.0, 1.0}
    self:move(dt, self.multiplier)
  else
    self.color = {1.0, 0.0, 1.0}
  end
end

function Platform:move(dt, multiplier)
  if math.abs(self.offsetX) > 160 or math.abs(self.offsetY) > 160 then
    self.timer.seconds = 0.5
    self.offsetX = 160 * self.moveX
    self.offsetY = 160 * self.moveY
    self.moved = true
    self.multiplier = -100
    self.playerOffset = math.abs(self.multiplier)
  else
    self.playerOffset = math.abs(self.multiplier)
    self.offsetX = self.offsetX + (self.moveX * self.multiplier) * dt
    self.offsetY = self.offsetY + (self.moveY * self.multiplier) * dt
  end

  if self.moved == true and (self.offsetY * self.moveY < 2 or self.offsetX * self.moveX < 0) then
    self.multiplier = 200
    self.playerOffset = 0
    self.offsetX = 0
    self.offsetY = 0
    self.moved = false
    self.timer.seconds = 0
  end
end

function Platform:draw()
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", self.x, self.y, TILE_SIZE, TILE_SIZE)
end
