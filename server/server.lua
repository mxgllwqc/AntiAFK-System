local checks = {} -- [src] = { phrase = "ABC123", timeoutHandle = ... }

local function generatePhrase()
    local charset = Config.PhraseCharset
    local out = {}

    for i = 1, Config.PhraseLength do
        local idx = math.random(1, #charset)
        out[i] = charset:sub(idx, idx)
    end

    return table.concat(out)
end
-- DODALEM BO MOZE BEDZIECIE CHCIELI
--[[ local function sendWebhook(name, id, reason)
    if not Config.Webhook.enabled or Config.Webhook.url == "" then return end

    PerformHttpRequest(Config.Webhook.url, function() end, 'POST', json.encode({
        username = Config.Webhook.name,
        embeds = {{
            title = "AntiAFK",
            color = Config.Webhook.color,
            fields = {
                { name = "Gracz", value = name, inline = true },
                { name = "ID", value = tostring(id), inline = true },
                { name = "Powód", value = reason, inline = false },
            }
        }}
    }), { ['Content-Type'] = 'application/json' })
end ]]

local function startCheck(src)
    if checks[src] then return end

    local phrase = generatePhrase()
    checks[src] = { phrase = phrase }

    TriggerClientEvent('antiafk:showUI', src, phrase, Config.TimeToAnswer)

    checks[src].timeoutHandle = SetTimeout(Config.TimeToAnswer * 1000, function()
        if not checks[src] then return end
        local name = GetPlayerName(src) or ('ID ' .. src)
        checks[src] = nil
       -- sendWebhook(name, src, "Brak odpowiedzi w wyznaczonym czasie")
        DropPlayer(src, Config.KickMessage)
    end)
end

RegisterNetEvent('antiafk:requestCheck', function()
    startCheck(source)
end)

RegisterNetEvent('antiafk:submitAnswer', function(answer)
    local src = source
    local check = checks[src]
    if not check or type(answer) ~= 'string' then return end

    if answer:upper() == check.phrase:upper() then
        checks[src] = nil
        TriggerClientEvent('antiafk:checkPassed', src)
    else
        TriggerClientEvent('antiafk:wrongAnswer', src)
    end
end)

AddEventHandler('playerDropped', function()
    checks[source] = nil
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        checks = {}
    end
end)

RegisterCommand('forceafk', function(src, args) -- DO TEST TYLLKO

    local target = tonumber(args[1])
    if not target or not GetPlayerName(target) then
        print('[antiafk] użycie: /forceafk [id gracza]')
        return
    end

    startCheck(target)
end, false)
