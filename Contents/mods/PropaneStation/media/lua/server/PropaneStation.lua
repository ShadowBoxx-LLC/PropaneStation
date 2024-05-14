if isClient() then return end

require "BuildingObjects/ISPropanePump"
require "BuildingObjects/ISPropaneTank"

local PropaneTank = ScriptManager.instance:getItem("Base.PropaneTank");
if PropaneTank then
  PropaneTank:DoParam("KeepOnDeplete = true")
  PropaneTank:DoParam("StaticModel = StaticPropaneTank")
end

local tilePrefix = "melos_tiles_random_props_industry_05_"

PropaneStation = {}

-- TileSets are groupings of tiles so we can pass a table to the function and easily loop over it for rendering our structure
PropaneStation.TileSets = {}

-- Tanks are large rendered containers near the Pumps. They are primarily just decorative.
PropaneStation.TileSets.Tanks = {} 

-- Tanks are split up into EastWest tanks, and SouthNorth tanks based on the direction the tank runs

-- ################################################################################################################ --
-- EastWest tanks run from East to West with the first tile being placed in the most North East square:
-- See below example, where A is the first tile placed (this would obviously be tilted more for isometric view in game):
-- HD
--  GC
--   FB
--    EA
-- ################################################################################################################ --
PropaneStation.TileSets.Tanks.EastWest = {}

-- ################################################################################################################ --
-- SouthNorth tanks run from South to North with the first tile being placed in the most South West square:
-- See below example, where A is the first tile placed (this would obviously be tilted more for isometric view in game):
--    DH
--   CG
--  BF
-- AE
-- ################################################################################################################ --
PropaneStation.TileSets.Tanks.SouthNorth = {}

-- Blue Tanks
PropaneStation.TileSets.Tanks.EastWest.Blue = {
  A = tilePrefix .. "11",
  B = tilePrefix .. "10",
  C = tilePrefix .. "9",
  D = tilePrefix .. "8",
  E = tilePrefix .. "15",
  F = tilePrefix .. "14",
  G = tilePrefix .. "13",
  H = tilePrefix .. "12"
}
PropaneStation.TileSets.Tanks.SouthNorth.Blue = {
  A = tilePrefix .. "0",
  B = tilePrefix .. "1",
  C = tilePrefix .. "2",
  D = tilePrefix .. "3",
  E = tilePrefix .. "4",
  F = tilePrefix .. "5",
  G = tilePrefix .. "6",
  H = tilePrefix .. "7"
}

-- Pumps are where the fuel in game is technically stored and where the player interacts to refuel their propane tank items
PropaneStation.TileSets.Pumps = {}

-- Pumps are split up into SouthFace pumps (which face South) and EastFace pumps (which face East)
PropaneStation.TileSets.Pumps.SouthFace = {}
PropaneStation.TileSets.Pumps.EastFace = {}

-- Blue Pumps
PropaneStation.TileSets.Pumps.SouthFace.Blue = tilePrefix .. "65"
PropaneStation.TileSets.Pumps.EastFace.Blue = tilePrefix .. "64"

-- ################################################################################################################ --
-- SpawnList provides details on where tanks and pumps will be placed on the map, each entry is it's own sub-table
-- The tank only needs it's first tile coordinates, it's directionality, and it's color defined. The pump needs it's
-- tile coordinates, it's facing, and it's color defined. The pump should be within a few spaces of the tank. We
-- label the table with a general description to start. As an example:
-- location_label = {
--   tank = {
--     coords = {x, y, z},
--     direction = "EastWest" or "SouthNorth",
--     color = "Blue" or "Red" or "Green" or "Dirty"
--   },
--   pump = {
--     coords = {x, y, z},
--     facing = "SouthFace" or "EastFace",
--     color = "Blue" or "Red" or "Green" or "Dirty"
--   }
-- }
PropaneStation.SpawnList =
{
  riverside_industrial = {
    tank = {
      coords = {5411, 5868, 0},
      direction = "EastWest",
      color = "Blue"
    },
    pump = {
      coords = {5413, 5865, 0},
      facing = "EastFace",
      color = "Blue"
    }
  }
}

--[[
PropaneStation.SpawnList = 
{
  --West Point
  {12066, 7157, IsNorth};
  {11818, 6879, IsNorth};
  
  --Valley Station
  {13717, 5677, IsNorth};
  {12725, 5064, IsNorth};
  
  --Rosewood
  {8326, 12255, IsNorth};
  {8129, 11252, IsNorth};
  
  --Riverside
  {5444, 5869, IsNorth};
  {6098, 5330};
  
  --Muldraugh
  {10637, 9751, IsNorth};
  {10623, 10628, IsNorth};
  
  --March Ridge
  {10159, 12815, IsNorth};
  
  --Dixie
  {11629, 8309, IsNorth};
  {11511, 8814};

  --Louisville
  {13617, 1545};
  {12101, 2112};
  {12699, 2253};
  {12253, 1641, IsNorth};
  {13544, 2145, IsNorth};

  --Doe Valley
  {5467, 9733};

  --Ekron
  {7311, 8195}
}
]]--

function PropaneStation.AddPropaneStation(square)
  if not square:getModData().AddPropaneStation then
    square:getModData().AddPropaneStation = true;
    
    for location, data in pairs(PropaneStation.SpawnList) do
      local tank_x = data.tank.coords[1]
      local tank_y = data.tank.coords[2]
      local tank_z = data.tank.coords[3]
      local pump_x = data.pump.coords[1]
      local pump_y = data.pump.coords[2]
      local pump_z = data.pump.coords[3]
      local tank_square = getCell():getGridSquare(tank_x, tank_y, tank_z)
      local pump_square = getCell():getGridSquare(pump_x, pump_y, pump_z)
      
      if pump_square == square then
        print("Propane Station: Spawning Propane Station at " .. location .. "location")
        local propanepump = ISPropanePump:new(PropaneStation.TileSets.Pumps[data.pump.facing][data.pump.color])
        propanepump:create(pump_x, pump_y, pump_z, PropaneStation.TileSets.Pumps[data.pump.facing][data.pump.color])
      end
    end
  end
end

Events.LoadGridsquare.Add(PropaneStation.AddPropaneStation);
