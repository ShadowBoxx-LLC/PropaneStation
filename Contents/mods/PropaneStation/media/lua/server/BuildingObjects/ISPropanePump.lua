ISPropanePump = ISBuildingObject:derive("ISPropanePump");
function ISPropanePump:new(sprite)
  local object = {};
  setmetatable(object, self);
  self.__index = self;
  object:init();
  object:setSprite(sprite);
  object.name = "PropanePump";
  return object;
end

function ISPropanePump:create(x, y, z, sprite)
  self.fuel = 1000 - ZombRand(300);
  
  local cell = getWorld():getCell();
  self.square = cell:getGridSquare(x, y, z);
  self.partSquare = {x, y, z}
  
  self:createIsoThumpable(self.square, sprite, self);
end

function ISPropanePump:createIsoThumpable(square, sprite)
  -- instance new IsoThumpableObject
  local thumpable = IsoThumpable.new(getCell(), square, sprite, false, self)

  -- name of the item for the tooltip
  buildUtil.setInfo(thumpable, self)

  -- turn off zombie damage/thumping
  thumpable:setIsThumpable(false)

  -- place object in square
  square:AddSpecialObject(thumpable)

  -- propane station specific ModData
  thumpable:getModData()["fuelAmount"] = self.fuel
  thumpable:getModData()["partSquare"] = self.partSquare
  thumpable:setSpecialTooltip(true)

  -- sent our object to the server
  thumpable:transmitCompleteItemToServer()

  -- make our addition trigger the OnObjectAdded event so other modders can detect it
  triggerEvent("OnObjectAdded", thumpable)
end
