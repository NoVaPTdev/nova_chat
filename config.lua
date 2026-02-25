ChatConfig = {}

-- Tecla para abrir o chat (default: T)
ChatConfig.OpenKey = 245 -- T

-- Máximo de caracteres por mensagem
ChatConfig.MaxLength = 256

-- Máximo de mensagens guardadas no chat
ChatConfig.MaxMessages = 100

-- Tempo (ms) antes do chat desaparecer quando inactivo
ChatConfig.FadeTimeout = 10000

-- Opacidade quando inactivo (0.0 - 1.0)
ChatConfig.InactiveOpacity = 0.4

-- Mostrar timestamps quando o chat está activo
ChatConfig.ShowTimestamps = true

-- Prefixo de comandos (sugestões no chat)
ChatConfig.Commands = {
    -- RP (todos os jogadores)
    { command = '/ooc',   type = 'ooc',           description = 'Mensagem fora do personagem', icon = '💬', color = '#42A5F5' },
    { command = '/me',    type = 'me',            description = 'Descrever uma ação',          icon = '🎭', color = '#BA68C8' },
    { command = '/do',    type = 'do',            description = 'Descrever o ambiente/situação', icon = '📝', color = '#66BB6A' },
    { command = '/ad',    type = 'system',         description = 'Anúncio público',             icon = '📢', color = '#C5FF00' },
    { command = '/tweet', type = 'twitter',        description = 'Publicar no Twitter',         icon = '🐦', color = '#1DA1F2' },
    { command = '/911',   type = 'radio-police',   description = 'Chamar a polícia',            icon = '🚔', color = '#4A90D9' },
    { command = '/ems',   type = 'radio-ems',      description = 'Chamar paramédicos',          icon = '🚑', color = '#FF6B6B' },
    { command = '/mec',   type = 'radio-mechanic', description = 'Chamar mecânico',             icon = '🔧', color = '#FFA500' },
    { command = '/duty',  type = 'cmd',            description = 'Entrar/sair de serviço',      icon = '👔', color = '#2ECC71' },

    -- Admin
    { command = '/announce',       type = 'cmd', description = 'Anúncio do sistema (admin)',       icon = '📣', color = '#FF5555' },
    { command = '/clearchat',      type = 'cmd', description = 'Limpar chat (admin)',              icon = '🧹', color = '#FF5555' },
    { command = '/giveitem',       type = 'cmd', description = 'Dar item [id] [item] [qtd]',      icon = '🎁', color = '#FF5555' },
    { command = '/givemoney',      type = 'cmd', description = 'Dar dinheiro [id] [tipo] [qtd]',   icon = '💰', color = '#FF5555' },
    { command = '/removemoney',    type = 'cmd', description = 'Remover dinheiro [id] [tipo] [qtd]', icon = '💸', color = '#FF5555' },
    { command = '/setjob',         type = 'cmd', description = 'Definir emprego [id] [job] [grau]', icon = '💼', color = '#FF5555' },
    { command = '/setgang',        type = 'cmd', description = 'Definir gang [id] [gang] [grau]',  icon = '🔫', color = '#FF5555' },
    { command = '/setgroup',       type = 'cmd', description = 'Definir grupo [id] [grupo]',       icon = '👑', color = '#FF5555' },
    { command = '/tp',             type = 'cmd', description = 'Teleportar para jogador [id]',     icon = '⚡', color = '#FF5555' },
    { command = '/bring',          type = 'cmd', description = 'Trazer jogador [id]',              icon = '🧲', color = '#FF5555' },
    { command = '/revive',         type = 'cmd', description = 'Reviver jogador [id]',             icon = '❤️', color = '#FF5555' },
    { command = '/heal',           type = 'cmd', description = 'Curar jogador [id]',               icon = '💊', color = '#FF5555' },
    { command = '/kick',           type = 'cmd', description = 'Expulsar jogador [id] [motivo]',   icon = '🚫', color = '#FF5555' },
    { command = '/ban',            type = 'cmd', description = 'Banir jogador [id] [motivo]',      icon = '⛔', color = '#FF5555' },
    { command = '/addcar',         type = 'cmd', description = 'Adicionar veículo [id] [modelo]',  icon = '🚗', color = '#FF5555' },
    { command = '/delveh',         type = 'cmd', description = 'Apagar veículo [placa]',           icon = '🗑️', color = '#FF5555' },
    { command = '/garageadmin',    type = 'cmd', description = 'Painel admin garagem',             icon = '🏗️', color = '#FF5555' },
    { command = '/clearinventory', type = 'cmd', description = 'Limpar inventário [id]',           icon = '🧹', color = '#FF5555' },
    { command = '/logout',         type = 'cmd', description = 'Forçar logout jogador',            icon = '🚪', color = '#FF5555' },
}

-- Cores dos departamentos rádio
ChatConfig.Departments = {
    ['radio-police']   = { label = 'POLÍCIA',  color = '#4A90D9' },
    ['radio-ems']      = { label = 'EMS',      color = '#FF6B6B' },
    ['radio-mechanic'] = { label = 'MECÂNICO', color = '#FFA500' },
}

-- Jogadores com permissão para /ad (anúncio)
-- 'all' = todos, 'admin' = apenas admins
ChatConfig.AnnouncementPermission = 'admin'

-- Proximidade do chat normal (em metros, 0 = global)
ChatConfig.ProximityRange = 0

-- Cores aleatórias para nomes de jogadores
ChatConfig.NameColors = {
    '#4A90E2', '#E94B3C', '#9B59B6', '#2ECC71', '#F39C12',
    '#1ABC9C', '#E74C3C', '#3498DB', '#E67E22', '#27AE60',
    '#8E44AD', '#C0392B', '#D35400', '#16A085', '#2980B9',
    '#F1C40F', '#7F8C8D', '#FF6B6B', '#FFA500', '#BA68C8',
}
