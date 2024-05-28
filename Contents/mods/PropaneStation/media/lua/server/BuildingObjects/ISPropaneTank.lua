ISPropaneTank = ISBuildingObject:derive("ISPropaneTank");
function ISPropaneTank:new(sprites)
  local object = {}
  setmetatable(object, self)
  self.__index = self
  object:init()
  object:setSprite(sprites.A)
  object.name = "PropaneTank"
  return object
end

function ISPropaneTank:getSquareCoords(square)
  if not square then return end
  return square:getX(), square:getY(), square:getZ()
end

function ISPropaneTank:create(x, y, z, direction, sprites)
  local cell = getWorld():getCell();
  local squares = {}

  squares.A = {x = x, y = y, z = z}
  if direction == "EastWest" then
    squares.B = {x = x -1, y = y, z = z}
    squares.C = {x = x -2, y = y, z = z}
    squares.D = {x = x -3, y = y, z = z}
    squares.E = {x = x, y = y + 1, z = z}
    squares.F = {x = x - 1, y = y + 1, z = z}
    squares.G = {x = x -2, y = y + 1, z = z}
    squares.H = {x = x -3, y = y + 1, z = z}
  else
    squares.B = {x = x, y = y -1, z = z}
    squares.C = {x = x, y = y -2, z = z}
    squares.D = {x = x, y = y -3, z = z}
    squares.E = {x = x + 1, y = y, z = z}
    squares.F = {x = x + 1, y = y -1, z = z}
    squares.G = {x = x + 1, y = y -2, z = z}
    squares.H = {x = x + 1, y = y - 3, z = z}
  end

  self.partSquare = {x, y, z}
  for part, coords in pairs(squares) do
    local part_x, part_y, part_z = coords.x, coords.y, coords.z
    print("Propane Station: Square coordinates are " .. tostring(part_x) .. "," .. tostring(part_y) .. "," .. tostring(part_z))
    local square = cell:getGridSquare(part_x, part_y, part_z)
    if square == nil and getWorld():isValidSquare(part_x, part_y, part_z) then
      print("Propane Station: Square was nil, so we have to force it to load")
---@diagnostic disable-next-line: param-type-mismatch
      square = IsoGridSquare.new(cell, nil, part_x, part_y, part_z)
      cell:ConnectNewSquare(square, false)
    end
    print("Propane Station: Spawn details - part: " .. tostring(part) .. " at square: " .. tostring(square))
    self:createIsoThumpable(square, sprites[part])
  end
end

function ISPropaneTank:createIsoThumpable(square, sprite)
  if square == nil then
    print("PropaneTank: We received an invalid square in ISPropaneTank:createIsoThumpable")
  end

  -- instance new IsoThumpableObject
  local thumpable = IsoThumpable.new(getCell(), square, sprite, false, self)

  -- name of the item for the tooltip
  buildUtil.setInfo(thumpable, self)

  -- turn off zombie damage/thumping
  thumpable:setIsThumpable(false)

  -- place object in square
  square:AddSpecialObject(thumpable)

  thumpable:getModData()["partSquare"] = self.partSquare
  thumpable:setSpecialTooltip(true)

  -- send our object to the server
  thumpable:transmitCompleteItemToServer()

  -- make our addition trigger the OnObjectAdded event so other modders can detect it
  triggerEvent("OnObjectAdded", thumpable)
end
