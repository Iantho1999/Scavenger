Command = Class{}

function Command:init(x, y)
  self.x = x
  self.y = y
  self.oldTilemap = nil
  self.newTilemap = nil
end

function Command:place(tilemap, x, y, tile)
  self.oldTilemap = tileMap
  tilemap[x][y] = tile
end

function Command:undo(tilemap)
  self.newTilemap = tilemap
  tilemap = self.oldTilemap
  self.oldTilemap = nil
end
