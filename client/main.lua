--[[
    NOVA Framework - Chat Client
    Sistema de chat completo com NUI
]]

local isOpen = false
local isChatLoaded = false
local playerColors = {}

-- ============================================================
-- HELPERS
-- ============================================================

local function GetPlayerColor(serverId)
    if playerColors[serverId] then
        return playerColors[serverId]
    end
    local colors = ChatConfig.NameColors
    local idx = (serverId % #colors) + 1
    playerColors[serverId] = colors[idx]
    return playerColors[serverId]
end

-- ============================================================
-- NUI INIT
-- ============================================================

CreateThread(function()
    Wait(1000) -- Esperar NUI carregar

    -- Enviar configuração para NUI
    SendNUIMessage({
        action = 'config',
        maxMessages = ChatConfig.MaxMessages,
        fadeTimeout = ChatConfig.FadeTimeout,
        showTimestamps = ChatConfig.ShowTimestamps,
        maxLength = ChatConfig.MaxLength,
        commands = ChatConfig.Commands,
    })

    isChatLoaded = true
end)

-- ============================================================
-- ABRIR / FECHAR CHAT
-- ============================================================

function OpenChat()
    if isOpen or not isChatLoaded then return end
    isOpen = true

    -- Focus no NUI sem cursor - manter input do jogador
    SetNuiFocus(true, false)
    SetNuiFocusKeepInput(true)
    SendNUIMessage({ action = 'open' })

    -- Desativar apenas controles que interferem com o chat
    CreateThread(function()
        while isOpen do
            -- Bloquear teclas de jogo que interferem com a escrita
            DisableControlAction(0, 245, true)  -- T (abrir chat)
            DisableControlAction(0, 249, true)  -- N
            DisableControlAction(0, 200, true)  -- ESC / Map
            DisableControlAction(0, 322, true)  -- ESC (menu)

            -- Bloquear ações de combate/veículo enquanto escreve
            DisableControlAction(0, 24, true)   -- Attack
            DisableControlAction(0, 25, true)   -- Aim
            DisableControlAction(0, 37, true)   -- Select Weapon
            DisableControlAction(0, 44, true)   -- Cover
            DisableControlAction(0, 47, true)   -- Detonate
            DisableControlAction(0, 58, true)   -- Throw Grenade
            DisableControlAction(0, 71, true)   -- Accelerate
            DisableControlAction(0, 72, true)   -- Brake
            DisableControlAction(0, 73, true)   -- Duck in vehicle
            DisableControlAction(0, 74, true)   -- Headlights
            DisableControlAction(0, 75, true)   -- Exit vehicle
            DisableControlAction(0, 140, true)  -- Melee light
            DisableControlAction(0, 141, true)  -- Melee heavy
            DisableControlAction(0, 142, true)  -- Melee alternate
            DisableControlAction(0, 257, true)  -- Attack 2
            DisableControlAction(0, 263, true)  -- Melee attack 1
            Wait(0)
        end
    end)
end

function CloseChat()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'close' })
end

-- ============================================================
-- TECLA T PARA ABRIR
-- ============================================================

CreateThread(function()
    while true do
        if not isOpen and isChatLoaded then
            if IsControlJustPressed(0, ChatConfig.OpenKey) then -- T (245)
                OpenChat()
            end
            Wait(0)
        else
            Wait(100)
        end
    end
end)

-- ============================================================
-- NUI CALLBACKS
-- ============================================================

RegisterNUICallback('sendMessage', function(data, cb)
    if not data.message or data.message == '' then
        cb('ok')
        return
    end

    CloseChat()

    -- Enviar mensagem ao server
    TriggerServerEvent('nova:chat:sendMessage', data.message, data.type or 'normal')
    cb('ok')
end)

RegisterNUICallback('executeCommand', function(data, cb)
    if not data.command or data.command == '' then
        cb('ok')
        return
    end

    CloseChat()

    -- Executar comando nativo do FiveM
    ExecuteCommand(data.command)
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    CloseChat()
    cb('ok')
end)

-- ============================================================
-- RECEBER MENSAGENS DO SERVER
-- ============================================================

RegisterNetEvent('nova:chat:receiveMessage', function(msg)
    if not isChatLoaded then return end

    SendNUIMessage({
        action = 'addMessage',
        message = msg,
    })
end)

-- ============================================================
-- EXPORTS PARA OUTROS SCRIPTS
-- ============================================================

-- Adicionar mensagem local (apenas no client deste jogador)
function AddChatMessage(data)
    if not isChatLoaded then return end

    local msg = {
        type = data.type or 'normal',
        playerId = data.playerId,
        playerName = data.playerName,
        playerColor = data.playerColor,
        message = data.message or '',
        department = data.department,
        departmentColor = data.departmentColor,
        timestamp = data.timestamp or GetGameTimer(),
    }

    SendNUIMessage({
        action = 'addMessage',
        message = msg,
    })
end

exports('AddChatMessage', AddChatMessage)

-- Adicionar mensagem de sistema
function AddSystemMessage(text)
    AddChatMessage({
        type = 'system',
        message = text,
    })
end

exports('AddSystemMessage', AddSystemMessage)

-- ============================================================
-- EVENTOS PARA OUTROS SCRIPTS ADICIONAREM MENSAGENS
-- ============================================================

RegisterNetEvent('nova:chat:addMessage', function(data)
    AddChatMessage(data)
end)

RegisterNetEvent('nova:chat:systemMessage', function(text)
    AddSystemMessage(text)
end)

-- Limpar chat
RegisterNetEvent('nova:chat:clear', function()
    SendNUIMessage({ action = 'clearMessages' })
end)

-- ============================================================
-- SUGESTÕES DE COMANDOS
-- ============================================================

CreateThread(function()
    Wait(500)
    TriggerEvent('chat:addSuggestion', '/ooc', 'Mensagem fora do personagem', {})
    TriggerEvent('chat:addSuggestion', '/me', 'Descrever uma ação', {})
    TriggerEvent('chat:addSuggestion', '/do', 'Descrever o ambiente', {})
    TriggerEvent('chat:addSuggestion', '/ad', 'Anúncio público', {})
    TriggerEvent('chat:addSuggestion', '/tweet', 'Publicar no Twitter', {})
    TriggerEvent('chat:addSuggestion', '/911', 'Chamar a polícia', {})
    TriggerEvent('chat:addSuggestion', '/ems', 'Chamar paramédicos', {})
    TriggerEvent('chat:addSuggestion', '/mec', 'Chamar mecânico', {})
end)

-- ============================================================
-- COMPATIBILIDADE: chatMessage event (usado por muitos scripts)
-- ============================================================

RegisterNetEvent('chatMessage', function(author, color, text)
    -- Compatibilidade com scripts que usam o evento chatMessage padrão
    if author == '' or author == 'system' then
        AddSystemMessage(text)
    else
        AddChatMessage({
            type = 'normal',
            playerName = author,
            playerColor = type(color) == 'table' and string.format('#%02x%02x%02x', color[1] or 255, color[2] or 255, color[3] or 255) or '#FFFFFF',
            message = text,
        })
    end
end)

-- Compatibilidade: chat:addMessage (formato FiveM padrão)
RegisterNetEvent('chat:addMessage', function(data)
    if not data then return end
    local msgType = 'normal'
    local color = '#FFFFFF'

    if data.color then
        if type(data.color) == 'table' then
            color = string.format('#%02x%02x%02x', data.color[1] or 255, data.color[2] or 255, data.color[3] or 255)
        elseif type(data.color) == 'string' then
            color = data.color
        end
    end

    if data.template then
        if data.template == 'system' or data.template == 'announcement' then
            msgType = 'system'
        end
    end

    AddChatMessage({
        type = msgType,
        playerName = data.author or nil,
        playerColor = color,
        message = type(data.args) == 'table' and table.concat(data.args, ' ') or (data.args or data.message or ''),
    })
end)

print('[NOVA] ^2Chat carregado com sucesso^0')
