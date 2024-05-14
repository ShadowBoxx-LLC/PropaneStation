if isClient() then return end

require "BuildingObjects/ISPropanePump"

SPropaneStationSystem = SGlobalObjectSystem:derive("SPropaneStationSystem")

function SPropaneStationSystem:new()
  local object = SGlobalObjectSystem.new(self, "propanestation")
  return object
end

function SPropaneStationSystem:initSystem()
  SGlobalObjectSystem.initSystem(self)

  -- Specify GlobalObjectSystem fields that should be saved.
  self.system:setModDataKeys({})
    
  -- Specify GlobalObject fields that should be saved.
  self.system:setObjectModDataKeys({'fuelAmount', 'partSquare'})

  self:convertOldModData()
end

function SPropaneStationSystem:newLuaObject(globalObject)
  return SPropaneStationGlobalObject:new(self, globalObject)
end

function SPropaneStationSystem:isValidIsoObject(isoObject)
  return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == "PropanePump"
end

function SPropaneStationSystem:convertOldModData()
end

local noise = function(msg)
  SPropaneStationSystem.instance:noise(msg)
end

local function getPropanePumpAt(x, y, z)
  return SPropaneStationSystem.instance:getLuaObjectAt(x, y, z)
end

function SPropaneStationSystem:OnClientCommand(command, player, args)
  local pump = getPropanePumpAt(args.x, args.y, args.z)
  if not pump then
    noise('no propane pump found at '..args.x..','..args.y..','..args.z)
    return
  end
  
  if command == "fuelChange" then    
    pump:setFuelAmount(args.fuelAmount)
    return
  end
end

SGlobalObjectSystem.RegisterSystemClass(SPropaneStationSystem)
