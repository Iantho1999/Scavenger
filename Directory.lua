Directory = Class{}

function Directory:init(folder)
  self.folder = folder
  self.files = love.filesystem.getDirectoryItems(self.folder)
  self.index = 1
  self.page = 0
  self.limit = math.min(#self.files, 12)
  self.startingHeight = 172 - ((self.limit - 1) * 8)
  self.fileY = {}
  for i = 1, self.limit do
    self.fileY[i] = self.startingHeight + (16 * (i - 1))
  end
  self.nextButton = {
    hovered = false,
    enabled = true,
    x = 576,
    y = 64,
    width = 32,
    height = 232,
    color = {0.2, 0.1, 0.4}
  }
  self.prevButton = {
    hovered = false,
    enabled = true,
    x = 32,
    y = 64,
    width = 32,
    height = 232,
    color = {0.2, 0.1, 0.4}
  }
  self.hoverIndex = 0
  self.saving = false
end

function Directory:update(dt)
  if loaded == false then
    self.files = love.filesystem.getDirectoryItems(self.folder)
    self.index = 1
    addButtons(buttons, "Back", 64, 312, 120, 32, scale, function()
      loaded = false
      changegamestate(lastState)
    end)
    if toggleEditor == true then
      self.limit = math.min(#self.files, 12)
      addButtons(buttons, "New Level", 456, 24, 120, 32, scale, function()
        lvlName = ""
        editor.tilemap = initTiles(editor.lvlWidth, editor.lvlHeight)
        changegamestate("newlevel")
      end)
      if self.limit ~= 0 then
        addButtons(buttons, "Load", 456, 312, 120, 32, scale, function()
          paused = false
          loaded = false
          clearTable(buttons)
          clearTable(textboxes)
          lvlName = "Custom Levels/" .. self.files[self.index + (12 * self.page)]
          editor.tilemap = loadLevel(string.gsub(lvlName, ".txt", "", 1))
          editor.lvlWidth = #editor.tilemap[1]
          editor.lvlHeight = #editor.tilemap
          gamestate = "editor"
        end)
        addButtons(buttons, "Delete", 64, 24, 120, 32, scale, function()
          love.filesystem.remove("Custom Levels/" .. self.files[self.index + (12 * self.page)])
          clearTable(buttons)
          loaded = false
        end)
      end
    else
      self.limit = lvlSave
      addButtons(buttons, "Load", 456, 312, 120, 32, scale, function()
        paused = false
        lvlName = string.gsub(directory.folder .. self.files[self.index + (12 * self.page)], ".txt", "", 1)
        if self.folder == "Levels/" then
          lvlIndex = self.index
        end
        level:reset(lvlName)
        changegamestate("game")
      end)
      addCheckboxes(buttons, 456, 40, function()
        self.folder = "Custom Levels/"
        lvlIndex = 0
        self.files = love.filesystem.getDirectoryItems(self.folder)
        self.limit = math.min(#self.files, 12)
        self.startingHeight = 172 - ((self.limit - 1) * 8)
        clearTable(self.fileY)
        self.fileY = {}
        for i = 1, self.limit do
          self.fileY[i] = self.startingHeight + (16 * (i - 1))
        end
      end, function()
        self.folder = "Levels/"
        self.files = love.filesystem.getDirectoryItems(self.folder)
        self.limit = lvlSave
        self.startingHeight = 172 - ((self.limit - 1) * 8)
        clearTable(self.fileY)
        self.fileY = {}
        for i = 1, self.limit do
          self.fileY[i] = self.startingHeight + (16 * (i - 1))
        end
    end, false)
    end
    self.startingHeight = 172 - ((self.limit - 1) * 8)
    clearTable(self.fileY)
    self.fileY = {}
    for i = 1, self.limit do
      self.fileY[i] = self.startingHeight + (16 * (i - 1))
    end
    loaded = true
  end

  if #self.files - (12 * self.page) > 12 then
    self.nextButton.enabled = true
  else
    self.nextButton.enabled = false
  end

  if self.page > 0 then
    self.prevButton.enabled = true
  else
    self.prevButton.enabled = false
  end

  if self.fileY[1] ~= nil and my >= self.fileY[1] - 4 and my <= self.fileY[#self.fileY] + 12 and mx >= 96 and mx <= 542 then
    for i = 1, self.limit do
      if my >= self.fileY[i] - 4 and my <= self.fileY[i] + 12 then
        self.hoverIndex = i
      end
    end
  else
    self.hoverIndex = 0
  end

  if self.nextButton.enabled == true and mx >= self.nextButton.x and mx <= self.nextButton.x + self.nextButton.width and my >= self.nextButton.y and my <= self.nextButton.y + self.nextButton.height then
    self.nextButton.hovered = true
    self.nextButton.color = {0.3, 0.2, 0.7}
  else
    self.nextButton.hovered = false
    self.nextButton.color = {0.2, 0.1, 0.4}
  end

  if self.prevButton.enabled == true and mx >= self.prevButton.x and mx <= self.prevButton.x + self.prevButton.width and my >= self.prevButton.y and my <= self.prevButton.y + self.prevButton.height then
    self.prevButton.hovered = true
    self.prevButton.color = {0.3, 0.2, 0.7}
  else
    self.prevButton.hovered = false
    self.prevButton.color = {0.2, 0.1, 0.4}
  end

  if love.mouse.isDown(1) then
    if self.hoverIndex ~= 0 then
      self.index = self.hoverIndex
    end

    if self.nextButton.hovered == true then
      self.nextButton.color = {0.1, 0.1, 0.3}
    end

    if self.prevButton.hovered == true then
      self.prevButton.color = {0.1, 0.1, 0.3}
    end

  end
end

function Directory:draw()
  love.graphics.setBackgroundColor(0.48, 0.16, 0.08)
  love.graphics.push()
  love.graphics.scale(scale, scale)
  love.graphics.setColor(0.4, 0.1, 0.05)
  love.graphics.rectangle("fill", 64, 64, 512, 232)
  if self.hoverIndex ~= 0 then
    love.graphics.setColor(1.0, 1.0, 1.0, 0.1)
    love.graphics.rectangle("fill", 96, self.fileY[self.hoverIndex] - 4, 448, 16)
  end

  if self.nextButton.enabled == true then
    love.graphics.setColor(self.nextButton.color)
    love.graphics.rectangle("fill", self.nextButton.x, self.nextButton.y, self.nextButton.width, self.nextButton.height)
  end

  if self.prevButton.enabled == true then
    love.graphics.setColor(self.prevButton.color)
    love.graphics.rectangle("fill", self.prevButton.x, self.prevButton.y, self.prevButton.width, self.prevButton.height)
  end

  love.graphics.setFont(editorFont)
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.printf("Select Level", 0, 32, 640, "center")
  love.graphics.setFont(subTitleFont)
  if toggleEditor == false then
    love.graphics.print("Custom", 480, 44)
  end
    if self.limit ~= 0 then
      for i = 1, self.limit do
        love.graphics.printf(string.gsub(self.files[i + (12 * self.page)], ".txt", "", 1), 0, self.fileY[i], 640, "center")
      end
      love.graphics.rectangle("line", 96, self.fileY[self.index] - 4, 448, 16)
    end
end

function Directory:mousereleased(x, y, button)
  if button == 1 then
    if self.nextButton.hovered == true then
      self.index = 1
      self.page = self.page + 1
      self.limit = math.min(#self.files - (12 * self.page), 12)
      self.startingHeight = 172 - ((self.limit - 1) * 8)
      clearTable(self.fileY)
      self.fileY = {}
      for i = 1, self.limit do
        self.fileY[i] = self.startingHeight + (16 * (i - 1))
      end
    elseif self.prevButton.hovered == true then
      self.index = 1
      self.page = self.page - 1
      self.limit = math.min(#self.files - (12 * self.page), 12)
      self.startingHeight = 172 - ((self.limit - 1) * 8)
      clearTable(self.fileY)
      self.fileY = {}
      for i = 1, self.limit do
        self.fileY[i] = self.startingHeight + (16 * (i - 1))
      end
    end
  end
end
