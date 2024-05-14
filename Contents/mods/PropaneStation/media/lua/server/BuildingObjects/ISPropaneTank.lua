ISPropaneTank = ISBuildingObject:derive("ISPropaneTank");
function ISPropaneTank:new(sprite1, sprite2, northSprite1, northSprite2)
  local object = {};
  setmetatable(object, self);
  self.__index = self;
  object:init();
  object:setSprite(sprite1);
  object:setNorthSprite(northSprite1);
  object.sprite2 = sprite2;
  object.northSprite2 = northSprite2;
  object.name = "PropaneTank";
  return object;
end

function ISPropaneTank:create(x, y, z, north, sprite)
  
  local cell = getWorld():getCell();
  self.sq = cell:getGridSquare(x, y, z);
  local square1 = {x, y, z}

  local spriteAName = self.northSprite2;

  local xa = x;
  local ya = y;

  -- we get the x and y of our next tile (depend if we're placing the furniture north or not)
  if north then
    ya = ya - 1;
  else
    -- if we're not north we also change our sprite
    spriteAName = self.sprite2;
    xa = xa - 1;
  end
  
  local squareA = cell:getGridSquare(xa, ya, z);
  local square2 = {xa, ya, z}
  
  self:createIsoThumpable(self.sq, north, sprite, square2, self);
  self:createIsoThumpable(squareA, north, spriteAName, square1, self);
end

function ISPropaneTank:createIsoThumpable(square, north, sprite, squareA)
  -- instance new IsoThumpableObject
  local thumpable = IsoThumpable.new(getCell(), square, sprite, north, self)

  -- name of the item for the tooltip
  buildUtil.setInfo(thumpable, self)

  -- turn off zombie damage/thumping
  thumpable:setIsThumpable(false)

  -- place object in square
  square:AddSpecialObject(thumpable)

  -- propane station specific ModData
  thumpable:getModData()["fuelAmount"] = self.fuel
  thumpable:getModData()["partSquare"] = squareA
  thumpable:setSpecialTooltip(true)

  -- sent our object to the server
  thumpable:transmitCompleteItemToServer()

  -- make our addition trigger the OnObjectAdded event so other modders can detect it
  triggerEvent("OnObjectAdded", thumpable)
end
