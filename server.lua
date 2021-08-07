local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vrp","vRP_turfs")

vRPCturfs = Tunnel.getInterface("vRP_turfs","vRP_turfs")

vRPSturfs = {}
Tunnel.bindInterface("vRP_turfs",vRPSturfs)
Proxy.addInterface("vRP_turfs",vRPSturfs)

cemortitaivrei = false


local virtualworlds = {}

RegisterServerEvent('SetEntityVirtualWorld')
AddEventHandler('SetEntityVirtualWorld', function(entity, worldid)
    if (worldid < 0) or (worldid > 2147483647)  then
        Citizen.Trace("Attempt to place entity "..entity.." in out of bounds virtual world ("..worldid..")!\n")
        return
    end
    
    for k,v in pairs(virtualworlds) do
        if virtualworlds[worldid] ~= nil then
            for g,w in pairs(virtualworlds[k]) do
                if w.entity == entity then
                    table.remove(virtualworlds[k], g)
                end
            end
        end
    end
    
    if virtualworlds[worldid] ~= nil then
        table.insert(virtualworlds[worldid], {['entity'] = entity})
    else
        virtualworlds[worldid] = {} 
        table.insert(virtualworlds[worldid], {['entity'] = entity})
    end

    TriggerClientEvent('SetEntityVirtualWorld', -1, virtualworlds, entity, worldid)
end)





theTurfs = {}
turfCD = {}
local myusers = nil
turfs = {}
turfCount = {}
alreadyExecuted = {}
function vRPSturfs.spawnTurfs()
	turfs = {}
	exports.ghmattimysql:execute("SELECT * FROM vrp_turfs",{},function(rows)
		if #rows > 0 then
			for k,v in pairs(rows)do
				id = v.id
				x = v.x
				y = v.y
				z = v.z
				faction = v.faction
				blipColor = "1"
				blipRadius = v.blipRadius
				attackedBy = nil
				turfs[id] = {x=x,y=y,z=z,blipRadius=blipRadius,blipColor=blipColor,faction=faction,inattack=false}
				table.insert(theTurfs,{id=id,x=x,y=y,z=z,blipColor=blipColor,blipRadius=blipRadius,faction=faction,attackedBy=attackedBy})
			end
			for i,v in ipairs(rows)do
				if(turfCount[v.faction] == nil)then
					turfCount[v.faction] = 0
				end
				turfCount[v.faction] = turfCount[v.faction] + 1
			end
		end
	end)
	vRPSturfs.spawnTurfsC(-1)
end
function vRPSturfs.spawnTurfsC(thePlayer)
	exports.ghmattimysql:execute("SELECT * FROM vrp_turfs",{},function(rows)
		for k,v in pairs(rows)do
			id = v.id
			x = v.x
			y = v.y
			z = v.z
			faction = v.faction
			blipColor = "1"
			blipRadius = v.blipRadius
			attackedBy = nil
			vRPCturfs.spawnTheTurfs(thePlayer,{id,x,y,z,blipColor,blipRadius,faction})
		end
	end)
end
-- RegisterCommand("turfs",function(source)
-- 	local thePlayer = source
-- 	Wait(500)
-- 	vRPCturfs.showTheTurfs(thePlayer,{})
-- 	--vRPCturfs.setInTheTurf(thePlayer,{1})
-- 	--vRPCturfs.drawTimer(thePlayer,{29,59,1})
-- 	--vRPCturfs.updateScore(thePlayer,{1,1,"HellsAngels","Mafia Narcos"})
-- end)

RegisterCommand(
    "turfs",
    function(source)
        local thePlayer = source

        vRPCturfs.showTheTurfs(thePlayer, {})
    end
)
RegisterCommand(
    'borders',
    function(source)
        local thePlayer = source
        vRPCturfs.showBorders(thePlayer,{})
    end
)

local minute = {}
local secunde = {}
startTimer = function(min,sec,turfID)
	minute[turfID] = min
	secunde[turfID] = sec
	CreateThread(function()
		while true do
			Wait(1000)
			if minute[turfID] < 0 or secunde[turfID] < 0 then
				endTurf(turfID)
				break
			end
			secunde[turfID] = secunde[turfID] - 1
			if secunde[turfID] <= 0 then
				secunde[turfID] = 59
				minute[turfID] = minute[turfID] - 1
			end
			--print(minute[turfID],secunde[turfID])vRP.getOnlineUsersByFaction(group)
			infaction = vRP.getOnlineUsersByFaction({turfWars[turfID].enemyFaction})
			for k,v in pairs(infaction)do
				--theF = vRP.isUserInFaction({k,turfWars[turfID].allyFaction}) or vRP.isUserInFaction({k,turfWars[turfID].enemyFaction})
				sugipl = vRP.getUserSource({v})
					--print(minute[turfID],secunde[turfID])
					vRPCturfs.updateTime(sugipl,{minute[turfID],secunde[turfID]})
					
			
			end
			infaction1 = vRP.getOnlineUsersByFaction({turfWars[turfID].allyFaction})
			for k,v in pairs(infaction1)do
				--theF = vRP.isUserInFaction({k,turfWars[turfID].allyFaction}) or vRP.isUserInFaction({k,turfWars[turfID].enemyFaction})
				sugipl = vRP.getUserSource({v})
			
					--print(minute[turfID],secunde[turfID])
					vRPCturfs.updateTime(sugipl,{minute[turfID],secunde[turfID]})
			
			end
			if cemortitaivrei then
				vRPCturfs.setturfColor(-1,{turfID,vRP.getFactionBlip({turfWars[turfID].allyFaction})})
			else 
				vRPCturfs.setturfColor(-1,{turfID,vRP.getFactionBlip({turfWars[turfID].enemyFaction})})
			end

		end
	end)
end

RegisterCommand("setvw",function(source,args)
	TriggerEvent("SetEntityVirtualWorld",source, tonumber(args[1]))
	--SetPlayerRoutingBucket(source,tonumber(args[1]))
end)
RegisterCommand("setidvw",function(source,args)
	local theTarget = vRP.getUserSource({args[1]})
	TriggerEvent("SetEntityVirtualWorld",theTarget, tonumber(args[2]))
	--SetPlayerRoutingBucket(theTarget,tonumber(args[2]))
end)
function tprint (tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
	  formatting = string.rep("  ", indent) .. k .. ": "
	  if type(v) == "table" then
		print(formatting)
		tprint(v, indent+1)
	  else
		print(formatting .. v)
	  end
	end
  end
cancelAttack = function(turfID)
	local users = myusers
		for k,v in pairs(users)do
			if vRP.isUserInFaction({k,turfWars[turfID].allyFaction}) then
				--print(k)
					--print(minute[turfID],secunde[turfID])
				vRPCturfs.endTurfWar(v,{turfID})
				vRPCturfs.setInTheTurf(v,{false})
				TriggerEvent("SetEntityVirtualWorld",v, 0)
				--SetPlayerRoutingBucket(v,0)
			elseif vRP.isUserInFaction({k,turfWars[turfID].enemyFaction}) then
				vRPCturfs.endTurfWar(v,{turfID})
				vRPCturfs.setInTheTurf(v,{false})
				TriggerEvent("SetEntityVirtualWorld",v, 0)
				--SetPlayerRoutingBucket(v,0)
			end
		end
		lastAttacked[turfWars[turfID].enemyFaction] = os.time()
		inWar[turfWars[turfID].allyFaction] = false
		inWar[turfWars[turfID].enemyFaction] = false
		minute[turfID] = {}
		secunde[turfID] = {}
		turfWars[turfID] = {}
		vRPSturfs.spawnTurfs()
		vRPCturfs.stopStartedWar(-1,{turfID})
		Wait(500)
		vRPSturfs.spawnTurfs()
end
endTurf = function(turfID)
	local users = myusers
	Wait(500)
	if turfWars[turfID].allyScore > turfWars[turfID].enemyScore then
		TriggerClientEvent('chatMessage',-1,"^1[Turfs]^0 Razboiul dintre factiunea ^1"..turfWars[turfID].allyFaction.."^0 si factiunea ^1"..turfWars[turfID].enemyFaction.."^0 a fost castigat de catre ^1"..turfWars[turfID].allyFaction.."!")
		TriggerClientEvent("chatMessage",-1,"	^0Scor: ^1"..turfWars[turfID].allyScore.." ^0(^1"..turfWars[turfID].allyFaction.."^0) - ^1"..turfWars[turfID].enemyScore.." ^0(^1"..turfWars[turfID].enemyFaction.."^0)")

	elseif turfWars[turfID].allyScore < turfWars[turfID].enemyScore then
		TriggerClientEvent('chatMessage',-1,"^1[Turfs]^0 Razboiul dintre factiunea ^1"..turfWars[turfID].allyFaction.."^0 si factiunea ^1"..turfWars[turfID].enemyFaction.."^0 a fost castigat de catre ^1"..turfWars[turfID].enemyFaction.."!")
		TriggerClientEvent("chatMessage",-1,"	^0Scor: ^1"..turfWars[turfID].enemyScore.." ^0(^1"..turfWars[turfID].enemyFaction.."^0) - ^1"..turfWars[turfID].allyScore.." ^0(^1"..turfWars[turfID].allyFaction.."^0)")
		exports.ghmattimysql:execute("UPDATE vrp_turfs SET faction=@faction,blipColor=@fColor WHERE id = @turfId",{['turfId'] = turfID,['faction'] = turfWars[turfID].enemyFaction,['fColor'] = vRP.getFactionBlip({turfWars[turfID].enemyFaction}) })

	elseif turfWars[turfID].allyScore == turfWars[turfID].enemyScore then
		TriggerClientEvent('chatMessage',-1,"^1[Turfs]^0 Factiunea ^1"..turfWars[turfID].allyFaction.."^0 a facut fata in razboi factiunii ^1"..turfWars[turfID].enemyFaction.."!")
		TriggerClientEvent("chatMessage",-1,"	^0Scor: ^1"..turfWars[turfID].allyScore.." ^0(^1"..turfWars[turfID].allyFaction.."^0) - ^1"..turfWars[turfID].enemyScore.." ^0(^1"..turfWars[turfID].enemyFaction.."^0)")
	end
	for k,v in pairs(users)do
		if vRP.isUserInFaction({k,turfWars[turfID].allyFaction}) then
			--print(k)
			--print(minute[turfID],secunde[turfID])
			vRPCturfs.endTurfWar(v,{turfID})
			vRPCturfs.setInTheTurf(v,{false})
			TriggerEvent("SetEntityVirtualWorld",v, 0)
			vRPCturfs.stopFlick(v,{turfID})
			--SetPlayerRoutingBucket(v,0)
		elseif vRP.isUserInFaction({k,turfWars[turfID].enemyFaction}) then
			vRPCturfs.endTurfWar(v,{turfID})
			vRPCturfs.setInTheTurf(v,{false})
			TriggerEvent("SetEntityVirtualWorld",v, 0)
			vRPCturfs.stopFlick(v,{turfID})
			--SetPlayerRoutingBucket(v,0)
		end

	end
	turfs[turfID].inattack = false
	lastAttacked[turfWars[turfID].enemyFaction] = os.time()
	inWar[turfWars[turfID].allyFaction] = false
	inWar[turfWars[turfID].enemyFaction] = false
	minute[turfID] = {}
	secunde[turfID] = {}
	turfWars[turfID] = {}
	vRPCturfs.stopStartedWar(-1,{turfID})
	Wait(199)
	vRPSturfs.spawnTurfs()
end

inWar = {}
turfWars = {}
gucii = true
lastAttacked = {}
RegisterCommand("attack",function(source)
	local thePlayer = source
	local user_id = vRP.getUserId({source})
	local hasFaction = vRP.hasUserFaction({user_id})
	ora = parseInt(os.date("%H"))
	if ora >= 0 and ora < 24 then
		if hasFaction then
			local faction = vRP.getUserFaction({user_id})
			local fType = vRP.getFactionType({faction})
			if fType == "Mafie" then
				vRPCturfs.isPlayerInTurf(thePlayer,{0},function(inTurf)
					--print(inTurf)
					if inTurf then
						turfID = inTurf
						if (os.time() - lastAttacked[faction]) < 150 then 
							TriggerClientEvent("chatMessage",thePlayer,"^1[TURFS] ^0Asteapta ^3"..(150 - (os.time() - lastAttacked[faction])).." secunde^0 pana sa ataci alt teritoriu!")
							return
						else
							if turfs[turfID].faction == faction then
								vRPclient.notify(thePlayer,{"~r~Nu poti sa-ti ataci propriul turf!"})
							else
								allyF = vRP.getOnlineUsersByFaction({faction})
								enemyF = vRP.getOnlineUsersByFaction({turfs[turfID].faction})
								if turfs[turfID].faction == "Neocupat" then
									isFactionLeader = vRP.isFactionLeader({user_id,faction})
									if isFactionLeader then
										exports.ghmattimysql:execute("UPDATE vrp_turfs SET faction=@faction,blipColor=@color WHERE id = @turfId",{turfId = turfID,faction = faction,color=1})
										Wait(500)
										vRPSturfs.spawnTurfs()
										vRPclient.notify(thePlayer,{"~g~Ai cucerit acest turf deoarece nu era ocupat!"})
									else
										vRPclient.notify(thePlayer,{"~r~Nu esti liderul factiunii ~y~"..faction})
									end
								else
									if #allyF >= 0 then
										if #enemyF >= 0 then
											--if (os.time() - turfCD[faction]) < 1200 and turfCD[faction] ~= 0 then
											--	TriggerClientEvent('chatMessage', thePlayer, "[Turfs] Factiunea ta a atacat recent un turf! Te rugam mai asteapta: ^2" .. (2400 - (os.time() - turfCD[turfID])) .. "^0 secunde.")
											--	return
											--else
												isFactionLeader = vRP.isFactionLeader({user_id,faction})
												if isFactionLeader then
													
													if not inWar[faction] then
														if not inWar[turfs[turfID].faction] then
															if turfs[turfID].inattack == false then
																--turfCD[faction] = os.time()
																inWar[turfs[turfID].faction] = true
																inWar[faction] = true
																turfWars[turfID] = {allyScore=0,enemyScore=0,allyFaction = turfs[turfID].faction,enemyFaction = faction}
																vRPCturfs.setWarStarted(-1,{turfID})
																print(json.encode(turfWars[turfID]))
																startTimer(14,59,turfID)
																local users = myusers
																turfs[turfID].inattack = true
																Wait(550)
																
																for k,v in pairs(vRP.getUsers({})) do
																	if vRP.isUserInFaction({k,turfWars[turfID].allyFaction}) then
																		vRPCturfs.flickTurf(v,{turfID, 1})
																		vRPCturfs.setInTheTurf(v,{turfID})
																		TriggerEvent("SetEntityVirtualWorld",v, turfID)
																		--SetPlayerRoutingBucket(v,turfID)
																		vRPCturfs.drawTimer(v,{minute[turfID],secunde[turfID],turfID})
																		vRPCturfs.updateScore(v,{turfWars[turfID].enemyScore,turfWars[turfID].allyScore,turfWars[turfID].enemyFaction,turfWars[turfID].allyFaction})
																	elseif vRP.isUserInFaction({k,turfWars[turfID].enemyFaction}) then
																		vRPCturfs.flickTurf(v,{turfID, 1})
																		vRPCturfs.setInTheTurf(v,{turfID})
																		--SetPlayerRoutingBucket(v,turfID)
																		TriggerEvent("SetEntityVirtualWorld",v, turfID)
																		vRPCturfs.drawTimer(v,{minute[turfID],secunde[turfID],turfID})
																		vRPCturfs.updateScore(v,{turfWars[turfID].enemyScore,turfWars[turfID].allyScore,turfWars[turfID].enemyFaction,turfWars[turfID].allyFaction})
																	end
																	
																end
															else
																vRPclient.notify(thePlayer,{'~r~Aceast turf este deja in war!'})
															end
														else
															vRPclient.notify(thePlayer,{'~r~Aceasta factiune este deja in war!'})
														end
													else
														vRPclient.notify(thePlayer,{"~r~Deja esti intr-un war!"})
													end
												else
													vRPclient.notify(thePlayer,{"~r~Nu esti liderul factiunii ~y~"..faction})
												end
											--end
										else
											vRPclient.notify(thePlayer,{"~r~Factiunea inamica nu are 3 membrii online in factiune"})
										end
									else
										vRPclient.notify(thePlayer,{"~r~Nu ai 3 membrii online in factiune"})
									end
							end
						end
					end
	
					else
						vRPclient.notify(thePlayer,{"~r~Nu esti in niciun Turf!"})
					end
				end)
			else
				vRPclient.notify(thePlayer,{"~r~Te crezi mafiot?"})
			end
		end
	else
		vRPclient.notify(thePlayer,{"~r~Warurile incep de la ora ~y~20:00~r~ si tin pana la ~y~22:00"})
	end
end)

--[[
RegisterCommand("cancelattack",function(source)
	vRPCturfs.saTiIauMortiiInPulaDeScript(source,{},function(turfID)
		if turfID then
			cancelAttack(turfID)
		else
			vRPclient.notify(source,{"~r~Nu faci parte din niciun War!"})
		end
	end)
end)
]]
RegisterCommand("wars",function(source)
	local data = json.decode(json.encode(turfWars))
	for k,v in pairs(turfWars)do
		if v.enemyFaction and v.allyFaction then
			TriggerClientEvent('chatMessage',source,"^1==================================================")
			TriggerClientEvent("chatMessage",source,"^2[Turf #"..k.."] ^0"..v.allyFaction.." ^1[Scor: ^1"..v.allyScore.."^1]^0 ^1vs ^0"..v.enemyFaction.." ^1[Scor: ^1"..v.enemyScore.."^1] ")
			TriggerClientEvent('chatMessage',source,"	Timp turf: ^1"..minute[k]..":"..secunde[k])
			TriggerClientEvent('chatMessage',source,"^1==================================================")
		end
	end
end)
RegisterCommand("stopturf",function(source,args)
	cancelAttack(args[1])
end)
Citizen.CreateThread(function()
	while true do
		myusers = vRP.getUsers({})
		if cemortitaivrei == false then
			cemortitaivrei = true
		else
			cemortitaivrei = false
		end
		Citizen.Wait(1000)
	end
end)
RegisterCommand("sh",function(source)
	vRPSturfs.spawnTurfs()
	local users = myusers
	for k,v in pairs(users)do
		alreadyExecuted[v] = nil
	end 
end)





AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	if first_spawn then
		Wait(250)
		vRPSturfs.spawnTurfsC(source)
		local hasFaction = vRP.hasUserFaction({user_id})
		if hasFaction then
			local theFaction = vRP.getUserFaction({user_id})
			for k,v in pairs(theTurfs)do
				turfID = v.id
				if turfWars[turfID]then
					if turfWars[turfID].allyFaction == theFaction or turfWars[turfID].enemyFaction == theFaction then
						alreadyExecuted[source] = nil 
						vRPCturfs.setWarStarted(source,{turfID})
						TriggerEvent("SetEntityVirtualWorld",source, turfID)

						vRPCturfs.setInTheTurf(source,{turfID})
						vRPCturfs.drawTimer(source,{minute[turfID],secunde[turfID],turfID})
						vRPCturfs.updateScore(source,{turfWars[turfID].enemyScore,turfWars[turfID].allyScore,turfWars[turfID].enemyFaction,turfWars[turfID].allyFaction})
						break
					end
				end
			end
		end
	end
end)

RegisterCommand("getora",function(source)
local actDate = os.time() * 60 * 60
print(os.date("%H"))
end)


RegisterCommand("setfwarf",function(source,args)
	inWar[args[1]] = false
end)

local cfg = module("vrp","cfg/factions")
local factions = cfg.factions

AddEventHandler("onResourceStart", function(res)
		Citizen.Wait(200)
		vRPSturfs.spawnTurfs()
		vRPSturfs.spawnTurfsC(-1)
		
		for i,v in pairs(factions) do
			lastAttacked[i] = 0
		end

		for k,v in pairs(myusers)do

			Wait(50)
			local source = v
			vRPSturfs.spawnTurfsC(source)
			local hasFaction = vRP.hasUserFaction({user_id})
			if hasFaction then
				local theFaction = vRP.getUserFaction({user_id})
				for k,v in pairs(theTurfs)do
					turfID = v.id
					if turfWars[turfID]then
						if turfWars[turfID].allyFaction == theFaction or turfWars[turfID].enemyFaction == theFaction then
							alreadyExecuted[source] = nil 
							vRPCturfs.setWarStarted(source,{turfID})
							TriggerEvent("SetEntityVirtualWorld",source, turfID)
				
							vRPCturfs.setInTheTurf(source,{turfID})
							vRPCturfs.drawTimer(source,{minute[turfID],secunde[turfID],turfID})
							vRPCturfs.updateScore(source,{turfWars[turfID].enemyScore,turfWars[turfID].allyScore,turfWars[turfID].enemyFaction,turfWars[turfID].allyFaction})
							break
						end
					end
				end
			end
		end 

end)

RegisterServerEvent("turfs:playerDied")
AddEventHandler("turfs:playerDied",function()
	local thePlayer = source
	local user_id = vRP.getUserId({thePlayer})
	if thePlayer ~= nil and not WasEventCanceled() then
		vRPCturfs.isPlayerInTurf(thePlayer,{0},function(inTurf)
			if inTurf then
				if turfWars[inTurf] then
					local hasFaction = vRP.hasUserFaction({user_id})
					if hasFaction then
						local faction = vRP.getUserFaction({user_id})
						local fType = vRP.getFactionType({faction})
						if fType == "Mafie" then
							print(GetPlayerName(thePlayer).." a murit!")
							vRPCturfs.isInWarAndInComa(thePlayer,{},function(inComa)
								if inComa then
									coords = vRP.getFactionCoords({faction})
									if turfWars[inTurf].allyFaction == faction then
										turfWars[inTurf].enemyScore = turfWars[inTurf].enemyScore + 1
									elseif turfWars[inTurf].enemyFaction == faction then
										turfWars[inTurf].allyScore = turfWars[inTurf].allyScore + 1
									end
									local users = myusers
									for k,v in pairs(users) do
										if vRP.isUserInFaction({k,turfWars[inTurf].allyFaction}) then
											vRPCturfs.updateScore(v,{turfWars[inTurf].enemyScore,turfWars[inTurf].allyScore,turfWars[inTurf].enemyFaction,turfWars[inTurf].allyFaction})
										elseif vRP.isUserInFaction({k,turfWars[inTurf].enemyFaction}) then
											vRPCturfs.updateScore(v,{turfWars[inTurf].enemyScore,turfWars[inTurf].allyScore,turfWars[inTurf].enemyFaction,turfWars[inTurf].allyFaction})
										end
									end
									vRPCturfs.drawTimer(thePlayer,{minute[inTurf],secunde[inTurf],inTurf})
									--vRPclient.varyHealth(thePlayer,{200})
									vRPCturfs.revivePlayer(thePlayer,{})
									--TriggerClientEvent("FRPTurfs:reviveDeadPlayer",thePlayer,200)
									vRPclient.teleport(thePlayer,{coords[1],coords[2],coords[3]})
								end
							end)
						end
					end
				end
			end
		end)
	end
	CancelEvent()
end)

RegisterNetEvent('KillFeed:Killed')
AddEventHandler('KillFeed:Killed', function(killer, weapon, coords, faction)
    TriggerClientEvent('KillFeed:AnnounceKill', -1, GetPlayerName(source), GetPlayerName(killer), weapon, coords, faction)
end)





