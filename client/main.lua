RDX = nil

Citizen.CreateThread(function()
    while RDX == nil do
		TriggerEvent('rdx:getSharedObject', function(obj) RDX = obj end)
		Citizen.Wait(0)
    end
    
	RDX.PlayerData = RDX.GetPlayerData()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

       if Citizen.InvokeNative(0x580417101DDB492F, 0, Config.OpenControl) then
            loadPlayerInventory()
            SendNUIMessage({
                action = "display"
            })
            SetNuiFocus(true, true)
        end
    end
end)

RegisterNUICallback('NUIFocusOff', function()
    SendNUIMessage({
        action = "hide"
    })
	SetNuiFocus(false, false)
end)

RegisterNUICallback('GetNearPlayers', function(data, cb)
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = RDX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
    local foundPlayers = false
    local elements     = {}

    for i=1, #players, 1 do
        if players[i] ~= PlayerId() then
            foundPlayers = true

            table.insert(elements, {
                label = GetPlayerName(players[i]),
                player = GetPlayerServerId(players[i])
            })
        end
    end
    
    if not foundPlayers then
        
    else
        SendNUIMessage({
            action = "nearPlayers",
            foundAny = foundPlayers,
            players = elements,
            item = data.item,
            count = data.count,
            type = data.type,
            what = data.what
        })
    end
    
	cb("ok")
end)

RegisterNUICallback('UseItem', function(data, cb)
    TriggerServerEvent('rdx:useItem', data.item)
    Citizen.Wait(500)
    loadPlayerInventory()
	cb("ok")
end)

RegisterNUICallback('DropItem', function(data, cb)
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end
    
    if data.type == 'item_weapon' then
        TriggerServerEvent('rdx:removeInventoryItem', data.type, data.item)
        Wait(500)
        loadPlayerInventory()
    else -- type: item_standard
        TriggerServerEvent('rdx:removeInventoryItem', data.type, data.item, data.number)
        Wait(500)
        loadPlayerInventory()
    end

	cb("ok")
end)

RegisterNUICallback('GiveItem', function(data, cb)
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = RDX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
    local foundPlayer = false
    for i=1, #players, 1 do
        if players[i] ~= PlayerId() then
            if GetPlayerServerId(players[i]) == data.player then
                foundPlayer = true
            end
        end
    end
    
    if foundPlayer then
        TriggerServerEvent('rdx:giveInventoryItem', data.player, data.data.type, data.data.item, tonumber(data.data.count))
        Wait(500)
        loadPlayerInventory()
    else
       --RDX.ShowNotification(_U('player_nearby'), 'error')
    end
	cb("ok")
end)

function shouldSkipAccount (accountName)
    for index, value in ipairs(Config.ExcludeAccountsList) do
        if value == accountName then
            return true
        end
    end

    return false
end

function loadPlayerInventory()
    PlayerData = RDX.GetPlayerData()
    local playerPed = PlayerPedId()
    local inventory = PlayerData["inventory"]
    local money = PlayerData["money"]
    local accounts = PlayerData["accounts"]
    local items  = {}

    if Config.IncludeCash then
        if money > 0 then
            local formattedMoney = RDX.Math.GroupDigits(money)

            table.insert(items, {
                label     = 'Cash',
                count     = formattedMoney,
                type      = 'item_money',
                name     = 'cash',
                usable    = false,
                rare      = false,
                weight = -1,
                canRemove = true
            })
        end
    end

    if Config.IncludeAccounts then
        for i=1, #accounts, 1 do
            if not shouldSkipAccount(accounts[i].name) then
                if accounts[i].money > 0 then
                    local canDrop = accounts[i].name ~= 'bank'

                    table.insert(items, {
                        label     = accounts[i].label,
                        count     = accounts[i].money,
                        type      = 'item_account',
                        name     = accounts[i].name,
                        usable    = false,
                        rare      = false,
                        weight = -1,
                        canRemove = canDrop
                    })
                end
            end
        end
    end
    
    for i=1, #inventory, 1 do
		if inventory[i].count > 0 then
			table.insert(items, {
				label     = inventory[i].label,
				type      = 'item_standard',
				count     = inventory[i].count,
				name     = inventory[i].name,
				usable    = inventory[i].usable,
				rare      = inventory[i].rare,
				weight      = -1,
				canRemove = inventory[i].canRemove
			})
		end
    end

    if Config.IncludeWeapons then
        local weaponsList = RDX.GetWeaponList()
        for i=1, #weaponsList, 1 do
            local weaponHash = GetHashKey(weaponsList[i].name)

            if HasPedGotWeapon(playerPed, weaponHash, false) and weaponsList[i].name ~= 'WEAPON_UNARMED' then
                local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
                table.insert(items, {
                    label     = weaponsList[i].label,
                    count     = ammo,
                    weight     = -1,
                    type      = 'item_weapon',
                    name     = weaponsList[i].name,
                    usable    = false,
                    rare      = false,
                    canRemove = true
                })
            end
        end
    end
    
    
    SendNUIMessage({
        action = "setItems",
        itemList = items
    })
end

RegisterCommand("i", function()
loadPlayerInventory()
            SendNUIMessage({
                action = "display"
            })
            SetNuiFocus(true, true)
end)
