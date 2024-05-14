ISPropaneStationActions = ISBaseTimedAction:derive("ISPropaneStationActions");

function ISPropaneStationActions:isValid()
	return true;
end

function ISPropaneStationActions:update()
	self.character:faceLocation(self.propaneStation:getSquare():getX(), self.propaneStation:getSquare():getY())
	
	self.tank:setJobDelta(self:getJobDelta())
	self.tank:setJobType(getText("ContextMenu_AddGas"))
	
	local litres = self.propaneStationStart + (self.propaneStationTarget - self.propaneStationStart)*self:getJobDelta()
	litres = math.ceil(litres)
	
	if litres ~= self.amountSent then
		local Obj = self.propaneStation;
		local args = { x = Obj:getX(), y = Obj:getY(), z = Obj:getZ(), fuelAmount = litres }
		CPropaneStationSystem.instance:sendCommand(self.character, 'fuelChange', args)
		self.amountSent = litres
	end
	
	local litresTaken = litres - self.propaneStationStart
	local usedDelta = self.tankStart - litresTaken*self.tank:getUseDelta()
	self.tank:setUsedDelta(usedDelta)
end

function ISPropaneStationActions:start()
	self.propaneStationStart = self.propaneStation:getModData()["fuelAmount"]
	self.tankStart = self.tank:getUsedDelta()
	
	local add = (1.0 - self.tankStart)/self.tank:getUseDelta();
	local take = math.min(add, self.propaneStationStart);
		
	self.propaneStationTarget = self.propaneStationStart - take;
	self.tankTarget = self.tankStart + take*self.tank:getUseDelta();
	
	self.amountSent = math.ceil(self.propaneStationStart);
	self.action:setTime(30 + take * 45)

  self:setOverrideHandModels(nil, self.tank:getStaticModel())
  self:setActionAnim("TakeGasFromPump")

  self.sound = self.character:playSound("CanisterAddFuelFromGasPump")
end

function ISPropaneStationActions:stop()
  self.character:stopOrTriggerSound(self.sound)
	self.tank:setJobDelta(0)
  ISBaseTimedAction.stop(self);
end

function ISPropaneStationActions:perform()
  self.character:stopOrTriggerSound(self.sound)
	self.tank:setJobDelta(0)
	self.tank:setUsedDelta(self.tankTarget)
	local Obj = self.propaneStation;
	local args = { x = Obj:getX(), y = Obj:getY(), z = Obj:getZ(), fuelAmount = self.propaneStationTarget }
	CPropaneStationSystem.instance:sendCommand(self.character, 'fuelChange', args)
  -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function ISPropaneStationActions:new(character, propaneStation, tank, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.propaneStation = propaneStation;
	o.tank = tank;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
	return o;
end
