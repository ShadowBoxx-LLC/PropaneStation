-- here we have to decorate doFillFuelMenu and return nothing if we are a Propane Pump so we can't take petrol from it
local doFillFuelMenuBase = ISWorldObjectContextMenu.doFillFuelMenu
---@diagnostic disable-next-line: duplicate-set-field
ISWorldObjectContextMenu.doFillFuelMenu = function(isoObject, player, context)
  --if isoObject:getName() ~= "PropanePump" then
  if not CPropaneStationSystem.instance:isValidIsoObject(isoObject) then
    doFillFuelMenuBase(isoObject, player, context)
  end
end

local createMenuBase = ISWorldObjectContextMenu.createMenu
---@diagnostic disable-next-line: duplicate-set-field
ISWorldObjectContextMenu.createMenu = function(player, worldobjects, x, y, test)
  local context = createMenuBase(player, worldobjects, x, y, test)
  for _,worldobject in ipairs(worldobjects) do
    if CPropaneStationSystem.instance:isValidIsoObject(worldobject) and getCore():getDebug() then
---@diagnostic disable-next-line: undefined-global
      context:removeOptionByName(getText("ContextMenu_PumpFuelAmount") .. ": " .. tostring(haveFuel:getPipedFuelAmount()))
    end
  end
  return context
end

PropaneStation_Menu={}
PropaneStation_Menu.pumpInfo = function(player, context, worldobjects, test)
	if test and ISWorldObjectContextMenu.Test then return true end
	
	local PropanePump = nil
	
  for _,worldobject in ipairs(worldobjects) do
		if CPropaneStationSystem.instance:isValidIsoObject(worldobject) then
			PropanePump = worldobject
		end
	end

  if not PropanePump then
    return
  end
	
	if PropanePump:getPipedFuelAmount() > 0 and getCore():getDebug() then
---@diagnostic disable-next-line: undefined-global
		local pumpInfo = context:addOption(getText("ContextMenu_PropaneStationAmount") .. ": " .. tostring(haveFuel:getPipedFuelAmount()), worldobjects, nil)
    pumpInfo.iconTexture = getTexture("media/ui/BugIcon.png")
	end
end

Events.OnPreFillWorldObjectContextMenu.Add(PropaneStation_Menu.pumpInfo)

PropaneStation_Menu.doMenu = function(player, context, worldobjects, test)
	if test and ISWorldObjectContextMenu.Test then return true end
	local playerObj = getSpecificPlayer(player)
  local playerInv = playerObj:getInventory()
  local allContainers = {}
  local allContainerTypes = {}
  local allContainersOfType = {}
	local PropanePump
  local PropaneTankItem
---@diagnostic disable-next-line: param-type-mismatch
  local fillInto = playerInv:getAllEvalRecurse(function(item)
    if item:getType() == "PropaneTank" and not item:isBroken() and item:getUsedDelta() < 1 then
      return true
    end
    return false
  end)

  if fillInto:isEmpty() then
    return
  end
	
  for _,worldobject in ipairs(worldobjects) do
    if CPropaneStationSystem.instance:isValidIsoObject(worldobject) then
      PropanePump = worldobject
    end
  end

  if not PropanePump then
    return
  end

  if PropanePump:getModData()["fuelAmount"] <= 0 then
    if getCore():isInDebug() then
      playerObj:Say("No fuel")
    end
    return
  end

  if not (SandboxVars.AllowExteriorGenerator and PropanePump:getSquare():haveElectricity()) and (SandboxVars.ElecShutModifier == -1 or GameTime:getInstance():getNightsSurvived() > SandboxVars.ElecShutModifier) then
    if getCore():isInDebug() then
      playerObj:Say("No power")
    end
    return
  end

  local fillOption = context:addOption(getText("ContextMenu_RefillPropaneTank"), worldobjects, nil)
  if not PropanePump:getSquare() or not AdjacentFreeTileFinder.Find(PropanePump:getSquare(), playerObj) then
    fillOption.notAvailable = true;
    return;
  end

  --make a table of all containers
  for i=0, fillInto:size() - 1 do
    local container = fillInto:get(i)
    table.insert(allContainers, container)
  end
  table.sort(allContainers, function(a,b) return not string.sort(a:getName(), b:getName()) end)

  --add the fill menu
  local containerMenu = ISContextMenu:getNew(context)
  local containerOption
  context:addSubMenu(fillOption, containerMenu)
  if fillInto:size() > 1 then
    containerOption = containerMenu:addOption(getText("ContextMenu_FillAll"), allContainers, PropaneStation_Menu.onTakeFuel, playerObj, PropanePump)
  end
  --add each appropriate item to the fill menu
  for _,PropaneTankItem in ipairs(allContainers) do
    containerOption = containerMenu:addOption(PropaneTankItem:getName(), PropaneTankItem, PropaneStation_Menu.onTakeFuel, playerObj, PropanePump);
  end

  -- Debug output stuff
  if getCore():isInDebug() then
    PropaneStation_Menu.Debug(worldobjects, playerObj)
  end
end

Events.OnFillWorldObjectContextMenu.Add(PropaneStation_Menu.doMenu)

PropaneStation_Menu.onTakeFuel = function(PropaneTankItems, player, PropanePump)
  local playerInv = player:getInventory()
  local PropaneTankItem
  if not PropaneTankItems then
    return
  end
  if luautils.walkAdj(player, PropanePump:getSquare()) then
    if type(PropaneTankItems) == "table" then
      for _,PropaneTankItem in ipairs(PropaneTankItems) do
        local returnToContainer = PropaneTankItem:getContainer():isInCharacterInventory(player) and PropaneTankItem:getContainer()
        ISWorldObjectContextMenu.transferIfNeeded(player, PropaneTankItem)
        ISInventoryPaneContextMenu.equipWeapon(PropaneTankItem, false, false, player:getPlayerNum())
        ISTimedActionQueue.add(ISPropaneStationActions:new(player, PropanePump, PropaneTankItem, 400 - (PropaneTankItem:getUsedDelta() * 300)))
        if returnToContainer and (returnToContainer ~= playerInv) then
          ISTimedActionQueue.add(ISInventoryTransferAction:new(player, PropaneTankItem, playerInv, returnToContainer))
        end
      end
    else
      PropaneTankItem = PropaneTankItems
      local returnToContainer = PropaneTankItem:getContainer():isInCharacterInventory(player) and PropaneTankItem:getContainer()
      ISWorldObjectContextMenu.transferIfNeeded(player, PropaneTankItem)
      ISInventoryPaneContextMenu.equipWeapon(PropaneTankItem, false, false, player:getPlayerNum())
		  ISTimedActionQueue.add(ISPropaneStationActions:new(player, PropanePump, PropaneTankItem, 400 - (PropaneTankItem:getUsedDelta() * 300)))
      if returnToContainer and (returnToContainer ~= playerInv) then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(player, PropaneTankItem, playerInv, returnToContainer))
      end
    end
  end
end

PropaneStation_Menu.Debug = function(worldobjects, player)
	for _,worldobject in ipairs(worldobjects) do	
		if instanceof(worldobject, "IsoGenerator") then
			player:Say(getText(tostring(worldobject)))
		end
		if worldobject:getName() == "PropanePump" and worldobject:getModData()["fuelAmount"] > 0  then
			player:Say("FuelAmount: "..tostring(worldobject:getModData()["fuelAmount"]))
			player:Say("FuelAmount: "..tostring(worldobject:getSquare()))
			if worldobject:getModData()["partSquare"] then
				player:Say("FuelAmount: "..tostring(worldobject:getModData()["partSquare"]))
			end

			break
		end
	end
end
