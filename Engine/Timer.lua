Timer = Class{}

function Timer:init()
  self.seconds = 0
  self.timed = false
end

function Timer:update(dt)
  if self.seconds > 0 then
    self.seconds = self.seconds - 1 * dt
  elseif self.seconds < 0 then
    if self.timed == false then
      self.timed = true
    end
  end
end
