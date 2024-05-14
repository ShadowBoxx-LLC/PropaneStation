CPropaneStationSystem = CGlobalObjectSystem:derive("CPropaneStationSystem")

function CPropaneStationSystem:new()
	local object = CGlobalObjectSystem.new(self, "propanestation")
	return object
end

function CPropaneStationSystem:isValidIsoObject(isoObject)
	return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == "PropanePump"
end

function CPropaneStationSystem:newLuaObject(isoObject)
	return CPropaneStationGlobalObject:new(self, isoObject)
end

function CPropaneStationSystem:isValidPart(arg)
	local square = getWorld():getCell():getGridSquare(arg[1], arg[2], arg[3])
	if square then
		return CPropaneStationSystem:getIsoObjectOnSquare(square)
	end
	return
end

CGlobalObjectSystem.RegisterSystemClass(CPropaneStationSystem)
