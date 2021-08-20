Player = Class{}

function Player:init(x, y, speed)
  self.x = x * TILE_SIZE
  self.y = (y * TILE_SIZE) + 2
  self.width = 16
  self.height = 30
  self.direction = 1
  self.offsetX = 0
  self.offsetY = 0
  self.newX = 0
  self.newY = 0
  self.velX = 0
  self.velY = 0
  self.maxGravity = -400
  self.leftBoundary = 0
  self.rightBoundary = 0
  self.upperBoundary = 0
  self.lowerBoundary = 0
  self.fuel = 0
  self.fuelBuffer = 0
  self.drawPack = false
  self.crouched = false
  self.solids = {'w', '#'}
  self.animation = "idle"
  self.sprite = {
    ["crouching"] = Animation("Sprites/Player/Crouching", 1, 1, 0),
    ["idle"] = Animation("Sprites/Player/Walking", 1, 4, 6)
  }
  self.jetpack = {
    ["activate"] = Animation("Sprites/Player/jetpack", 1, 2, 0)
  }
end

function Player:update(dt)
  self.newX = self.x
  self.newY = self.y
  self.offsetY = 0
  local newAnimation = "idle"
  self.sprite["idle"]:update(dt)
  if self.x <= (love.graphics.getWidth() / 4) - TILE_SIZE then
    cameraX = (love.graphics.getWidth() / 4) - TILE_SIZE
  elseif self.x >= (((level.width * TILE_SIZE) / 8) * 6) - TILE_SIZE then
    cameraX = (((level.width * TILE_SIZE) / 8) * 6) - TILE_SIZE
  else
    cameraX = self.x
  end

  if self.y <= (love.graphics.getHeight() / 4) then
    cameraY = (love.graphics.getHeight() / 4)
  elseif self.y >= ((love.graphics.getHeight() / 8) * 6) then
    cameraY = ((love.graphics.getHeight() / 8) * 6)
  else
    cameraY = self.y
  end

  if love.keyboard.isDown('a', "left") then
    self.direction = -1
    self.offsetX = self.width
    self.velX = math.max(self.velX - (1500 * dt), -200)
    self.sprite["idle"].speed = 6
  elseif love.keyboard.isDown('d', "right") then
    self.direction = 1
    self.offsetX = 0
    self.velX = math.min(self.velX + (1500 * dt), 200)
    self.sprite["idle"].speed = 6
  else
    self.sprite["idle"].speed = 0
    self.sprite["idle"].index = 1
    self.velX = lerp(self.velX, 0, 2000, dt)
  end


  if self.crouched == true then
    newAnimation = "crouching"
    self.height = 18
    self.velX = lerp(self.velX, 0, 2000, dt)
  else
    self.height = 30
  end
  self.newX = self.newX + (self.velX * dt)




  if self.newX < 0 then
    self.newX = 0
  elseif self.newX > (level.width * TILE_SIZE) - self.width then
    self.newX = level.width * TILE_SIZE - self.width
  end

  if self.newY > (level.height * TILE_SIZE) + TILE_SIZE then
    self.velY = 0
    level.sounds["death"]:play()
    level:reset(string.gsub(lvlName, ".txt", "", 1))
  end

  if self.fuel > 0 then
    self.drawPack = true
  end

  if self.jetpack["activate"].index == 2 and self.velY <= 0 then
    if self.fuel == 0 then
      self.drawPack = false
    end
    self.jetpack["activate"].index = 1
  end

  if self.velY ~= 0 then
    self.sprite["idle"].speed = 0
    self.sprite["idle"].index = 2
  end

  -- Gravity
  self.newY = self.newY - (self.velY * dt)
  self.velY = self.velY - 700 * dt

  --Clamp velocity values
  if self.velY < self.maxGravity then
    self.velY = self.maxGravity
    if self.fuel == 0 then
      self.drawPack = false
    end
  elseif self.velY > 500 then
    self.velY = 500
  end

  self:collision()

  self.x = self.newX
  self.y = self.newY
  self.animation = newAnimation
end

function Player:draw()
  local currentAnimation = self.sprite[self.animation]
  love.graphics.setColor(1.0, 1.0, 1.0)
  if self.drawPack == true then
    love.graphics.draw(self.jetpack["activate"].frames[self.jetpack["activate"].index], self.x, self.y + 11, 0, self.direction, 1, self.offsetX)
  end
  love.graphics.draw(currentAnimation.frames[currentAnimation.index], self.x, self.y + self.offsetY, 0, self.direction, 1, self.offsetX)
end

function Player:keypressed(key)
  if key == 's' or key == "down" then
    self.crouched = true
    self.offsetY = 18 - self.height
    self.y = self.y + 12
  end

  if key == "space" and self.velY == 0 and self.fuel > 0 then
    level.sounds["jump"]:play()
    self.jetpack["activate"].index = 2
    self.fuel = self.fuel - 1
    self.velY = 500
  end
end

function Player:keyreleased(key)
  if key == 's' or key == "down" then
    self.crouched = false
    self.offsetY = 30 - self.height
    self.y = self.y - 12
  end

end

function Player:collision()
  self.leftBoundary = math.floor(self.newX / TILE_SIZE)
  self.rightBoundary = math.floor((self.newX + self.width) / TILE_SIZE)
  self.upperBoundary = math.floor(self.newY / TILE_SIZE)
  self.lowerBoundary = math.floor((self.newY + self.height) / TILE_SIZE)

  for i = 1, #self.solids do
    if getTile(self.leftBoundary, math.floor(self.y / TILE_SIZE)) == self.solids[i] or getTile(self.leftBoundary, math.floor((self.y + self.height - 2) / TILE_SIZE)) == self.solids[i] then
      self.newX = self.rightBoundary * TILE_SIZE
    elseif getTile(self.rightBoundary, math.floor(self.y / TILE_SIZE)) == self.solids[i] or getTile(self.rightBoundary, math.floor((self.y + self.height - 2) / TILE_SIZE)) == self.solids[i] then
      self.newX = (self.leftBoundary * TILE_SIZE) + self.width
    end

    if getTile(math.floor((self.newX + 2) / TILE_SIZE), self.upperBoundary) == self.solids[i] or getTile(math.ceil((self.newX - 18) / TILE_SIZE), self.upperBoundary) == self.solids[i] then
      self.velY = -1
      self.newY = self.lowerBoundary * TILE_SIZE
    end
    if getTile(math.floor((self.newX + 2) / TILE_SIZE), self.lowerBoundary)  == self.solids[i] or getTile(math.ceil((self.newX - 18) / TILE_SIZE), self.lowerBoundary) == self.solids[i] then
      self.velY = 0
      self.newY = (self.upperBoundary * TILE_SIZE) + (TILE_SIZE - self.height)
    end
  end

  if getTile(self.leftBoundary, math.floor(self.y / TILE_SIZE)) == '+' or getTile(self.leftBoundary, math.floor((self.y + self.height - 2) / TILE_SIZE)) == '+' or
  getTile(self.rightBoundary, math.floor(self.y / TILE_SIZE)) == '+' or getTile(self.rightBoundary, math.floor((self.y + self.height - 2) / TILE_SIZE)) == '+' then
    self.maxGravity = 75
    self.velY = math.max(self.velY, 75)
  else
    self.maxGravity = -400
  end

  if getTile(self.leftBoundary, math.floor(self.y / TILE_SIZE)) == '^' or getTile(self.leftBoundary, math.floor((self.y + self.height - 2) / TILE_SIZE)) == '^' then
    self.newX = self.rightBoundary * TILE_SIZE
  elseif getTile(self.rightBoundary, math.floor(self.y / TILE_SIZE)) == '^' or getTile(self.rightBoundary, math.floor((self.y + self.height - 2) / TILE_SIZE)) == '^' then
    self.newX = (self.leftBoundary * TILE_SIZE) + self.width
  end

  if getTile(math.floor((self.newX + 2) / TILE_SIZE), self.upperBoundary) =='^' or getTile(math.ceil((self.newX - 18) / TILE_SIZE), self.upperBoundary) == '^' then
    self.velY = -1
    self.newY = self.lowerBoundary * TILE_SIZE
  end
  if getTile(math.floor((self.newX + 2) / TILE_SIZE), self.lowerBoundary)  == '^' or getTile(math.ceil((self.newX - 18) / TILE_SIZE), self.lowerBoundary) == '^' then
    self.velY = 500
    level.sounds["bounce"]:play()
    self.newY = (self.upperBoundary * TILE_SIZE) + (TILE_SIZE - self.height)
  end
end

function lerp(a, b, speed, dt)
  if b > a then
    a = math.min(a + (speed * dt), b)
  elseif b < a then
    a = math.max(a - (speed * dt), b)
  end
  return a
end
