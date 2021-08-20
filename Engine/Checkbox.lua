Checkbox = Class{}

function Checkbox:init(x, y, fnOne, fnTwo, checked)
  self.x = x
  self.y = y
  self.width = 16
  self.height = 16
  self.fnOne = fnOne
  self.fnTwo = fnTwo
  self.hovered = false
  self.checked = checked
  self.color = {0.0, 0.0, 0.0, 0.3}
end

function Checkbox:update(dt)
  if mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height then
    self.hovered = true
    if love.mouse.isDown('1') then
      self.color = {0.0, 0.0, 0.0, 0.3}
    else
      self.color = {1.0, 1.0, 1.0, 0.3}
    end
  else
    self.hovered = false
  end
end

function Checkbox:draw()
  if self.hovered == true then
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  end
  if self.checked == true then
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.rectangle("fill", self.x + 2, self.y + 2, self.width - 4, self.height - 4)
  end

  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function Checkbox:mousereleased(x, y, button)
  if button == 1 and self.hovered == true then
    select:play()
    if self.checked == false then
      self.fnOne()
      self.checked = true
    else
      self.fnTwo()
      self.checked = false
    end
  end
end

function addCheckboxes(tbl, x, y, fnOne, fnTwo, checked)
  local checkbox = Checkbox(x, y, fnOne, fnTwo, checked)
  table.insert(tbl, checkbox)
end
