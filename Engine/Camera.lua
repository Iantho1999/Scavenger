Camera = Class{}

function Camera:init()
  self.x = 0
  self.y = 0
  self.width = love.graphics.getWidth() / scale
  self.height = love.graphics.getHeight() / scale
  self.visibleTilesX = self.width / TILE_SIZE
  self.visibleTilesY = self.height / TILE_SIZE
  self.offsetX = self.x - self.width / 2
  self.offsetY = self.y - self.height / 2
end


function Camera:update(dt)


  if player.x <= (self.width / 2) or self.visibleTilesX > level.width then
    self.x = (self.width / 2)
  elseif player.x >= (level.width * TILE_SIZE) - (self.width / 2) then
    self.x = (level.width * TILE_SIZE) - (self.width / 2)
  else
    self.x = player.x
  end

  if player.y <= (self.height / 2) or self.visibleTilesY > level.height then
  self.y = (self.height / 2)
  elseif player.y >= (level.height * TILE_SIZE) - (self.height / 2)then
    self.y = (level.height * TILE_SIZE) - (self.height / 2)
  else
    self.y = player.y
  end
  self.offsetX = self.x - self.width / 2
  self.offsetY = self.y - self.height / 2
end
