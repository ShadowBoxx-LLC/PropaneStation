if isClient() then return end

require "BuildingObjects/ISPropanePump"

SPropaneStationGlobalObject = SGlobalObject:derive("SPropaneStationGlobalObject")

function SPropaneStationGlobalObject:new(luaSystem, globalObject)
  local object = SGlobalObject.new(self, luaSystem, globalObject)
  return object
end

function SPropaneStationGlobalObject:initNew()
  self.fuelAmount = 0
end

function SPropaneStationGlobalObject:stateFromIsoObject(isoObject)
  self.fuelAmount = isoObject:getModData().fuelAmount
  self.partSquare = isoObject:getModData().partSquare

  isoObject:transmitModData()
end

function SPropaneStationGlobalObject:stateToIsoObject(isoObject)
  if not self.fuelAmount then
    self.fuelAmount = 0
  end
  
  self:setModData()
end

function SPropaneStationGlobalObject:setModData()
  local isoObject = self:getIsoObject()
  if not isoObject then return end
  local previousfuelAmount = isoObject:getModData()["fuelAmount"];
  isoObject:getModData()["fuelAmount"] = self.fuelAmount;
  if previousfuelAmount ~= isoObject:getModData()["fuelAmount"] then
    isoObject:transmitModData();
  end
end

function SPropaneStationGlobalObject:setFuelAmount(fuelAmount)
  self.fuelAmount = fuelAmount
  local isoObject = self:getIsoObject()
  if not isoObject then return end
  isoObject:getModData()["fuelAmount"] = self.fuelAmount
  isoObject:transmitModData()
end
