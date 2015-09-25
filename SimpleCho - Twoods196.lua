--Simple Cho by Twoods196

myHero = GetMyHero()
if myHero.charName ~= "Chogath" then return end

--[[		Auto Update		]]
local version = "1.5"
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
				["Q"] = { speed = math.huge, delay = 0.625, range = 900, width = 300, collision = false, aoe = true, type = "circular"},
        ["W"] = { speed = math.huge, delay = 0.5, range = 650, width = 275, collision = false, aoe = false, type = "linear"}
	}
local minions
local qRange, wRange, eRange  = 950, 700, 500 
local ts
local SACLoaded, SxOrbLoaded, orbWalkLoaded = false
local passiveStacks = 0
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
UPL:AddSpell(_Q, { speed = math.huge, delay = 0.625, range = 900, width = 300, collision = false, aoe = true, type = "circular"})
UPL:AddSpell(_W, { speed = math.huge, delay = 0.5, range = 650, width = 275, collision = false, aoe = false, type = "linear"})
Menu()
ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, qRange, true)

end


function OnUpdateBuff(unit, buff, stacks)
if unit and unit.isMe and buff and (buff.name == "Feast") then
passiveStacks = stacks
end 
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
			SxOrb:EnableAttacks()
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
	  Config:addSubMenu("Combo Settings", "Combo")
    Config:addSubMenu("Draw Settings", "Draw")
		Config:addSubMenu("Stack Settings", "Stack")
		
		--> Basic Settings
Config.Combo:addParam("doCombo", "Q-W combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
Config.Combo:addParam("usew", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
Config.Combo:addParam("autoult", "Auto use Ult", SCRIPT_PARAM_ONOFF, true)

		
		Config.Stack:addParam("stack", "Auto Stack R on Minions", SCRIPT_PARAM_ONOFF, true)
		
	 
    Config:addParam("hc", "Accuracy (Default 2)", SCRIPT_PARAM_SLICE, 2, 0, 3, 1)
    UPL:AddToMenu(Config)





--> Draw Settings
Config.Draw:addParam("drawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
Config.Draw:addParam("drawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
--Config:addTS(ts)






print("<b><font color=\"#6699FF\">Simple Cho - Twoods196:</font></b> <font color=\"#FFFFFF\">Sucessfully loaded!</font>")
end

-- handles script logic, a pure high speed loop
function OnTick()

ts:update()
target = ts.target
Combo()
if Config.Stack.stack then
ultMin()
end
end

function ultMin()

if passiveStacks < 6 then
print(passiveStacks)
enemyMinions = minionManager(MINION_ENEMY, 600, player, MINION_SORT_HEALTH_ASC)
enemyMinions:update()
local player = GetMyHero()
local tick = 0
local delay = 0
local myTarget = ts.target
local Rrange = 275



for index, minion in pairs(enemyMinions.objects) do
if GetDistance(minion, myHero) <= Rrange and GetTickCount() > tick + delay then
local dmg = getDmg("R", minion, myHero)
if dmg > minion.health then
CastSpell(_R, minion)
tick = GetTickCount()
AttackMinion = true
else
AttackMinion = false
end
end
end
end
end


--handles overlay drawing (processing is not recommended here,use onTick() for that)

function OnDraw()
red = ARGB(150, 255,0,0)
    if (Config.Draw.drawQ) then
		if (myHero:CanUseSpell(_Q) == READY) then
        DrawCircle3D(myHero.x, myHero.y, myHero.z, 900, 4, red)
				end
				end
				
				if (Config.Draw.drawW) then
		if (myHero:CanUseSpell(_W) == READY) then
        DrawCircle3D(myHero.x, myHero.y, myHero.z, 650, 4, red)
				end
				end
 end
		
		
		
   




function Combo()


if (Config.Combo.doCombo) then

if (ts.target ~= nil) then
--Cast Spell

CastPosition, HitChance, HeroPosition = UPL:Predict(_Q, myHero, ts.target)
	if HitChance >= Config.hc then
	CastSpell(_Q, CastPosition.x, CastPosition.z)
	end
	if (Config.Combo.usew) then
  if (myHero:CanUseSpell(_W) == READY) then
	if GetDistanceSqr(target) <= Spells.W.range * Spells.W.range then
CastPosition, HitChance, HeroPosition = UPL:Predict(_W, myHero, ts.target)
CastSpell(_W, CastPosition.x, CastPosition.z)
end
end
end
if (Config.Combo.autoult) then
if (myHero:CanUseSpell(_R) == READY) then
local Rdmg = getDmg('R', target, myHero)
if (target.health < Rdmg) then
CastSpell(_R, target)
end
end
end
end
end
end




