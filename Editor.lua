Editor = Class{}

function Editor:init(lvlWidth, lvlHeight, lvlName)
  self.lvlWidth = lvlWidth
  self.lvlHeight = lvlHeight
  self.lvlName = lvlName
  self.testing = false
  self.index = 1
  self.tiling = false
  self.tilemap = nil
  self.uiScale = scale / 2
  self.commands = {}
  self.sprites = {
    love.graphics.newImage("Sprites/Player/Walking1.png"),
    love.graphics.newImage("Sprites/Tiles/rock.png"),
    love.graphics.newImage("Sprites/Tiles/onewayplatform.png"),
    love.graphics.newImage("Sprites/Tiles/phase.png"),
    love.graphics.newImage("Sprites/Tiles/bouncepad.png"),
    love.graphics.newImage("Sprites/Tiles/fuel.png"),
    love.graphics.newImage("Sprites/Tiles/volt.png"),
    love.graphics.newImage("Sprites/Tiles/portal5.png")
  }
  self.cursorColor = {1.0, 1.0, 1.0, 0.5}
  self.colors = {
    {1.0, 1.0, 1.0, 0.5},
    {0.2, 0.2, 0.6, 0.5},
    {0.30, 0.15, 0.10, 0.5},
    {0.5, 0.0, 1.0, 0.5},
    {1.0, 1.0, 1.0, 0.5},
    {1.0, 1.0, 1.0, 0.5},
    {1.0, 1.0, 1.0, 0.5},
    {1.0, 1.0, 1.0, 0.5}
  }
  self.letters = {
    'p', 'w', '-', '#', '^', 'f', 'v', 'o'
  }
  self.descriptions = {
    "Player", "Wall", "Platform", "Phase Block", "Bounce Pad", "Fuel", "Volt", "Portal"
  }

  self.menuBar = {
    width = love.graphics.getWidth() / self.uiScale,
    height = 80,
    offset = 40,
    startingWidth = love.graphics.getWidth() / scale - (20 * #self.sprites)
  }
  self.camera = {
    x = 0,
    y = 0,
    speed = 100
  }

  self.widthButton = {
    color = {0.48, 0.16, 0.08, 0.3},
    x = self.lvlWidth,
    selected = false,
    hovered = false
  }
  self.heightButton = {
    color = {0.48, 0.16, 0.08, 0.3},
    y = self.lvlHeight,
    selected = false,
    hovered = false
  }

  self.player = {
    placed = false,
    x = 0,
    y = 0
  }
  self.portal = {
    placed = false,
    x = 0,
    y = 0
  }
end

function Editor:update(dt)
  self.uiX = love.mouse.getX() / self.uiScale
  self.uiY = love.mouse.getY() / self.uiScale

  if loaded == false then
    addButtons(buttons, "Save", 12, 24, 120, 32, self.uiScale, function()
      saveFile(lvlName, self.tilemap, self.lvlWidth, self.lvlHeight)
    end)
    addButtons(buttons, "Play", 1148, 24, 120, 32, self.uiScale, function()
      saveFile(lvlName, self.tilemap, self.lvlWidth, self.lvlHeight)
      level:reset(string.gsub(lvlName, ".txt", "", 1))
      self.testing = true
      changegamestate("game")
    end)
    loaded = true
  end

  buttons[1].enabled = self.player.placed
  buttons[2].enabled = self.player.placed

  self.cursorColor = {1.0, 1.0, 1.0, 0.5}
  self.widthButton.color = {0.48, 0.16, 0.08, 0.3}
  self.widthButton.selected = false
  self.heightButton.color = {0.48, 0.16, 0.08, 0.3}
  self.heightButton.selected = false

  self.tileX = math.floor((mx + self.camera.x) / TILE_SIZE) + 1
  self.tileY = math.floor((my - self.menuBar.offset + self.camera.y) / TILE_SIZE) + 1

  local boundaryX = love.graphics.getWidth() / scale
  local boundaryY = love.graphics.getHeight() / scale

  if love.keyboard.isDown("lshift") then
    self.camera.speed = 800
  else
    self.camera.speed = 200
  end

  if (love.keyboard.isDown('s') or love.keyboard.isDown("down")) and self.camera.y - self.menuBar.offset + boundaryY < (self.lvlHeight * TILE_SIZE) + 180 then
    self.camera.y = self.camera.y + self.camera.speed * dt
  elseif (love.keyboard.isDown('w') or love.keyboard.isDown("up")) and self.camera.y > 0 then
    self.camera.y = self.camera.y - self.camera.speed * dt
  end

  if (love.keyboard.isDown('d') or love.keyboard.isDown("right")) and self.camera.x + boundaryX < (self.lvlWidth * TILE_SIZE) + 320 then
    self.camera.x = self.camera.x + self.camera.speed * dt
  elseif (love.keyboard.isDown('a') or love.keyboard.isDown("left")) and self.camera.x > 0 then
    self.camera.x = self.camera.x - self.camera.speed * dt
  end

  self.camera.x = math.max(self.camera.x, 0)
  self.camera.y = math.max(self.camera.y, 0)

  if self.tileX > self.lvlWidth and self.tileX < self.lvlWidth + 2 and my > self.menuBar.offset and self.tileY <= self.lvlHeight + 1 then
    self.widthButton.hovered = true
    self.widthButton.color = {0.48, 0.16, 0.08, 0.4}
  end

  if self.tileY > self.lvlHeight and self.tileY < self.lvlHeight + 2 and self.tileX > 0 and self.tileX <= self.lvlWidth + 1 then
    self.heightButton.hovered = true
    self.heightButton.color = {0.48, 0.16, 0.08, 0.4}
  end

  if love.mouse.isDown(1) then
    if self.widthButton.hovered == true and self.tiling == false then
      self.widthButton.selected = true
    end
    if self.heightButton.hovered == true and self.tiling == false then
      self.heightButton.selected = true
    end
    if self.tileX <= self.lvlWidth and self.tileY <= self.lvlHeight and my > self.menuBar.offset and self.widthButton.selected == false and self.heightButton.selected == false then
      self.cursorColor = {1.0, 1.0, 1.0, 1.0}
      if self.tilemap[self.tileY][self.tileX] ~= '>' and self.tilemap[self.tileY][self.tileX] ~= '<' and self.letters[self.index] ~= 'p' and self.letters[self.index] ~= 'o' then
        self.tilemap[self.tileY][self.tileX] = self.letters[self.index]
      end
      self.tiling = true
    elseif love.mouse.getY() >= 32 and love.mouse.getY() <= 64 then
      for i = 1, #self.sprites do
        if love.mouse.getX() >= self.menuBar.startingWidth + (40 * (i - 1)) - 4 and love.mouse.getX() <= self.menuBar.startingWidth + 36 + (40 * (i - 1)) then
          self.index = i
        end
      end
    end
  elseif love.mouse.isDown(2) and self.tileX <= self.lvlWidth and self.tileY <= self.lvlHeight and my > self.menuBar.offset then
    if self.player.x == self.tileX and self.player.y == self.tileY then
      self.player.placed = false
    end
    self.cursorColor = {0.3, 0.3, 0.3, 1.0}
    self.tilemap[self.tileY][self.tileX] = '.'
  end

  if self.widthButton.selected == true then
    self.widthButton.color = {0.48, 0.10, 0.04, 0.4}
    if self.tileX > self.lvlWidth + 1 and self.lvlWidth + self.lvlHeight <= 128 then
      self.lvlWidth = self.lvlWidth + 1
      for i = 1, self.lvlHeight do
        if self.tilemap[i][self.lvlWidth] == nil then
          self.tilemap[i][self.lvlWidth] = '.'
        end
      end
    elseif self.tileX <= self.lvlWidth then
      self.lvlWidth = math.max(self.lvlWidth - 1, 12)

      if self.player.x > self.lvlWidth then
        self.tilemap[self.player.y][self.player.x] = '.'
        self.player.placed = false
      end

      if self.portal.x > self.lvlWidth then
        self.tilemap[self.portal.y][self.portal.x] = '.'
        self.portal.placed = false
      end
    end
  else
    self.widthButton.hovered = false
  end

  if self.heightButton.selected == true then
    self.heightButton.color = {0.48, 0.10, 0.04, 0.4}
    if self.tileY > self.lvlHeight + 1 and self.lvlWidth + self.lvlHeight <= 128 then
      self.tilemap = self:headInsert(self.tilemap)
    elseif self.tileY <= self.lvlHeight and self.lvlHeight > 10 then
      self.tilemap = self:headRemove(self.tilemap)

      if self.player.y > self.lvlHeight then
        self.tilemap[self.player.y][self.player.x] = '.'
        self.player.placed = false
      end

      if self.portal.y > self.lvlWidth then
        self.tilemap[self.portal.y][self.portal.x] = '.'
        self.portal.placed = false
      end
    end
  else
    self.heightButton.hovered = false
  end

  if #self.commands > 10 then
    table.remove(self.commands, 1)
  end
end

function Editor:draw()
  love.graphics.setBackgroundColor(0.12, 0.05, 0.3)
  love.graphics.push()
  love.graphics.scale(scale, scale)
  love.graphics.push()
  love.graphics.translate(-self.camera.x, self.menuBar.offset - self.camera.y)

  --Draw width button
  love.graphics.setColor(self.widthButton.color)
  love.graphics.rectangle("fill", self.lvlWidth * TILE_SIZE, 0, TILE_SIZE, (self.lvlHeight * TILE_SIZE) + TILE_SIZE)

  --Draw height button
  love.graphics.setColor(self.heightButton.color)
  love.graphics.rectangle("fill", 0, self.lvlHeight * TILE_SIZE, (self.lvlWidth * TILE_SIZE) + TILE_SIZE, TILE_SIZE)

  love.graphics.setColor(0.48, 0.16, 0.08)
  love.graphics.rectangle("fill", 0, 0, self.lvlWidth * TILE_SIZE, self.lvlHeight * TILE_SIZE)
  for i = 1, self.lvlHeight do
    for j = 1, self.lvlWidth do
      if self.tilemap[i][j] == 'p' then
        love.graphics.setColor(1.0, 1.0, 1.0)
        love.graphics.draw(self.sprites[1], ((j - 1) * TILE_SIZE) + ((TILE_SIZE - self.sprites[1]:getWidth()) / 2), (i - 1) * TILE_SIZE)
      elseif self.tilemap[i][j] == 'w' then
        love.graphics.setColor(0.2, 0.2, 0.6)
        love.graphics.draw(self.sprites[2], (j - 1) * TILE_SIZE, (i - 1) * TILE_SIZE)
      elseif self.tilemap[i][j] == '-' then
        love.graphics.setColor(0.30, 0.15, 0.10)
        love.graphics.draw(self.sprites[3], (j - 1) * TILE_SIZE, (i - 1) * TILE_SIZE)
      elseif self.tilemap[i][j] == '#' then
        love.graphics.setColor(0.5, 0.0, 1.0)
        love.graphics.draw(self.sprites[4], (j - 1) * TILE_SIZE, (i - 1) * TILE_SIZE)
      elseif self.tilemap[i][j] == '^' then
        love.graphics.setColor(1.0, 1.0, 1.0)
        love.graphics.draw(self.sprites[5], (j - 1) * TILE_SIZE, (i - 1) * TILE_SIZE)
      elseif self.tilemap[i][j] == 'f' then
        love.graphics.setColor(1.0, 1.0, 1.0)
        love.graphics.draw(self.sprites[6], (j - 1) * TILE_SIZE, (i - 1) * TILE_SIZE)
      elseif self.tilemap[i][j] == '>' then
        love.graphics.setColor(0.0, 0.6, 0.0, 0.3)
        love.graphics.rectangle("fill", (j - 1) * TILE_SIZE, (i - 1) * TILE_SIZE, 128, TILE_SIZE)
        love.graphics.setColor(1.0, 1.0, 1.0)
        love.graphics.draw(self.sprites[7], ((j - 1) * TILE_SIZE) + ((TILE_SIZE - self.sprites[6]:getWidth()) / 2), (i - 1) * TILE_SIZE)
      elseif self.tilemap[i][j] == '<' then
        love.graphics.setColor(0.0, 0.6, 0.0, 0.3)
        love.graphics.rectangle("fill", (j - 4) * TILE_SIZE, (i - 1) * TILE_SIZE, 128, TILE_SIZE)
        love.graphics.setColor(1.0, 1.0, 1.0)
        love.graphics.draw(self.sprites[7], ((j - 1) * TILE_SIZE) + ((TILE_SIZE - self.sprites[6]:getWidth()) / 2), (i - 1) * TILE_SIZE)
      elseif self.tilemap[i][j] == 'o' then
        love.graphics.setColor(1.0, 1.0, 1.0)
        love.graphics.draw(self.sprites[8], (j - 1) * TILE_SIZE, (i - 1) * TILE_SIZE)
      end
    end
  end
if paused == false then
  if self.tileX <= self.lvlWidth and self.tileY <= self.lvlHeight and my > self.menuBar.offset then
    love.graphics.setColor(self.colors[self.index])
    love.graphics.draw(self.sprites[self.index], ((self.tileX - 1) * TILE_SIZE) + ((TILE_SIZE - self.sprites[self.index]:getWidth()) / 2), ((self.tileY - 1) * TILE_SIZE))
    love.graphics.setColor(self.cursorColor)
    love.graphics.rectangle("line", (self.tileX - 1) * TILE_SIZE, (self.tileY - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
  end
end

  love.graphics.pop()
  love.graphics.pop()
  love.graphics.push()
  love.graphics.scale(self.uiScale, self.uiScale)

  --Draw Menubar
  love.graphics.setColor(0.0, 0.3, 0.15, 0.8)
  love.graphics.rectangle("fill", 0, 0, self.menuBar.width, self.menuBar.height)

  for i = 1, #self.sprites do
    love.graphics.setColor(self.colors[i][1], self.colors[i][2], self.colors[i][3])
    love.graphics.draw(self.sprites[i], (self.menuBar.startingWidth + (40 * (i - 1))) + ((TILE_SIZE - self.sprites[i]:getWidth()) / 2), 32)
  end
  love.graphics.setColor(1.0, 1.0, 1.0, 0.5)
  love.graphics.rectangle("line", self.menuBar.startingWidth + (40 * (self.index - 1)), 32, TILE_SIZE, TILE_SIZE)
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.setFont(editorFont)
  love.graphics.printf(self.descriptions[self.index], 0, 2, self.menuBar.width, "center")
  love.graphics.printf("X: " .. math.min(self.tileX, self.lvlWidth) .. " Y: " .. math.max(math.min(self.tileY, self.lvlHeight), 0), 0, 2, self.menuBar.width, "left")

  if paused == true then
    love.graphics.pop()
    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.setColor(0.0, 0.0, 0.0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 640, 360)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.printf("Paused", 0, 32, 640, "center")
    love.graphics.setFont(editorFont)
    love.graphics.pop()
    love.graphics.push()
    love.graphics.scale(self.uiScale, self.uiScale)
  end
end

function Editor:keypressed(key)
  if paused == false then
    for i = 1, #self.sprites do
      if key == tostring(i) then
        self.index = i
      end
    end
  end


end


function Editor:wheelmoved(x, y)
  if y > 0 then
    if self.index + 1 > #self.sprites then
      self.index = 1
    else
      self.index = self.index + 1
    end
  elseif y < 0 then
    if self.index - 1 == 0 then
      self.index = #self.sprites
    else
      self.index = self.index - 1
    end
  end
end

function Editor:mousereleased(x, y, button)
  for i, v in ipairs(buttons) do
    buttons[i]:mousereleased(x, y, button)
  end


  self.tiling = false

  if button == 1 and self.tileX <= self.lvlWidth and self.tileY <= self.lvlHeight and self.tileX > 0 and my > self.menuBar.offset and self.widthButton.selected == false  and self.heightButton.selected == false then
    if self.letters[self.index] == 'p' then
      if self.player.placed == true then
        self.tilemap[self.player.y][self.player.x] = '.'
      end
      self.tilemap[self.tileY][self.tileX] = 'p'
      self.player.x = self.tileX
      self.player.y = self.tileY
      self.player.placed = true
    elseif self.letters[self.index] == 'o' then
      if self.portal.placed == true then
        self.tilemap[self.portal.y][self.portal.x] = '.'
      end
      self.tilemap[self.tileY][self.tileX] = 'o'
      self.portal.x = self.tileX
      self.portal.y = self.tileY
      self.portal.placed = true
    elseif self.letters[self.index] == 'v' then
      if self.tilemap[self.tileY][self.tileX] == '<' or self.tilemap[self.tileY][self.tileX] == 'v' then
        self.tilemap[self.tileY][self.tileX] = '>'
      elseif self.tilemap[self.tileY][self.tileX] == '>' then
        self.tilemap[self.tileY][self.tileX] = '<'
      end
    end
  end

  self.widthButton.selected = false
  self.heightButton.selected = false
end

function initTiles(lvlWidth, lvlHeight)
  local tY = {}
  for i = 1, lvlHeight do
    local tX = {}
    for j = 1, lvlWidth do
      tX[j] = '.'
    end
    tY[i] = tX
  end
  return tY
end

function Editor:headInsert(tMap)
  local newMap = {}
  local tOne = {}
  for i = 1, self.lvlWidth do
    tOne[i] = '.'
  end
  self.player.y = self.player.y + 1
  self.portal.y = self.portal.y + 1
  self.lvlHeight = self.lvlHeight + 1
  table.insert(newMap, tOne)
  for i = 1, #tMap do
    table.insert(newMap, tMap[i])
    tMap[i] = nil
  end
  tMap = nil
  return newMap
end

function Editor:headRemove(tMap)
  local newMap = {}
  tMap[1] = nil
  for i = 2, self.lvlHeight do
    table.insert(newMap, tMap[i])
    tMap[i] = nil
  end
  tMap = nil
  self.player.y = self.player.y - 1
  self.portal.y = self.portal.y - 1
  if self.player.y < 1 then
    self.player.placed = false
  end
  if self.portal.y < 1 then
    self.portal.placed = false
  end
  self.lvlHeight = self.lvlHeight - 1
  return newMap
end

function saveFile(filename, tMap, lvlWidth, lvlHeight)
  local file = nil
  file = love.filesystem.write(filename, "")
  for i = 1, lvlHeight do
    for j = 1, lvlWidth do
      file = love.filesystem.append(filename, tMap[i][j])
    end
    file = love.filesystem.append(filename, "\r\n")
  end
end
