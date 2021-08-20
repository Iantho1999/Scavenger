Animation = Class{}

function Animation:init(filename, index, numframes, speed)
  self.filename = filename
  self.index = index
  self.frame = index
  self.speed = speed
  self.numframes = numframes
  self.frames = {}

  for i = self.index, self.numframes do
    self.frames[i] = love.graphics.newImage(self.filename .. i .. ".png")
  end
end

function Animation:update(dt)
  if self.frame >= self.numframes + 1 then
    self.frame = 1
  else
    self.frame = self.frame + (self.speed * dt)
  end
  self.index = math.min(math.floor(self.frame), self.numframes)
end
