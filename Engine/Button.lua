Button = Class{}

function Button:init(text, x, y, width, height, scale, fn)
  self.text = text
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.scale = scale
  self.fn = fn
  self.enabled = true
  self.hovered = false
  self.color = {0.0, 0.0, 1.0}
end

function Button:update(dt)
  self.mx = love.mouse.getX() / self.scale
  self.my = love.mouse.getY() / self.scale
  if self.enabled == false then
    self.color = {0.25, 0.25, 0.25}
  elseif self.mx >= self.x and self.mx <= self.x + self.width and self.my >= self.y and self.my <= self.y + self.height then
    self.hovered = true
    if love.mouse.isDown('1') then
      self.color = {0.1, 0.1, 0.3}
    else
      self.color = {0.3, 0.2, 0.7}
    end
  else
    self.hovered = false
    self.color = {0.2, 0.1, 0.4}
  end
end

function Button:draw()
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.printf(self.text, self.x, self.y + (self.height / 2) - 4, self.width, "center")
end

function Button:mousereleased(x, y, button)
  if button == 1 and self.hovered == true then
    select:play()
    self.fn()
  end
end

function addButtons(tbl, text, x, y, width, height, scale, fn)
  local button = Button(text, x, y, width, height, scale, fn)
  table.insert(tbl, button)
end
