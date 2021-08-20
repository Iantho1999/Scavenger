Textbox = Class{}

function Textbox:init(x, y, width, height, font)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.hovered = false
  self.active = false
  self.drawRect = true
  self.timer = Timer()
  self.backspaceTime = 0
  self.font = font
  self.text = ""
  self.color = {0.0, 0.0, 0.2}
end

function Textbox:update(dt)
  self.timer:update(dt)
  if mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height then
    self.hovered = true
    self.color = {0.05, 0.05, 0.3}
  else
    self.hovered = false
    self.color = {0.0, 0.0, 0.2}
  end
  if self.active == true then
    if self.timer.seconds == 0 then
      self.timer.seconds = 0.5
    end
  end

  if love.keyboard.isDown("backspace") and self.active == true then
    if self.backspaceTime == 0 or self.backspaceTime > 0.5 then
      local byteoffset = utf8.offset(self.text, -1)

      if byteoffset then
        self.text = string.sub(self.text, 1, byteoffset - 1)
      end
    end
    self.backspaceTime = self.backspaceTime + 1 * dt

  else
    self.backspaceTime = 0
  end

  if self.timer.seconds < 0 then
    if self.drawRect == false then
      self.drawRect = true
    else
      self.drawRect = false
    end
    self.timer.seconds = 0
  end
end

function Textbox:draw()
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.setFont(self.font)
  -- love.graphics.print(self.backspaceTime, 0, 0)
  love.graphics.printf(self.text, self.x + 4, self.y + 4, self.width, "left")
  if self.drawRect == true and self.active == true then
    love.graphics.rectangle("fill", self.x + 5 + self.font:getWidth(self.text), self.y + 2, 4, 12)
  end
end


function Textbox:mousepressed(mx, my)
  if self.hovered == true then
    self.active = true
  else
    self.active = false
  end
end



function Textbox:textinput(text)
  if self.active == true and self.font:getWidth(self.text) < self.width - 16 then
    self.text = self.text .. text
  end
end

function addTextboxes(txtboxes, x, y, width, height, font)
  local txtbox = Textbox(x, y, width, height, font)
  table.insert(txtboxes, txtbox)
  return txtboxes
end
