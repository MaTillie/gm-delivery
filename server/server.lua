local QBCore = exports['qb-core']:GetCoreObject()

function PrintTable(t, indent)
    indent = indent or 0
    local prefix = string.rep(" ", indent)
    if type(t) == "table" then
        for k, v in pairs(t) do
            if type(v) == "table" then
                print(prefix .. tostring(k) .. ":")
                PrintTable(v, indent + 2)
            else
                print(prefix .. tostring(k) .. ": " .. tostring(v))
            end
        end
    else
        print(prefix .. tostring(t))
    end
end

RegisterNetEvent('gm-delivery:server:rewardPlayer')
AddEventHandler('gm-delivery:server:rewardPlayer', function(metadata)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    local totalAmount = math.random(Config.Business[player.PlayerData.job.name].additionalDeliveryReward.min, Config.Business[player.PlayerData.job.name].additionalDeliveryReward.max)
    
    for item, amount in pairs(metadata) do  
        totalAmount = totalAmount + (Config.Business[player.PlayerData.job.name].items[item].price * amount)
    end   

    player.Functions.AddMoney('cash', totalAmount)
    local tenPercent = totalAmount * 0.10
    local roundedTenPercent = math.floor(tenPercent + 0.5)
    exports.fdsdev_bossmenu.addMoney(nil, player.PlayerData.job.name, roundedTenPercent, "Livraison", "Livraison de "..player.PlayerData.charinfo.firstname.." "..player.PlayerData.charinfo.lastname )
   -- xPlayer.Functions.AddExperience('delivery', itemCount * 10) -- Exemple de gain d'expérience
end)

local function getItemLabel(itemName)
    local item = exports.ox_inventory:Items()[itemName]
    if item then
        return item.label
    else
        return "Item inconnu"
    end
end

RegisterNetEvent('gm-delivery:server:delivery_order', function(metadata)
    local src = source
    local items = {}
    local hasAllItems = true

    local player = exports.qbx_core:GetPlayer(src)
    print("delivery_order")
    PrintTable(metadata)
    for item, amount in pairs(metadata) do       

        local itemCount = exports.ox_inventory:GetItemCount(src, item,mtdt)

        if itemCount < amount then
            hasAllItems = false
            table.insert(items, {
                name = getItemLabel(item),
                amount = itemCount.."/"..amount,
                cl = notCompleted,
            })
        else
            table.insert(items, {
                name = getItemLabel(item),
                amount = amount.."/"..amount,
                cl = completed,
            })
        end
    end
    
    if hasAllItems then
        -- Retirer le ticket

        -- Retirer les items de la commande de l'inventaire du joueur
        for item, amount in pairs(metadata) do   
            exports.ox_inventory:RemoveItem(src, item, amount)
        end
        
        -- Ajouter l'item "repas_empaquete" avec les mêmes métadonnées
        -- Lance delivery cote client
        
        TriggerClientEvent('gm-delivery:client:goDelivery', src)
        TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Les objets sont empaquetés'})
        return true
    else
        local src = source
        local player = exports.qbx_core:GetPlayer(src)

        TriggerClientEvent('gm-delivery:client:displayOrder', src, items)
        return false
    end   
end)
