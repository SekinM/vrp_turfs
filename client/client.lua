
vRPCturfs = {}
Tunnel.bindInterface("vRP_turfs",vRPCturfs)
Proxy.addInterface("vRP_turfs",vRPCturfs)
vRP = Proxy.getInterface("vrp")
vRPSturfs = Tunnel.getInterfata("vRP_turfs","vRP_turfs")

zone = nil

local fontId
fontId = RegisterFontId('Freedom Font')

local turfs = {}
local turfsBlip = {}
local flickering = {}
local turfsIcons = {}
local turfsData = {}
defaultAlpha = 0
local turfsData = {}
local weaponblacklist = {
	"weapon_sniperrifle",
	"weapon_heavysniper",
	"weapon_heavysniper_mk2",
	"weapon_marksmanrifle",
	"weapon_revolver",
	"weapon_marksmanrifle_mk2"
}

local CreateThread = Citizen.CreateThread

function vRPCturfs.spawnTheTurfs(id,x,y,z,blipColor,blipRadius,faction)
	if turfsBlip[id] then
		RemoveBlip(turfsBlip[id])
	end
	if turfsIcons[id] then
		RemoveBlip(turfsIcons[id])
	end
	turfsIcons[id] = AddBlipForCoord(x, y, z)
	SetBlipSprite(turfsIcons[id], 0)
	SetBlipColour(turfsIcons[id], 1)
	SetBlipAlpha(turfsIcons[id], 255)

	SetBlipAsShortRange(turfsIcons[id], true)
	turfsBlip[id] = AddBlipForRadius(x, y, z, blipRadius + 0.0)
	SetBlipColour(turfsBlip[id], blipColor)
	SetBlipAlpha(turfsBlip[id], defaultAlpha)


	turfsData[id] = {
		id,
		x,
		y,
		z,
		blipRadius,
		blipColor,
		faction
	}

end

local warStarted = {}

vRPCturfs.setWarStarted = function(turfID)
	warStarted[turfID] = true
	ExecuteCommand("borders")
end

vRPCturfs.stopStartedWar = function(turfID)
	warStarted[turfID] = false
end

local function RGBRainbow( frequency )
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = math.floor( math.sin( curtime * frequency + 0 ) * 127 + 128 )
	result.g = math.floor( math.sin( curtime * frequency + 2 ) * 127 + 128 )
	result.b = math.floor( math.sin( curtime * frequency + 4 ) * 127 + 128 )
	
	return result
end

local inWar = false
local enemyScore = 0
local allyScore = 0

local enemyName = ""
local allyName = ""

function vRPCturfs.updateScore(eS,aS,eN,aN)
	enemyScore = eS
	allyScore = aS

	enemyName = eN
	allyName = aN
end

function vRPCturfs.showTheTurfs()
	if defaultAlpha == 0 then
		defaultAlpha = 150
		vRP.notify({"~g~Ai afisat turfurile!"})
	else
		defaultAlpha = 0
		vRP.notify({"~r~Ai ascuns turfurile"})
	end
	for key, value in pairs(turfsBlip) do
		SetBlipAlpha(turfsBlip[key], defaultAlpha)
	end
end

local borders = false
function vRPCturfs.showBorders()
    if not borders then
        vRP.notify({"~g~Ai afisat delimitarile"})
    elseif borders then
        vRP.notify({'~r~Ai ascuns delimitarile'})
    end
    borders = not borders
    while borders do
        local coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(turfsData) do
            if #(vector3(coords) - vector3(v[2],v[3],v[4])) < v[5] then

                local scale = (v[5] + 0.0) * 2
                DrawMarker(1,v[2],v[3],v[4] - v[5],0,0,0,0,0,0,scale,scale,(100 + 0.0) + v[5] * 2,255,0,0,220,0,0,2,0)
            end
        end 	
        Wait(1)
    end
end

function vRPCturfs.setColor(id, color)
	if turfsBlip[id] then
		SetBlipColour(turfsBlip[id], color)
	end
end

vRPCturfs.stopFlick = function(id)
	flickering[id] = false
end
vRPCturfs.flickTurf = function(id, time)
	if id then
		flickering[id] = true

		while time >= 0 or flickering[id] do
			Citizen.Wait(1000)
			vRPCturfs.setColor(id, tonumber(0))
			Citizen.Wait(1000)
			vRPCturfs.setColor(id, tonumber(15))
			time = time - 2
		end
		vRPCturfs.setColor(id, (turfsData[id].blipColor))
	end
end


function vRPCturfs.endTurfWar(turfID)
	enemyScore = 0
	allyScore = 0
	enemyName = ""
	allyName = ""
	minute = 0
	secunde = 0
	inWar = nil
	warStarted[turfID] = false
	ExecuteCommand("turfs")
    ExecuteCommand("borders")
	Wait(2000)
	vRPCturfs.setColor(turfID, turfsData[turfID][12])
end

--function vRPCturfs.endTurfWar(turfID)
--	enemyScore = 0
--	allyScore = 0
--	enemyName = ""
--	allyName = ""
--	minute = 0
--	secunde = 0
--	inWar = nil
--	warStarted[turfID] = false
--	vRPCturfs.flickTurf(turfID)
--	ExecuteCommand("turfs")
--    ExecuteCommand("borders")
--	Wait(2000)
--	vRPCturfs.setColor(turfID, turfsData[turfID].blipColor)
--end

CreateThread(function()
	while true do
		for k,v in pairs(turfsData)do	
			while Vdist(GetEntityCoords(GetPlayerPed(-1)),v[2],v[3],v[4]) < v[5] and defaultAlpha ~= 0 do
				drawText(0.5,0.05,0.0,0.0,0.27, "TURF: ~y~"..v[7].." ~w~[~y~#"..v[1].."~w~]", 255,255,255,255,4)
				Wait(0)
			end
		end
		Wait(500)
	end
end)
function vRPCturfs.isPlayerInTurf(oneTurf)
	local x, y, z = vRP.getPosition({})
	if oneTurf and oneTurf ~= 0 then
		local theTurf = turfsData[oneTurf]
		if theTurf then
			if GetDistanceBetweenCoords(x, y, z, theTurf[2], theTurf[3], theTurf[4], false) < theTurf[5] then
				return true
			end
		end
	else
		for i, v in pairs(turfsData) do 
			if Vdist(GetEntityCoords(GetPlayerPed(-1)), v[2], v[3], v[4]) < v[5] then
				return i
			end
		end
	end
	return false
end

VirtualDistance = function(x,y,z,x1,y1,z1)
	local theDistance = #(vector3(x,y,z) - vector3(x1,y1,z1))
	return theDistance
end
function drawText(x,y ,width,height,scale, text, r,g,b,a,font)
	SetTextFont(6)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextCentre(1)
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x - width/2, y - height/2 + 0.005)
end
local showing = false

local minute = 0
local secunde = 0
function vRPCturfs.updateTime(min,sec)
	minute = tonumber(min)
	secunde = tonumber(sec)
end



local function getNonZDistance(vector1,vector2)
	return #(vector3(vector1.x,vector1.y,0.0)-vector3(vector2.x,vector2.y,0.0))
end

function vRPCturfs.notifyPicture(icon, type, sender, title, text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	SetNotificationMessage(icon, icon, true, type, sender, title, text)
	DrawNotification(false, true)
end

function vRPCturfs.setInTheTurf(theTurf)
	inWar = theTurf
	Citizen.CreateThread(function()
		while ( inWar ) do
			Wait(1000)
			if ( GetEntityHealth(PlayerPedId()) <= 105 ) then
				TriggerServerEvent("turfs:playerDied")
				Wait(10000)
				print('Ai murit!')
			end
		end 
	end)
	CreateThread(function()
		while inWar do
			Wait(1)
			local ped = GetPlayerPed(PlayerId())
			nothing, weapon = GetCurrentPedWeapon(ped, true)
			--if inWar then
				if secunde < 10 then
					secStr = "0"..secunde
				else
					secStr = secunde
				end
				if minute == 0 then
					minStr = "00"
				elseif minute < 10 then
					minStr = "0"..minute
				else
					minStr = minute
				end
				drawText(0.5,0.10 ,0.0,0.0,0.35, "TIMP TURF", 255,0,0,255,7)
				drawText(0.5,0.13 ,0.0,0.0,0.35, minStr..":"..secStr, 255,255,255,255,4)
				
				drawText(0.4,0.06 ,0.0,0.0,0.40, "~g~"..allyName, 255,255,255,255,1)
				drawText(0.4,0.04 ,0.0,0.0,0.30, "~w~"..tostring(allyScore), 255,255,255,255,4)

				drawText(0.6,0.06 ,0.0,0.0,0.40, "~r~"..enemyName, 255,255,255,255,1)
				drawText(0.6,0.04 ,0.0,0.0,0.30, "~w~"..tostring(enemyScore), 255,255,255,255,4)
				if isWeaponRestricted(weapon) then
					SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), false)
					vRP.notify({"~r~Aceasta arma este interzisa in timpul unui war!"})
				end
			--else 
			--	return
			--end
		end
	end)

end

function vRPCturfs.saTiIauMortiiInPulaDeScript() -- Sa ma pis pe tine de bug de cresti scoru' luami-ai pula in gura daca nu te-am rezolvat.
	return inWar
end

function isWeaponRestricted(weapon)
	for _, blacklistedWeapon in pairs(weaponblacklist) do
		if weapon == GetHashKey(blacklistedWeapon) then
			return true
		end
	end

	return false
end

CreateThread(function()
	while true do
		tick = 500
		ped = PlayerPedId()
		plyCoords = GetEntityCoords(ped)
		for k,v in pairs(turfsData)do
			if #(vector3(v[2], v[3], v[4]) - vector3(plyCoords.x,plyCoords.y,plyCoords.z)) > v[5] then
				local aiming = false
				local entity
				if IsPlayerFreeAiming(PlayerId()) then
					tick = 0
					aiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
					if (aiming) then
						if IsEntityAPed(entity) then
							if IsPedAPlayer(entity) and warStarted[k] then
								local coords = GetEntityCoords(entity)
								if Vdist(coords.x,coords.y,coords.z,v[2], v[3], v[4]) <= v[5] then
									SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), false)
								end
							end
						end
					end
				end
			end
		end
		Wait(tick)
	end
end)

RegisterCommand("GetHealth",function(...)
	thePed = PlayerPedId()
	print(GetEntityHealth(thePed))
end)
vRPCturfs.isInWarAndInComa = function()
	local plyPed = PlayerPedId()
	local plyHealth = GetEntityHealth(plyPed)
	print(plyHealth,"inWar = "..inWar)
	if inWar and plyHealth <= 105 then
		return true
	end
	return false
end


vRPCturfs.revivePlayer = function() -- Revive sa nu se mai buguiasca autistu'
	local ped = GetPlayerPed(-1)
	if IsEntityDead(ped) then
		local x,y,z = GetEntityCoords(ped)
		NetworkResurrectLocalPlayer(x, y, z, GetEntityHeading(GetPlayerPed(-1)),true, true, false)
		Citizen.Wait(0)
	end
	local player = PlayerId()
	SetPlayerControl(player, true, false)

	if not IsEntityVisible(ped) then
		SetEntityVisible(ped, true)
	end

	if not IsPedInAnyVehicle(ped) then
		SetEntityCollision(ped, true)
	end

	FreezeEntityPosition(ped, false)
	SetPlayerInvincible(player, false)
	SetEntityHealth(ped,200)
	
	local ped = GetPlayerPed(-1)
	SetEntityInvincible(ped,false)
	ClearPedSecondaryTask(GetPlayerPed(-1))
	Citizen.CreateThread(function()
		Wait(500)
		ClearPedSecondaryTask(GetPlayerPed(-1))
		ClearPedTasks(GetPlayerPed(-1))
	end)    
end


local config = {
	prox_enabled = false,				-- Proximity Enabled
	prox_range = 100,					-- Distance
}

-- Weapons Table
local weapons = {
	[-1569615261] = 'weapon_unarmed',
	[-1716189206] = 'weapon_knife',
	[1737195953] = 'weapon_nightstick',
	[1317494643] = 'weapon_hammer',
	[-1786099057] = 'weapon_bat',
	[-2067956739] = 'weapon_crowbar',
	[1141786504] = 'weapon_golfclub',
	[-102323637] = 'weapon_bottle',
	[-1834847097] = 'weapon_dagger',
	[-102973651] = 'weapon_hatchet',
	[940833800] = 'weapon_stone_hatchet',
	[-656458692] = 'weapon_knuckle',
	[-581044007] = 'weapon_machete',
	[-1951375401] = 'weapon_flashlight',
	[-538741184] = 'weapon_switchblade',
	[-1810795771] = 'weapon_poolcue',
	[419712736] = 'weapon_wrench',
	[-853065399] = 'weapon_battleaxe',
	[453432689] = 'weapon_pistol',
	[-1075685676] = 'weapon_pistol_mk2',
	[1593441988] = 'weapon_combatpistol',
	[-1716589765] = 'weapon_pistol50',
	[-1076751822] = 'weapon_snspistol',
	[-2009644972] = 'weapon_snspistol_mk2',
	[-771403250] = 'weapon_heavypistol',
	[137902532] = 'weapon_vintagepistol',
	[-598887786] = 'weapon_marksmanpistol',
	[-1045183535] = 'weapon_revolver',
	[-879347409] = 'weapon_revolver_mk2',
	[-1746263880] = 'weapon_doubleaction',
	[584646201] = 'weapon_appistol',
	[911657153] = 'weapon_stungun',
	[1198879012] = 'weapon_flaregun',
	[324215364] = 'weapon_microsmg',
	[-619010992] = 'weapon_machinepistol',
	[736523883] = 'weapon_smg',
	[2024373456] = 'weapon_smg_mk2',
	[-270015777] = 'weapon_assaultsmg',
	[171789620] = 'weapon_combatpdw',
	[-1660422300] = 'weapon_mg',
	[2144741730] = 'weapon_combatmg',
	[-608341376] = 'weapon_combatmg_mk2',
	[1627465347] = 'weapon_gusenberg',
	[-1121678507] = 'weapon_minismg',
	[-1074790547] = 'weapon_assaultrifle',
	[961495388] = 'weapon_assaultrifle_mk2',
	[-2084633992] = 'weapon_carbinerifle',
	[-86904375] = 'weapon_carbinerifle_mk2',
	[-1357824103] = 'weapon_advancedrifle',
	[-1063057011] = 'weapon_specialcarbine',
	[-1768145561] = 'weapon_specialcarbine_mk2',
	[2132975508] = 'weapon_bullpuprifle',
	[-2066285827] = 'weapon_bullpuprifle_mk2',
	[1649403952] = 'weapon_compactrifle',
	[100416529] = 'weapon_sniperrifle',
	[205991906] = 'weapon_heavysniper',
	[177293209] = 'weapon_heavysniper_mk2',
	[-952879014] = 'weapon_marksmanrifle',
	[1785463520] = 'weapon_marksmanrifle_mk2',
	[487013001] = 'weapon_pumpshotgun',
	[1432025498] = 'weapon_pumpshotgun_mk2',
	[2017895192] = 'weapon_sawnoffshotgun',
	[-1654528753] = 'weapon_bullpupshotgun',
	[-494615257] = 'weapon_assaultshotgun',
	[-1466123874] = 'weapon_musket',
	[984333226] = 'weapon_heavyshotgun',
	[-275439685] = 'weapon_dbshotgun',
	[317205821] = 'weapon_autoshotgun',
	[-1568386805] = 'weapon_grenadelauncher',
	[-1312131151] = 'weapon_rpg',
	[1119849093] = 'weapon_minigun',
	[2138347493] = 'weapon_firework',
	[1834241177] = 'weapon_railgun',
	[1672152130] = 'weapon_hominglauncher',
	[1305664598] = 'weapon_grenadelauncher_smoke',
	[125959754] = 'weapon_compactlauncher',
	[-1813897027] = 'weapon_grenade',
	[741814745] = 'weapon_stickybomb',
	[-1420407917] = 'weapon_proxmine',
	[-1600701090] = 'weapon_bzgas',
	[615608432] = 'weapon_molotov',
	[101631238] = 'weapon_fireextinguisher',
	[883325847] = 'weapon_petrolcan',
	[-544306709] = 'weapon_petrolcan',
	[1233104067] = 'weapon_flare',
	[600439132] = 'weapon_ball',
	[126349499] = 'weapon_snowball',
	[-37975472] = 'weapon_smokegrenade',
	[-1169823560] = 'weapon_pipebomb',
	[-72657034] = 'weapon_parachute',
	[-1238556825] = 'weapon_rayminigun',
	[-1355376991] = 'weapon_raypistol',
	[1198256469] = 'weapon_raycarbine',
}

local isDead = false
Citizen.CreateThread(function()
	while true do
		local killed = GetPlayerPed(PlayerId())
		local killedCoords = GetEntityCoords(killed)
		if IsEntityDead(killed) and not isDead then
			local killer = GetPedKiller(killed)
			if killer ~= 0 then
				if killer == killed then
					TriggerServerEvent('KillFeed:Died', killedCoords)
				else
					local KillerNetwork = NetworkGetPlayerIndexFromPed(killer)
					if KillerNetwork == "**Invalid**" or KillerNetwork == -1 then
						TriggerServerEvent('KillFeed:Died', killedCoords)
					else
						TriggerServerEvent('KillFeed:Killed', GetPlayerServerId(KillerNetwork), hashToWeapon(GetPedCauseOfDeath(killed)), killedCoords,enemyName)
					end
				end
			else
				TriggerServerEvent('KillFeed:Died', killedCoords)
			end
			isDead = true
		end
		if not IsEntityDead(killed) then
			isDead = false
		end
		Citizen.Wait(50)
	end
end)

RegisterNetEvent('KillFeed:AnnounceKill')
AddEventHandler('KillFeed:AnnounceKill', function(killed, killer, weapon, coords, enemy1)
	if (enemy1 == enemyName or enemy1 == allyName) and inWar then
			local myLocation = GetEntityCoords(GetPlayerPed(PlayerId()))
			if #(myLocation - coords) < config.prox_range then
				SendNUIMessage({
					type = 'newKill',
					killer = killer,
					killed = killed,
					weapon = weapon,
				})
			end
		end
end)

RegisterNetEvent('KillFeed:AnnounceDeath')
AddEventHandler('KillFeed:AnnounceDeath', function(killed, coords)
	if coords ~= nil and config.prox_enabled then
		local myLocation = GetEntityCoords(GetPlayerPed(PlayerId()))
		if #(myLocation - coords) < config.prox_range then
			SendNUIMessage({
				type = 'newDeath',
				killed = killed,
			})
		end
	else
		SendNUIMessage({
			type = 'newDeath',
			killed = killed,
		})
	end
end)

function hashToWeapon(hash)
	if weapons[hash] ~= nil then
		return weapons[hash]
	else
		return 'weapon_unarmed'
	end
end
