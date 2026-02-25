--[[
    NOVA Framework - Chat Server
    Processa e distribui mensagens entre jogadores
]]

local GetPlayer = exports['nova_core'].GetPlayer

-- ============================================================
-- HELPERS
-- ============================================================

local function GetPlayerColor(src)
    local colors = ChatConfig.NameColors
    local idx = (src % #colors) + 1
    return colors[idx]
end

local NativeGetPlayerName = GetPlayerName -- FiveM native

local function GetCharacterName(src)
    local player = GetPlayer(src)
    if player then
        local firstname = player.firstname or ''
        local lastname = player.lastname or ''
        if firstname ~= '' then
            return firstname .. ' ' .. lastname
        end
    end
    return NativeGetPlayerName(src) or ('Jogador ' .. src)
end

local function GetPlayerServerId(src)
    return src
end

local function IsAdmin(src)
    local player = GetPlayer(src)
    if not player then return false end

    local group = player.group
    if group and (group == 'admin' or group == 'superadmin' or group == 'owner' or group == 'god') then
        return true
    end

    -- Fallback DB
    local identifier = player.identifier
    if identifier then
        local result = MySQL.scalar.await('SELECT `group` FROM nova_users WHERE identifier = ?', { identifier })
        if result and (result == 'admin' or result == 'superadmin' or result == 'owner' or result == 'god') then
            return true
        end
    end

    return false
end

local function GetPlayerJob(src)
    local player = GetPlayer(src)
    if player then
        return player.job or 'desempregado'
    end
    return 'desempregado'
end

-- ============================================================
-- DEPARTMENT CONFIG
-- ============================================================

local DepartmentJobs = {
    ['radio-police'] = {
        jobs = { 'policia', 'police', 'bcso', 'sasp', 'fbi', 'doj' },
        label = 'POLÍCIA',
        color = '#4A90D9',
    },
    ['radio-ems'] = {
        jobs = { 'ems', 'ambulance', 'hospital', 'medico' },
        label = 'EMS',
        color = '#FF6B6B',
    },
    ['radio-mechanic'] = {
        jobs = { 'mechanic', 'mecanico', 'mechanic', 'tow' },
        label = 'MECÂNICO',
        color = '#FFA500',
    },
}

-- ============================================================
-- RECEBER MENSAGEM DO CLIENT
-- ============================================================

RegisterNetEvent('nova:chat:sendMessage', function(text, msgType)
    local src = source
    if not text or text == '' then return end

    -- Anti-spam: limitar tamanho
    if #text > ChatConfig.MaxLength then
        text = string.sub(text, 1, ChatConfig.MaxLength)
    end

    local playerName = GetCharacterName(src)
    local playerId = GetPlayerServerId(src)
    local playerColor = GetPlayerColor(src)
    local playerJob = GetPlayerJob(src)

    local msg = {
        type = msgType,
        playerId = playerId,
        playerName = playerName,
        playerColor = playerColor,
        message = text,
        timestamp = os.time() * 1000, -- ms para JS
    }

    -- ============ NORMAL ============
    if msgType == 'normal' then
        TriggerClientEvent('nova:chat:receiveMessage', -1, msg)

    -- ============ OOC ============
    elseif msgType == 'ooc' then
        msg.type = 'ooc'
        TriggerClientEvent('nova:chat:receiveMessage', -1, msg)

    -- ============ ME ============
    elseif msgType == 'me' then
        msg.type = 'me'
        TriggerClientEvent('nova:chat:receiveMessage', -1, msg)

    -- ============ DO ============
    elseif msgType == 'do' then
        msg.type = 'do'
        TriggerClientEvent('nova:chat:receiveMessage', -1, msg)

    -- ============ SYSTEM / ANNOUNCEMENT ============
    elseif msgType == 'system' then
        if ChatConfig.AnnouncementPermission == 'admin' and not IsAdmin(src) then
            TriggerClientEvent('nova:chat:receiveMessage', src, {
                type = 'system',
                message = 'Não tens permissão para usar anúncios.',
                timestamp = os.time() * 1000,
            })
            return
        end
        msg.type = 'system'
        msg.playerId = nil -- Sistema não mostra ID
        msg.playerName = nil
        TriggerClientEvent('nova:chat:receiveMessage', -1, msg)

    -- ============ TWITTER ============
    elseif msgType == 'twitter' then
        msg.type = 'twitter'
        TriggerClientEvent('nova:chat:receiveMessage', -1, msg)

    -- ============ RADIO (DEPARTAMENTOS) ============
    elseif msgType == 'radio-police' or msgType == 'radio-ems' or msgType == 'radio-mechanic' then
        local deptConfig = DepartmentJobs[msgType]
        if not deptConfig then return end

        -- Verificar se jogador pertence ao departamento
        local isInDept = false
        for _, job in ipairs(deptConfig.jobs) do
            if playerJob == job then
                isInDept = true
                break
            end
        end

        if not isInDept and not IsAdmin(src) then
            TriggerClientEvent('nova:chat:receiveMessage', src, {
                type = 'system',
                message = 'Não pertences a este departamento.',
                timestamp = os.time() * 1000,
            })
            return
        end

        msg.type = 'radio'
        msg.department = deptConfig.label
        msg.departmentColor = deptConfig.color

        -- Enviar apenas para membros do mesmo departamento + admins
        local players = GetPlayers()
        for _, targetId in ipairs(players) do
            local tid = tonumber(targetId)
            if tid then
                local targetJob = GetPlayerJob(tid)
                local shouldReceive = false

                for _, job in ipairs(deptConfig.jobs) do
                    if targetJob == job then
                        shouldReceive = true
                        break
                    end
                end

                if not shouldReceive then
                    shouldReceive = IsAdmin(tid)
                end

                if shouldReceive then
                    TriggerClientEvent('nova:chat:receiveMessage', tid, msg)
                end
            end
        end

    else
        -- Tipo desconhecido, tratar como normal
        msg.type = 'normal'
        TriggerClientEvent('nova:chat:receiveMessage', -1, msg)
    end
end)

-- ============================================================
-- EXPORTS PARA OUTROS SCRIPTS
-- ============================================================

-- Enviar mensagem para todos os jogadores
function SendChatMessage(data)
    local msg = {
        type = data.type or 'normal',
        playerId = data.playerId,
        playerName = data.playerName,
        playerColor = data.playerColor or '#FFFFFF',
        message = data.message or '',
        department = data.department,
        departmentColor = data.departmentColor,
        timestamp = os.time() * 1000,
    }

    if data.target then
        TriggerClientEvent('nova:chat:receiveMessage', data.target, msg)
    else
        TriggerClientEvent('nova:chat:receiveMessage', -1, msg)
    end
end

exports('SendChatMessage', SendChatMessage)

-- Enviar mensagem de sistema para todos
function SendSystemMessage(text, target)
    local msg = {
        type = 'system',
        message = text,
        timestamp = os.time() * 1000,
    }
    TriggerClientEvent('nova:chat:receiveMessage', target or -1, msg)
end

exports('SendSystemMessage', SendSystemMessage)

-- Enviar mensagem de admin
function SendAdminMessage(adminName, text, target)
    local msg = {
        type = 'admin',
        playerName = adminName,
        message = text,
        timestamp = os.time() * 1000,
    }
    TriggerClientEvent('nova:chat:receiveMessage', target or -1, msg)
end

exports('SendAdminMessage', SendAdminMessage)

-- ============================================================
-- COMANDOS ADMIN
-- ============================================================

RegisterCommand('announce', function(src, args, raw)
    if src > 0 and not IsAdmin(src) then
        TriggerClientEvent('nova:chat:receiveMessage', src, {
            type = 'system',
            message = 'Não tens permissão.',
            timestamp = os.time() * 1000,
        })
        return
    end

    local text = table.concat(args, ' ')
    if text == '' then return end

    SendSystemMessage(text)
end, false)

RegisterCommand('clearchat', function(src, args, raw)
    if src > 0 and not IsAdmin(src) then return end

    if args[1] then
        local inputId = tonumber(args[1])
        if inputId then
            -- Resolver charId → source (ID persistente do HUD)
            local resolved = nil
            pcall(function()
                resolved = exports['nova_core']:CharIdToSource(inputId)
            end)
            local targetId = resolved or inputId
            TriggerClientEvent('nova:chat:clear', targetId)
        end
    else
        TriggerClientEvent('nova:chat:clear', -1)
    end
end, false)

-- ============================================================
-- EVENTO DE CONEXÃO
-- ============================================================

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    -- Pode ser usado para logs
end)

RegisterNetEvent('nova:server:onPlayerLoaded', function()
    -- Jogador carregado
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local playerName = GetCharacterName(src) or ('Jogador ' .. src)

    -- Notificar saída (opcional - pode comentar se não quiser)
    -- SendSystemMessage(playerName .. ' saiu do servidor.')
end)

print('[NOVA] ^2Chat Server carregado^0')
