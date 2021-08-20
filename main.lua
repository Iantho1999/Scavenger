Class = require "Engine/class"
utf8 = require "utf8"
require "Level"
require "Editor"
require "Directory"
require "Engine/Camera"
require "Engine/Button"
require "Engine/Checkbox"
require "Engine/Timer"
require "Engine/Textbox"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
TILE_SIZE = 32
MAXLVL = 3


local cFullscreen = false
local cVsync = true
buttons = {}
textboxes = {}
loaded = false
paused = false
lvlName = ""
lvlIndex = 1
toggleEditor = false

function love.load()
  love.window.setTitle("Scavenger - Demo")
  love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = cFullscreen, vsync = cVsync, resizable = false})
  love.graphics.setDefaultFilter("nearest", "nearest")

  love.filesystem.createDirectory("Custom Levels/")
  lvlSave = love.filesystem.read("save.txt")
  if lvlSave == nil then
    lvlSave = 1
    love.filesystem.newFile("save.txt")
    love.filesystem.write("save.txt", lvlSave)
  end

  scale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)
  lastState = ""
  gamestate = "title"
  select = love.audio.newSource("Sounds/select.wav", "static")
  editor = Editor(12, 12, "Levels/Level 1.txt")
  player = Player(-1, -1)
  level = Level("Levels/Level " .. lvlIndex)
  camera = Camera()
  directory = Directory("Custom Levels/")

  titleFont = love.graphics.newFont("Sprites/prstartk.ttf", 24)
  editorFont = love.graphics.newFont("Sprites/PrStart.ttf", 16)
  subTitleFont = love.graphics.newFont("Sprites/PrStart.ttf", 8)

end

function love.update(dt)

  mx = love.mouse.getX() / scale
  my = love.mouse.getY() / scale
  if gamestate == "title" then
    if loaded == false then
      local column = 0
      player.fuelBuffer = 0
      addButtons(buttons, "Start Game", 260, 116 + (48 * column), 120, 32, scale, function()
        paused = false
        directory.folder = "Levels/"
        toggleEditor = false
        lvlIndex = 1
        lvlName = "Levels/Level " .. lvlIndex
        level:reset("Levels/Level " .. lvlIndex)
        changegamestate("directory")
      end)
      column = column + 1

      addButtons(buttons, "Level Editor", 260, 116 + (48 * column), 120, 32, scale, function()
        lvlIndex = 0
        paused = false
        directory.folder = "Custom Levels/"
        toggleEditor = true
        editor.player.placed = false
        changegamestate("directory")
      end)
      column = column + 1

      addButtons(buttons, "Options", 260, 116 + (48 * column), 120, 32, scale, function()
        changegamestate("options")
      end)
      column = column + 1

      addButtons(buttons, "Exit", 260, 116 + (48 * column), 120, 32, scale, function()
        clearTable(buttons)
        love.event.quit()
      end)

      loaded = true
    end

  elseif gamestate == "game" and paused == false then
    level:update(dt)
    camera:update(dt)
  elseif gamestate == "game" and paused == true then
    if loaded == false then
      addButtons(buttons, "Resume", 260, 110, 120, 32, scale, function()
        paused = false
        changegamestate("game")
      end)
      addButtons(buttons, "Retry", 260, 162, 120, 32, scale, function()
        level:reset(string.gsub(lvlName, ".txt", "", 1))
        paused = false
        changegamestate("game")
      end)
      addButtons(buttons, "Options", 260, 214, 120, 32, scale, function()
        changegamestate("options")
      end)
      addButtons(buttons, "To Main Menu", 260, 266, 120, 32, scale, function()
        paused = false
        changegamestate("title")
      end)
      loaded = true
    end
  elseif gamestate == "options" then
    if loaded == false then
      addCheckboxes(buttons, 352, 90, function()
        cFullscreen = true
      end, function()
        cFullscreen = false
      end, cFullscreen)
      addCheckboxes(buttons, 352, 150, function()
        cVsync = true
      end, function()
        cVsync = false
      end, cVsync)
      addButtons(buttons, "Back", 170, 240, 120, 32, scale, function()
        changegamestate(lastState)
      end)
      addButtons(buttons, "Apply", 350, 240, 120, 32, scale, function()
        love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = cFullscreen, vsync = cVsync})
        for i, v in ipairs(buttons) do
          if buttons[i].scale == scale then
            buttons[i].scale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)
          end
        end
        scale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)
        editor.uiScale = scale / 2
      end)
      loaded = true
    end
  elseif gamestate == "clear" then
      if loaded == false then
        if editor.testing == true then
          addButtons(buttons, "Back to Editor", 260, 132, 120, 32, scale, function()
              changegamestate("editor")
              editor.testing = false
          end)
        elseif lvlIndex < MAXLVL and lvlIndex > 0 then
          lvlSave = math.max(math.min(lvlIndex + 1, MAXLVL), lvlSave)
          addButtons(buttons, "Next Level", 260, 132, 120, 32, scale, function()
            lvlIndex = lvlIndex + 1
            love.filesystem.write("save.txt", lvlSave)
            lvlName = "Levels/Level " .. lvlIndex
            level:reset(lvlName)
            changegamestate("game")
          end)
        end
        addButtons(buttons, "Main Menu", 260, 164 + (32 * #buttons), 120, 32, scale, function()
          changegamestate("title")
          editor.testing = false
        end)
        loaded = true
      end
    elseif gamestate == "directory" then
      directory:update(dt)
    elseif gamestate == "editor" then
      if paused == false then
        editor:update(dt)
      elseif loaded == false then
        clearTable(buttons)
        addButtons(buttons, "Resume", 520, 220, 240, 64, editor.uiScale, function()
          clearTable(buttons)
          loaded = false
          paused = false
        end)
        addButtons(buttons, "Rename", 520, 324, 240, 64, editor.uiScale, function()
          paused = false
          changegamestate("newlevel")
        end)
        addButtons(buttons, "Load Level", 520, 428, 240, 64, editor.uiScale, function()
          directory.page = 0
          changegamestate("directory")
        end)
        addButtons(buttons, "Main Menu", 520, 532, 240, 64, editor.uiScale, function()
          paused = false
          changegamestate("title")
        end)
      end
    elseif gamestate == "newlevel" then
      if loaded == false then
        addTextboxes(textboxes, 208, 172, 224, 18, subTitleFont)
        textboxes[1].active = true
        textboxes[1].text = string.gsub(lvlName, "Custom Levels/", "", 1)
        textboxes[1].text = string.gsub(textboxes[1].text, ".txt", "", 1)
        addButtons(buttons, "Back", 190, 200, 120, 32, scale, function()
          changegamestate(lastState)
        end)
        addButtons(buttons, "Create", 330, 200, 120, 32, scale, function()
          paused = false
          editor.portal.placed = false
          lvlName = "Custom Levels/" .. textboxes[1].text .. ".txt"
          changegamestate("editor")
        end)
        loaded = true
      end
    end

  for i, v in ipairs(buttons) do
    buttons[i]:update(dt)
  end

  for i, v in ipairs(textboxes) do
    textboxes[i]:update(dt)
  end

end

function love.draw()
  love.graphics.setBackgroundColor(0.48, 0.16, 0.08, 1.0)
  if gamestate == "game" then
    love.graphics.setBackgroundColor(0.0, 0.0, 0.0)
    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.push()
    love.graphics.translate(-camera.offsetX, -camera.offsetY)
    love.graphics.setColor(0.48, 0.16, 0.08)
    love.graphics.rectangle("fill", 0, 0, level.width * TILE_SIZE, level.height * TILE_SIZE)
    level:draw()
    love.graphics.pop()
    if paused == true then
      love.graphics.setColor(0.0, 0.0, 0.0, 0.5)
      love.graphics.rectangle("fill", 0, 0, 640, 360)
      love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
      love.graphics.setFont(titleFont)
      love.graphics.printf("Paused", 0, 32, camera.width, "center")
      love.graphics.setFont(subTitleFont)
    else
      --HUD
      love.graphics.setFont(subTitleFont)
      love.graphics.draw(player.jetpack["activate"].frames[1], 610, 8)
      love.graphics.print("x" .. player.fuel, 620, 8)
    end
  elseif gamestate == "title" then
    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.setFont(titleFont)
    love.graphics.printf("Scavenger", 0, 32, camera.width, "center")
    love.graphics.setFont(subTitleFont)
  elseif gamestate == "options" then
    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.setFont(titleFont)
    love.graphics.printf("Options", 0, 32, camera.width, "center")
    love.graphics.setFont(subTitleFont)
    love.graphics.print("Fullscreen", 260, 93)
    love.graphics.print("Vsync", 281, 155)
  elseif gamestate == "clear" then
    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.setFont(titleFont)
    love.graphics.printf("Level Clear", 0, 32, camera.width, "center")
    love.graphics.setFont(subTitleFont)
  elseif gamestate == "directory" then
    directory:draw()
  elseif gamestate == "editor" then
    editor:draw()
  elseif gamestate == "newlevel" then
      love.graphics.setBackgroundColor(0.48, 0.16, 0.08)
      love.graphics.push()
      love.graphics.scale(scale, scale)
      love.graphics.setFont(editorFont)
      love.graphics.printf("Enter Name", 0, 125, 640, "center")
      love.graphics.setFont(subTitleFont)
  end

  for i, v in ipairs(buttons) do
    buttons[i]:draw()
  end

  for i, v in ipairs(textboxes) do
    textboxes[i]:draw()
  end

  local stats = love.graphics.getStats()

  -- Debug Info
  --[[

  love.graphics.print("MouseX: " .. mx, 10, 40)
  love.graphics.print("MouseY: " .. my, 10, 50)
  love.graphics.print(lvlSave, 10, 10)
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.setFont(subTitleFont)
  love.graphics.print(love.timer.getFPS() .. " FPS", 10, 10)
  love.graphics.print("Drawcalls: " .. stats.drawcalls, 10, 30)

  ]]--

  love.graphics.pop()
end

function love.keypressed(key)
  if key == "escape" then
    if editor.testing == true then
      changegamestate("editor")
      editor.testing = false
    elseif paused == false then
      loaded = false
      paused = true
    else
      clearTable(buttons)
      loaded = false
      paused = false
    end
  end

  if gamestate == "game" then
    level:keypressed(key)
  elseif gamestate == "editor" then
    editor:keypressed(key)
  end
end

function love.keyreleased(key)
  if gamestate == "game"  then
    level:keyreleased(key)
  end
end

function love.wheelmoved(x, y)
  if gamestate == "editor" and paused == false then
    editor:wheelmoved(x, y)
  end
end

function love.mousepressed(x, y)
  mx = x / scale
  my = y / scale
  for i, v in ipairs(textboxes) do
    textboxes[i]:mousepressed(mx, my)
  end
end

function love.mousereleased(x, y, button)
  if gamestate == "editor" and paused == false then
    editor:mousereleased(x, y, button)
  elseif gamestate == "directory" then
    directory:mousereleased(x, y, button)
  end

  for i, v in ipairs(buttons) do
    buttons[i]:mousereleased(x, y, button)
  end
end

function love.textinput(text)
  for i, v in ipairs(textboxes) do
    textboxes[i]:textinput(text)
  end
end

function changegamestate(state)
  loaded = false
  clearTable(buttons)
  clearTable(textboxes)
  lastState = gamestate
  gamestate = state
end

--[[

codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode
codecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecodecode


]]--
