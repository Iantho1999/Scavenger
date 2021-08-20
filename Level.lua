Level = Class{}

require "Engine/Animation"
require "Objects/Player"
require "Objects/Wall"
require "Objects/Platform"
require "Objects/PhPlatform"
require "Objects/Spike"
require "Objects/OneWayPlatform"
require "Objects/Bouncepad"
require "Objects/Volt"
require "Objects/Portal"
require "Objects/Sign"
require "Objects/Beam"
require "Objects/Fuel"

function Level:init(filename)
  player.x = -32
  player.y = -32
  player.fuel = player.fuelBuffer
  self.walls = {}
  self.wallSprite = love.graphics.newImage("Sprites/Tiles/rock.png")
  self.wallBatch = love.graphics.newSpriteBatch(self.wallSprite)
  self.platforms = {}
  self.phplatforms = {}
  self.phaseSprite = love.graphics.newImage("Sprites/Tiles/phase.png")
  self.phaseBatch = love.graphics.newSpriteBatch(self.phaseSprite)
  self.spikes = {}
  self.onewayplatforms = {}
  self.platformSprite = love.graphics.newImage("Sprites/Tiles/onewayplatform.png")
  self.platformBatch = love.graphics.newSpriteBatch(self.platformSprite)
  self.bouncepads = {}
  self.bouncepadSprite = love.graphics.newImage("Sprites/Tiles/bouncepad.png")
  self.bouncepadBatch = love.graphics.newSpriteBatch(self.bouncepadSprite)
  self.volts = {}
  self.voltSprite = love.graphics.newImage("Sprites/Tiles/volt.png")
  self.voltBatch = love.graphics.newSpriteBatch(self.voltSprite)
  self.portals = {}
  self.signs = {}
  self.beams = {}
  self.tanks = {}
  self.tankSprite = love.graphics.newImage("Sprites/Tiles/fuel.png")
  self.tankBatch = love.graphics.newSpriteBatch(self.tankSprite)
  self.sounds = {
    ["jump"] = love.audio.newSource("Sounds/jump.wav", "static"),
    ["bounce"] = love.audio.newSource("Sounds/bounce.wav", "static"),
    ["death"] = love.audio.newSource("Sounds/death.wav", "static"),
    ["portal"] = love.audio.newSource("Sounds/portal.wav", "static"),
    ["fuel"] = love.audio.newSource("Sounds/fuel.wav", "static")
  }
  self.tilemap = loadLevel(filename)
  if self.tilemap == nil then
    self.index = 1
    gameState = "title"
  end
  self.width = #self.tilemap[1]
  self.height = #self.tilemap
  self:placeTiles()
end

function loadLevel(filename)
  local tMap = {}
  local i = 1
  for line in love.filesystem.lines(filename .. ".txt") do
    local vec = {}
    for j in line:gmatch(".") do
      vec[#vec + 1] = j
      if vec[#vec] == 'p' then
        editor.player.placed = true
        editor.player.x = #vec
        editor.player.y = i
      elseif vec[#vec] == 'o' then
        editor.portal.placed = true
        editor.portal.x = #vec
        editor.portal.y = i
      end
    end
    tMap[i] = vec
    i = i + 1
  end
  return tMap
end

function Level:placeTiles()
  for i = 1, self.height do
    for j = 1, self.width do
      if self.tilemap[i][j] == 'p' then
        player.x = (j - 1) * TILE_SIZE
        player.y = ((i - 1) * TILE_SIZE) + 2
        player.newX = player.x
        player.newY = player.y
        player.velY = 0
        player.drawPack = false
      elseif self.tilemap[i][j] == 'w' then
        local wall = Wall(j - 1, i - 1)
        table.insert(self.walls, wall)
      elseif self.tilemap[i][j] == '^' then
        local bouncepad = Bouncepad(j - 1, i - 1)
        table.insert(self.bouncepads, bouncepad)
      elseif self.tilemap[i][j] == '#' then
        local phplatform = PhPlatform(j - 1, i - 1)
        table.insert(self.phplatforms, phplatform)
      elseif self.tilemap[i][j] == 'x' then
        local spike = Spike(j - 1, i - 1)
        table.insert(self.spikes, spike)
      elseif self.tilemap[i][j] == '-' then
        local onewayplatform = OneWayPlatform(j - 1, i - 1)
        table.insert(self.onewayplatforms, onewayplatform)
      elseif self.tilemap[i][j] == '>' then
        local volt = Volt(j - 1, i - 1, j - 1, j + 2)
        table.insert(self.volts, volt)
      elseif self.tilemap[i][j] == '<' then
        local volt = Volt(j - 1, i - 1, j - 4, j - 1)
        table.insert(self.volts, volt)
      elseif self.tilemap[i][j] == 'o' then
        local portal = Portal(j - 1, i - 1)
        table.insert(self.portals, portal)
      elseif self.tilemap[i][j] == 's' then
        local sign = Sign(j - 1, i - 1)
        table.insert(self.signs, sign)
      elseif self.tilemap[i][j] == '+' then
        local beam = Beam(j - 1, i - 1)
        table.insert(self.beams, beam)
      elseif self.tilemap[i][j] == 'f' then
        local fuel = Fuel(j - 1, i - 1)
        table.insert(self.tanks, fuel)
      end
    end
  end
end

function Level:update(dt)
  updateBatch(self.wallBatch, self.walls)
  updateBatch(self.platformBatch, self.onewayplatforms)
  updateBatch(self.bouncepadBatch, self.bouncepads)
  updateBatch(self.voltBatch, self.volts)
  updateTempBatch(self.tankBatch, self.tanks)

  player:update(dt)

  for i, v in ipairs(self.phplatforms) do
    self.phplatforms[i]:update(dt)
  end

  updateTempBatch(self.phaseBatch, self.phplatforms)

  for i, v in ipairs(self.platforms) do
    self.platforms[i]:update(dt)
  end

  for i, v in ipairs(self.onewayplatforms) do
    self.onewayplatforms[i]:update(dt)
  end

  for i, v in ipairs(self.volts) do
    self.volts[i]:update(dt)
  end

  for i, v in ipairs(self.tanks) do
    if self.tanks[i].activated == false then
      self.tanks[i]:update(dt)
    end
  end

  for i, v in ipairs(self.portals) do
    self.portals[i]:update(dt)
  end
end

function Level:draw()

    love.graphics.setColor(0.5, 0.0, 1.0)
    love.graphics.draw(self.phaseBatch)

    for i, v in ipairs(self.phplatforms) do
      if self.phplatforms[i].x + TILE_SIZE >= camera.offsetX and self.phplatforms[i].x <= camera.offsetX + camera.width
      and self.phplatforms[i].y + TILE_SIZE >= camera.offsetY and self.phplatforms[i].y <= camera.offsetY + camera.height
      and self.phplatforms[i].activated == true then
        self.phplatforms[i]:draw()
      end
    end

    player:draw()

    for i, v in ipairs(self.beams) do
      self.beams[i]:draw()
    end

    love.graphics.setColor(0.30, 0.15, 0.10)
    love.graphics.draw(self.platformBatch)


    for i, v in ipairs(self.spikes) do
      self.spikes[i]:draw()
    end

    for i, v in ipairs(self.platforms) do
      self.platforms[i]:draw()
    end

    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(self.bouncepadBatch)

    love.graphics.draw(self.tankBatch)

    love.graphics.setColor(0.2, 0.2, 0.6)
    love.graphics.draw(self.wallBatch)

    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(self.voltBatch)

    for i, v in ipairs(self.portals) do
      if self.portals[i].x + TILE_SIZE >= camera.offsetX and self.portals[i].x <= camera.offsetX + camera.width
      and self.portals[i].y + TILE_SIZE >= camera.offsetY and self.portals[i].y <= camera.offsetY + camera.height then
        self.portals[i]:draw()
      end
    end

    for i, v in ipairs(self.signs) do
      if self.signs[i].x + TILE_SIZE >= camera.offsetX and self.signs[i].x <= camera.offsetX + camera.width
      and self.signs[i].y + TILE_SIZE >= camera.offsetY and self.signs[i].y <= camera.offsetY + camera.height then
        self.signs[i]:draw()
      end
    end
end

function Level:reset(filename)
  player.x = -1
  player.y = -1
  player.newX = player.x
  player.newY = player.y
  clearTable(self.walls)
  clearTable(self.phplatforms)
  clearTable(self.bouncepads)
  clearTable(self.onewayplatforms)
  clearTable(self.signs)
  clearTable(self.beams)
  clearTable(self.volts)
  clearTable(self.tanks)
  for i = #self.tilemap, 1, -1 do
    clearTable(self.tilemap[i])
  end
  clearTable(self.tilemap)
  self:init(filename)
end

function clearTable(table)
  if table ~= nil then
    for i = #table, 1, -1 do
      table[i] = nil
    end
  end
end

function Level:keypressed(key)
  player:keypressed(key)
end

function Level:keyreleased(key)
  player:keyreleased(key)
end

function getTile(x, y)
  if x >= 0 and x < level.width and y >= 0 and y < level.height then
    return level.tilemap[y+1][x+1]
  else
    return "."
  end
end

function updateBatch(spriteBatch, objects)
  spriteBatch:clear()
  for i = 1, #objects do
    if objects[i].x + TILE_SIZE >= camera.offsetX and objects[i].x <= camera.offsetX + camera.width
    and objects[i].y + TILE_SIZE >= camera.offsetY and objects[i].y <= camera.offsetY + camera.height then
      spriteBatch:add(objects[i].x, objects[i].y)
    end
  end
  spriteBatch:flush()
end

function updateTempBatch(spriteBatch, objects)
  spriteBatch:clear()
  for i = 1, #objects do
    if objects[i].x + TILE_SIZE >= camera.offsetX and objects[i].x <= camera.offsetX + camera.width
    and objects[i].y + TILE_SIZE >= camera.offsetY and objects[i].y <= camera.offsetY + camera.height
    and objects[i].activated == false then
      spriteBatch:add(objects[i].x, objects[i].y)
    end
  end
  spriteBatch:flush()
end
