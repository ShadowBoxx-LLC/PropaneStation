CPropaneStationGlobalObject = CGlobalObject:derive("CPropaneStationGlobalObject")

function CPropaneStationGlobalObject:new(luaSystem, isoObject)
	local object = CGlobalObject.new(self, luaSystem, isoObject)
	return object
end

function CPropaneStationGlobalObject:getObject()
	return self:getIsoObject()
end
