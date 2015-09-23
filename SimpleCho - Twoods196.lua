--Simple Cho by Twoods196

myHero = GetMyHero()
if myHero.charName ~= "Chogath" then return end

--[[		Auto Update		]]
local version = "1.3"
local author = "Twoods196"
local SCRIPT_NAME = "SimpleCho"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/Twoods196/BOLSimpleCho/master/SimpleCho%20-%20Twoods196.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>SimpleCho:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST,"/Twoods196/BOLSimpleCho/master/SimpleCho.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available "..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end



--Intializing Variables
Spells = {
				["Q"] = { speed = math.huge, delay = 0.625, range = 950, width = 300, collision = false, aoe = true, type = "circular"},
        ["W"] = { speed = math.huge, delay = 0.5, range = 650, width = 275, collision = false, aoe = false, type = "linear"}
	}
local ts
local SACLoaded, SxOrbLoaded, orbWalkLoaded = false
if not _G.UPLloaded then
  if FileExist(LIB_PATH .. "/UPL.lua") then
    require("UPL")
    _G.UPL = UPL()
  else 
    print("Downloading UPL, please don't press F9")
    DelayAction(function() DownloadFile("https://raw.github.com/nebelwolfi/BoL/master/Common/UPL.lua".."?rand="..math.random(1,10000), LIB_PATH.."UPL.lua", function () print("Successfully downloaded UPL. Press F9 twice.") end) end, 3) 
    return
  end
end 




-- called once when the script is loaded
function OnLoad()
DelayAction(function() CheckOrbWalker() end, 10)
UPL:AddSpell(_Q, { speed = math.huge, delay = 0.625, range = 950, width = 300, collision = false, aoe = true, type = "circular"})
Menu()
ts = TargetSelector(TARGET_LOW_HP_PRIORITY,950)
end


function CheckOrbWalker() 
	if _G.Reborn_Initialised then
		SACLoaded = true
		_G.AutoCarry.Skills:DisableAll()
		print("SAC Detected.")
	elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		require("SxOrbWalk")
		SxOrbLoaded = true 
		Config:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
 	    SxOrb:LoadToMenu(Config.Orbwalking)
		--_G.SxOrb:LoadToMenu(Config.orbwalker)
	
	end

	if SACLoaded or SxOrbLoaded then
		orbWalkLoaded = true
	end

	if not orbWalkLoaded then 
		print("You need either SAC or SxOrbWalk for this script. Please download one of them.") 
	else
		print("Succesfully Loaded. Enjoy the script! Report bugs on the thread.")
	end
end



function Menu()
Config = scriptConfig("Simple Cho - Twoods196", "Settings")
	
	Config:addParam("drawCircle", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(" "))
    Config:addParam("hc", "Accuracy (Default 2)", SCRIPT_PARAM_SLICE, 2, 0, 3, 1)
    UPL:AddToMenu(Config)

print("<b><font color=\"#6699FF\">Simple Cho - Twoods196:</font></b> <font color=\"#FFFFFF\">Sucessfully loaded!</font>")
end

-- handles script logic, a pure high speed loop
function OnTick()

ts:update()
target = ts.target
Combo()
end




--handles overlay drawing (processing is not recommended here,use onTick() for that)

function OnDraw()
red = ARGB(150, 255,0,0)
    if (Config.drawCircle) then
		if (myHero:CanUseSpell(_Q) == READY) then
        DrawCircle3D(myHero.x, myHero.y, myHero.z, 950, 4, red)
				end
				end
 end
		
		
		
   




function Combo()


if (Config.combo) then

if (ts.target ~= nil) then
--Cast Spell

CastPosition, HitChance, HeroPosition = UPL:Predict(_Q, myHero, ts.target)
	if HitChance >= Config.hc then
	CastSpell(_Q, CastPosition.x, CastPosition.z)
	end
if (myHero:CanUseSpell(_W) == READY) then
CastPosition, HitChance, HeroPosition = UPL:Predict(_W, myHero, ts.target)
CastSpell(_W, CastPosition.x, CastPosition.z)
end
if (myHero:CanUseSpell(_R) == READY) then
local Rdmg = getDmg('R', target, myHero)
if (target.health < Rdmg) then
CastSpell(_R, target)
end
end
end
end
end




