local QBCore = exports['qb-core']:GetCoreObject()
local currentOrder = nil
local currentDelivery = nil
local pedModel = 'a_m_m_farmer_01' -- Modèle du PNJ (remplace par le modèle que tu souhaites utiliser)

-- Charger le modèle du PNJ
function loadPedModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end
end

-- Création du PNJ avec le modèle spécifique et ajout à ox_target
Citizen.CreateThread(function()
    -- Charger le modèle du PNJ
    loadPedModel(pedModel)
    for key, value in pairs(Config.Business) do
        local pnjCoords = value.npc.pos
        local ped = CreatePed(4, pedModel, pnjCoords.x, pnjCoords.y, pnjCoords.z - 1.0, 1.0, false, true)
        SetEntityHeading(ped, value.npc.heading) -- Orienter le PNJ
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
    
        -- Utiliser ox_target pour interagir avec ce modèle de PNJ
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'delivery:start',
                event = 'gm-delivery:requestOrder',
                icon = 'fa-solid fa-box',
                label = 'Prendre une commande',
                groups = key,
                canInteract = function(entity, distance, coords)
                    return not currentOrder -- Seulement si aucune commande n'est en cours
                end
                
            },
            {
                name = 'delivery:validate',
                event = 'gm-delivery:validateOrder',
                icon = 'fa-solid fa-box-check',
                label = 'Valider la commande',
                groups = key,
                canInteract = function(entity, distance, coords)
                    return (currentOrder and not currentDelivery) -- Si le joueur a tous les items nécessaires
                end
            }
        })
    end

end)

-- Interaction avec le PNJ pour récupérer la commande
RegisterNetEvent('gm-delivery:requestOrder')
AddEventHandler('gm-delivery:requestOrder', function()
    print("requestOrder")
    if currentOrder then
        TriggerEvent('ox_lib:notify', {type = 'error', description = 'Vous avez déjà une commande en cours !'})
        return
    end

    local playerData = QBCore.Functions.GetPlayerData()
    print("requestOrder1 "..playerData.job.name)
    if(Config.Business[playerData.job.name]) then
        print("requestOrder2")
        local cfg = Config.Business[playerData.job.name]

        local order = {}

        local totalAmount = 0
        local minPerDelivery = cfg.minPerDelivery
        local maxPerDelivery = cfg.maxPerDelivery
        minPerDelivery = math.random(minPerDelivery, maxPerDelivery)
        
        print('requestOrder min '..minPerDelivery)
        -- Boucle pour s'assurer que le total amount est dans les limites
        while (totalAmount <= minPerDelivery) do

            -- Parcourir les items
            for itemKey, itemValue in pairs(cfg.items) do
                local amount = math.random(0, 2) -- Générer un nombre aléatoire entre 0 et 2
                
                if amount > 0 then
                    -- Si l'item existe déjà dans result, on met à jour sa quantité
                    if order[itemKey] then
                        order[itemKey] = order[itemKey] + amount
                    else
                        order[itemKey] = amount
                    end
                end
    
                -- Ajouter la quantité à totalAmount
                totalAmount = totalAmount + amount
            end
        end 
    
        currentOrder = order
        TriggerServerEvent('gm-delivery:server:delivery_order', currentOrder)
        
        --TriggerServerEvent('gm-delivery:server:createOrder',order)   
        
        TriggerEvent('ox_lib:notify', {type = 'success', description = 'Vous avez reçu une commande.'})
    end
end)

-- Validation de la commande
RegisterNetEvent('gm-delivery:validateOrder')
AddEventHandler('gm-delivery:validateOrder', function()
    if not currentOrder then
        TriggerEvent('ox_lib:notify', {type = 'error', description = 'Aucune commande en cours.'})
        return
    end

    if currentDelivery then
        TriggerEvent('ox_lib:notify', {type = 'error', description = 'Livraison en attente.'})
        return
    end    

    return TriggerServerEvent('gm-delivery:server:delivery_order', currentOrder)    
end)

RegisterNetEvent('gm-delivery:client:goDelivery')
AddEventHandler('gm-delivery:client:goDelivery', function()
    local randomIndex = math.random(#Config.Locations)
    local randomDelivery = Config.Locations[randomIndex]
    currentDelivery = {
        coords = vector3(randomDelivery[1], randomDelivery[2], randomDelivery[3]),
        heading = randomDelivery[4]
    }

    -- Création du marqueur et du trajet
    TriggerEvent('ox_lib:notify', {type = 'success', description = 'Tous les items sont récupérés, direction la destination.'})

    -- Affichage d'un marqueur visuel pour la livraison
    local blip = AddBlipForCoord(currentDelivery.coords.x, currentDelivery.coords.y, currentDelivery.coords.z)
    SetBlipSprite(blip, 1) -- Blip bleu
    SetBlipRoute(blip, true)
    SetBlipColour(blip, 3)
    currentDelivery.blip = blip
end)



RegisterNetEvent('gm-delivery:client:completeDelivery')
AddEventHandler('gm-delivery:client:completeDelivery', function()
    TriggerServerEvent('gm-delivery:server:rewardPlayer',currentOrder)
    RemoveBlip(currentDelivery.blip)
    currentDelivery = nil
    currentOrder = nil
end)

-- Vérification pour la validation de la livraison à destination
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if currentDelivery and IsPlayerNearCoords(currentDelivery.coords) then
            DrawText3D(currentDelivery.coords.x, currentDelivery.coords.y, currentDelivery.coords.z, "[E] Valider la livraison")

            if IsControlJustPressed(0, 38) then -- Touche E
                TriggerEvent('gm-delivery:client:completeDelivery')
            end
        end
    end
end)

-- Fonction pour vérifier si le joueur est proche de coordonnées données (utile pour la livraison)
function IsPlayerNearCoords(coords)
    local playerCoords = GetEntityCoords(PlayerPedId())
    return #(playerCoords - coords) < 5.0 -- Proximité de 5 unités
end

-- Fonction pour afficher du texte 3D à l'écran
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px, py, pz) - vector3(x, y, z))

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(1)

        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

RegisterNetEvent('gm-delivery:client:displayOrder')
AddEventHandler('gm-delivery:client:displayOrder', function(orderItems)   
     
    orderDisplayOpen = true
    print("displayOrder")    
    if(orderItems)then
        print("order data"..json.encode(orderItems))
    else
        print("order data null")
    end
    local data ={}
    data.items = orderItems
    orderDisplayOpen = true
    -- On envoie les items à la NUI (HTML)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openTicket",
        data = data
    })
end)

function closeMenu()
    SetNuiFocus(false, false)
end

-- Gestion du NUI Callback
RegisterNUICallback('nuiCallback', function(data, cb)
    if data.action == 'closeMenu' then
        closeMenu()  -- Appelle la fonction Lua avec le paramètre envoyé depuis JS
    end

    cb('ok')  -- Réponse à envoyer au JS
end)