local lastActivity = GetGameTimer()
local checkOpen = false
local paused = false
local enabled = Config.Enabled

local lastCoords, lastCamRot

local function bump()
    lastActivity = GetGameTimer()
end

CreateThread(function()
    while true do
        Wait(0)
        if enabled and not checkOpen then
            for _, control in ipairs(Config.ActivityControls) do
                if IsControlPressed(0, control) or IsDisabledControlPressed(0, control) then
                    bump()
                    break
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(Config.CheckInterval)

        if not enabled or checkOpen then goto continue end

        local ped = PlayerPedId()
        if not DoesEntityExist(ped) then goto continue end

        local coords = GetEntityCoords(ped)
        local camRot = GetGameplayCamRot(2)

        if lastCoords and #(coords - lastCoords) > Config.MovementThreshold then
            bump()
        end

        if lastCamRot and #(camRot - lastCamRot) > Config.CameraThreshold then
            bump()
        end

        lastCoords, lastCamRot = coords, camRot

        if Config.IgnoreWhenDead and (IsEntityDead(ped) or IsPedFatallyInjured(ped)) then
            bump()
        end

        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        if enabled and not checkOpen and not paused then
            if GetGameTimer() - lastActivity >= Config.TimeBeforeAfkCheck * 1000 then
                checkOpen = true
                TriggerServerEvent('antiafk:requestCheck')
            end
        end
    end
end)

local function closeUI()
    checkOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })

    if Config.FreezePlayerDuringCheck then
        FreezeEntityPosition(PlayerPedId(), false)
    end

    bump()
end

RegisterNetEvent('antiafk:showUI', function(phrase, time)
    checkOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'show',
        phrase = phrase,
        time = time,
        locale = Config.Locale
    })

    if Config.PlaySound then
        PlaySoundFrontend(-1, Config.SoundName, Config.SoundSet, true)
    end

    if Config.FreezePlayerDuringCheck then
        FreezeEntityPosition(PlayerPedId(), true)
    end
end)

RegisterNetEvent('antiafk:wrongAnswer', function()
    SendNUIMessage({ action = 'wrong' })
end)

RegisterNetEvent('antiafk:checkPassed', function()
    closeUI()
end)

CreateThread(function()
    while true do
        if checkOpen and Config.DisableControlsDuringCheck then
            Wait(0)
            DisableAllControlActions(0)
        else
            Wait(250)
        end
    end
end)

RegisterNUICallback('submit', function(data, cb)
    if data and data.answer then
        TriggerServerEvent('antiafk:submitAnswer', tostring(data.answer))
    end
    cb('ok')
end)

exports('PauseAntiAfk', function(state)
    paused = state and true or false
    if not paused then bump() end
end)

exports('ResetAfkTimer', function()
    bump()
end)

exports('SetEnabled', function(state)
    enabled = state and true or false
    if enabled then bump() end
end)

exports('IsAfkCheckActive', function()
    return checkOpen
end)

AddEventHandler('onClientResourceStart', function(res)
    if res == GetCurrentResourceName() then
        bump()
        checkOpen = false
        SetNuiFocus(false, false)
    end
end)
