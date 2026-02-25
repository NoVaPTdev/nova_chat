/* ============================================================
   NOVA Chat - JavaScript (NUI)
   ============================================================ */

// ============ STATE ============

let isActive = false;
let messages = [];
let maxMessages = 100;
let fadeTimeout = 10000;
let showTimestamps = true;
let maxLength = 256;
let currentType = 'normal';
let commands = [];
let fadeTimer = null;

// ============ ELEMENTS ============

const chatContainer = document.getElementById('chatContainer');
const messagesList = document.getElementById('messagesList');
const inputArea = document.getElementById('inputArea');
const chatForm = document.getElementById('chatForm');
const chatInput = document.getElementById('chatInput');
const inputBar = document.getElementById('inputBar');
const commandPrefix = document.getElementById('commandPrefix');
const sendBtn = document.getElementById('sendBtn');
const inputProgress = document.getElementById('inputProgress');
const charCount = document.getElementById('charCount');
const suggestionsDropdown = document.getElementById('suggestionsDropdown');

// ============ NUI COMMUNICATION ============

function post(event, data) {
    fetch('https://nova_chat/' + event, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    });
}

// ============ NUI MESSAGE HANDLER ============

window.addEventListener('message', (e) => {
    const d = e.data;
    switch (d.action) {
        case 'open':
            openChat();
            break;
        case 'close':
            closeChat();
            break;
        case 'addMessage':
            addMessage(d.message);
            break;
        case 'addMessages':
            if (d.messages && d.messages.length) {
                d.messages.forEach(m => addMessage(m));
            }
            break;
        case 'clearMessages':
            messages = [];
            messagesList.innerHTML = '';
            break;
        case 'config':
            if (d.maxMessages) maxMessages = d.maxMessages;
            if (d.fadeTimeout) fadeTimeout = d.fadeTimeout;
            if (d.showTimestamps !== undefined) showTimestamps = d.showTimestamps;
            if (d.maxLength) { maxLength = d.maxLength; chatInput.maxLength = maxLength; }
            if (d.commands) commands = d.commands;
            break;
    }
});

// ============ OPEN / CLOSE ============

function openChat() {
    isActive = true;
    chatContainer.className = 'chat-container active';
    inputArea.style.display = '';
    chatInput.focus();
    clearFadeTimer();
    scrollToBottom();
}

function closeChat() {
    isActive = false;
    inputArea.style.display = 'none';
    chatInput.value = '';
    chatInput.blur();
    currentType = 'normal';
    updatePrefix();
    updateProgress();
    hideSuggestions();
    inputBar.classList.remove('focused');
    startFadeTimer();
}

// ============ FADE LOGIC ============

function startFadeTimer() {
    clearFadeTimer();
    chatContainer.className = 'chat-container inactive';
    fadeTimer = setTimeout(() => {
        chatContainer.className = 'chat-container hidden';
    }, fadeTimeout);
}

function clearFadeTimer() {
    if (fadeTimer) {
        clearTimeout(fadeTimer);
        fadeTimer = null;
    }
}

function showTemporary() {
    if (isActive) return;
    chatContainer.className = 'chat-container inactive';
    clearFadeTimer();
    fadeTimer = setTimeout(() => {
        chatContainer.className = 'chat-container hidden';
    }, fadeTimeout);
}

// ============ MESSAGES ============

function addMessage(msg) {
    messages.push(msg);

    // Limit max messages
    while (messages.length > maxMessages) {
        messages.shift();
        if (messagesList.firstChild) {
            messagesList.removeChild(messagesList.firstChild);
        }
    }

    const el = createMessageElement(msg);
    messagesList.appendChild(el);
    scrollToBottom();

    // Show chat temporarily when new message arrives
    if (!isActive) {
        showTemporary();
    }
}

function createMessageElement(msg) {
    const type = msg.type || 'normal';
    const time = formatTime(msg.timestamp);

    switch (type) {
        case 'ooc': return buildOOC(msg, time);
        case 'me': return buildMe(msg, time);
        case 'do': return buildDo(msg, time);
        case 'system': return buildSystem(msg, time);
        case 'admin': return buildAdmin(msg, time);
        case 'twitter': return buildTwitter(msg, time);
        case 'radio':
        case 'radio-police':
        case 'radio-ems':
        case 'radio-mechanic':
            return buildRadio(msg, time);
        default: return buildNormal(msg, time);
    }
}

function formatTime(ts) {
    if (!ts) return '';
    const d = new Date(ts);
    if (isNaN(d.getTime())) return '';
    return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', hour12: false });
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// ============ MESSAGE BUILDERS ============

function buildNormal(msg, time) {
    const div = document.createElement('div');
    div.className = 'msg msg-normal';
    let html = '';
    if (msg.playerId) html += `<span class="msg-badge badge-id">ID: ${msg.playerId}</span>`;
    if (msg.playerName) html += `<span class="msg-name" style="color:${msg.playerColor || '#FFFFFF'}">${escapeHtml(msg.playerName)}:</span>`;
    html += `<span class="msg-text">${escapeHtml(msg.message)}</span>`;
    html += `<span class="msg-time">${time}</span>`;
    div.innerHTML = html;
    return div;
}

function buildOOC(msg, time) {
    const div = document.createElement('div');
    div.className = 'msg msg-ooc';
    let html = '<span class="msg-badge badge-ooc">OOC</span>';
    if (msg.playerId) html += `<span class="msg-badge badge-id">ID: ${msg.playerId}</span>`;
    if (msg.playerName) html += `<span class="msg-name" style="color:${msg.playerColor || '#FFFFFF'}">${escapeHtml(msg.playerName)}:</span>`;
    html += `<span class="msg-text">${escapeHtml(msg.message)}</span>`;
    html += `<span class="msg-time">${time}</span>`;
    div.innerHTML = html;
    return div;
}

function buildMe(msg, time) {
    const div = document.createElement('div');
    div.className = 'msg msg-me';
    let html = `<span class="msg-text">* ${escapeHtml(msg.playerName || '')} ${escapeHtml(msg.message)} *</span>`;
    html += `<span class="msg-time">${time}</span>`;
    div.innerHTML = html;
    return div;
}

function buildDo(msg, time) {
    const div = document.createElement('div');
    div.className = 'msg msg-do';
    let html = `<span class="msg-text">* ${escapeHtml(msg.message)} (${escapeHtml(msg.playerName || '')}) *</span>`;
    html += `<span class="msg-time">${time}</span>`;
    div.innerHTML = html;
    return div;
}

function buildSystem(msg, time) {
    const div = document.createElement('div');
    div.className = 'msg msg-system';
    let html = `<span class="msg-icon"><svg width="16" height="16" fill="none" stroke="#C5FF00" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg></span>`;
    html += `<span class="msg-text">${escapeHtml(msg.message)}</span>`;
    html += `<span class="msg-time">${time}</span>`;
    div.innerHTML = html;
    return div;
}

function buildAdmin(msg, time) {
    const div = document.createElement('div');
    div.className = 'msg msg-admin';
    let html = '<span class="msg-badge badge-admin">ADMIN</span>';
    if (msg.playerName) html += `<span class="msg-name" style="color:#FFFFFF">${escapeHtml(msg.playerName)}:</span>`;
    html += `<span class="msg-text">${escapeHtml(msg.message)}</span>`;
    html += `<span class="msg-time">${time}</span>`;
    div.innerHTML = html;
    return div;
}

function buildTwitter(msg, time) {
    const div = document.createElement('div');
    div.className = 'msg msg-twitter';
    let html = `<span class="msg-badge badge-tweet"><svg class="tweet-icon" viewBox="0 0 24 24"><path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/></svg>Tweet</span>`;
    if (msg.playerName) html += `<span class="msg-name" style="color:${msg.playerColor || '#FFFFFF'}">@${escapeHtml(msg.playerName)}:</span>`;
    html += `<span class="msg-text">${escapeHtml(msg.message)}</span>`;
    html += `<span class="msg-time">${time}</span>`;
    div.innerHTML = html;
    return div;
}

function buildRadio(msg, time) {
    const div = document.createElement('div');
    div.className = 'msg msg-radio';
    let html = '';
    if (msg.department) {
        const deptColor = msg.departmentColor || '#C5FF00';
        html += `<span class="badge-dept" style="background:${deptColor}20;color:${deptColor}">${escapeHtml(msg.department)}</span>`;
    }
    if (msg.playerId) html += `<span class="msg-badge badge-id">ID: ${msg.playerId}</span>`;
    if (msg.playerName) html += `<span class="msg-name" style="color:${msg.playerColor || '#FFFFFF'}">${escapeHtml(msg.playerName)}:</span>`;
    html += `<span class="msg-text">${escapeHtml(msg.message)}</span>`;
    html += `<span class="msg-time">${time}</span>`;
    div.innerHTML = html;
    return div;
}

// ============ SCROLL ============

function scrollToBottom() {
    requestAnimationFrame(() => {
        messagesList.scrollTop = messagesList.scrollHeight;
    });
}

// ============ INPUT HANDLING ============

chatInput.addEventListener('input', () => {
    const val = chatInput.value;
    sendBtn.disabled = !val.trim();
    updateProgress();
    updatePrefix();
    updateSuggestions();
    inputBar.classList.add('focused');
});

chatInput.addEventListener('focus', () => {
    inputBar.classList.add('focused');
});

chatInput.addEventListener('blur', () => {
    if (!chatInput.value) inputBar.classList.remove('focused');
});

chatForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const val = chatInput.value.trim();
    if (!val) return;

    let messageText = val;
    let finalType = 'normal';

    const lower = val.toLowerCase();

    if (lower.startsWith('/ooc '))        { messageText = val.substring(5); finalType = 'ooc'; }
    else if (lower.startsWith('/me '))    { messageText = val.substring(4); finalType = 'me'; }
    else if (lower.startsWith('/do '))    { messageText = val.substring(4); finalType = 'do'; }
    else if (lower.startsWith('/ad '))    { messageText = val.substring(4); finalType = 'system'; }
    else if (lower.startsWith('/tweet ')) { messageText = val.substring(7); finalType = 'twitter'; }
    else if (lower.startsWith('/911 '))   { messageText = val.substring(5); finalType = 'radio-police'; }
    else if (lower.startsWith('/ems '))   { messageText = val.substring(5); finalType = 'radio-ems'; }
    else if (lower.startsWith('/mec '))   { messageText = val.substring(5); finalType = 'radio-mechanic'; }
    else if (val.startsWith('/')) {
        // Enviar como comando nativo do FiveM (ex: /giveitem, /tp, /kick, etc.)
        post('executeCommand', { command: val.substring(1) });
        chatInput.value = '';
        currentType = 'normal';
        updatePrefix();
        updateProgress();
        sendBtn.disabled = true;
        hideSuggestions();
        return;
    }

    // Send to Lua
    post('sendMessage', {
        message: messageText,
        type: finalType,
    });

    chatInput.value = '';
    currentType = 'normal';
    updatePrefix();
    updateProgress();
    sendBtn.disabled = true;
    hideSuggestions();
});

// ESC key to close
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && isActive) {
        post('close');
    }
    // Backspace com input vazio fecha o chat
    if (e.key === 'Backspace' && isActive && chatInput.value === '') {
        post('close');
    }
});

// ============ PREFIX INDICATOR ============

function updatePrefix() {
    const val = chatInput.value.toLowerCase();
    let prefix = null;

    if (val.startsWith('/ooc'))        prefix = { text: '/ooc',   color: '#42A5F5', bg: 'rgba(33, 150, 243, 0.1)' };
    else if (val.startsWith('/me'))    prefix = { text: '/me',    color: '#BA68C8', bg: 'rgba(186, 104, 200, 0.1)' };
    else if (val.startsWith('/do'))    prefix = { text: '/do',    color: '#66BB6A', bg: 'rgba(102, 187, 106, 0.1)' };
    else if (val.startsWith('/ad'))    prefix = { text: '/ad',    color: '#C5FF00', bg: 'rgba(197, 255, 0, 0.1)' };
    else if (val.startsWith('/tweet')) prefix = { text: '/tweet', color: '#1DA1F2', bg: 'rgba(29, 161, 242, 0.1)' };
    else if (val.startsWith('/911'))   prefix = { text: '/911',   color: '#4A90D9', bg: 'rgba(74, 144, 217, 0.1)' };
    else if (val.startsWith('/ems'))   prefix = { text: '/ems',   color: '#FF6B6B', bg: 'rgba(255, 107, 107, 0.1)' };
    else if (val.startsWith('/mec'))   prefix = { text: '/mec',   color: '#FFA500', bg: 'rgba(255, 165, 0, 0.1)' };

    if (prefix) {
        commandPrefix.textContent = prefix.text;
        commandPrefix.style.background = prefix.bg;
        commandPrefix.style.color = prefix.color;
        commandPrefix.style.display = '';
    } else {
        commandPrefix.style.display = 'none';
    }
}

// ============ PROGRESS BAR ============

function updateProgress() {
    const len = chatInput.value.length;
    const percent = (len / maxLength) * 100;

    inputProgress.style.width = percent + '%';
    inputProgress.style.opacity = len > 0 ? '0.6' : '0';

    inputProgress.className = 'input-progress';
    if (percent > 90) inputProgress.classList.add('danger');
    else if (percent > 70) inputProgress.classList.add('warning');

    charCount.textContent = len + '/' + maxLength;
    charCount.className = percent > 90 ? 'danger' : '';
}

// ============ COMMAND SUGGESTIONS ============

const defaultCommands = [
    // RP
    { command: '/ooc',   description: 'Mensagem fora do personagem', icon: '💬', color: '#42A5F5' },
    { command: '/me',    description: 'Descrever uma ação',          icon: '🎭', color: '#BA68C8' },
    { command: '/do',    description: 'Descrever o ambiente/situação', icon: '📝', color: '#66BB6A' },
    { command: '/ad',    description: 'Anúncio público',             icon: '📢', color: '#C5FF00' },
    { command: '/tweet', description: 'Publicar no Twitter',         icon: '🐦', color: '#1DA1F2' },
    { command: '/911',   description: 'Chamar a polícia',            icon: '🚔', color: '#4A90D9' },
    { command: '/ems',   description: 'Chamar paramédicos',          icon: '🚑', color: '#FF6B6B' },
    { command: '/mec',   description: 'Chamar mecânico',             icon: '🔧', color: '#FFA500' },
    { command: '/duty',  description: 'Entrar/sair de serviço',      icon: '👔', color: '#2ECC71' },
    // Admin
    { command: '/announce',       description: 'Anúncio do sistema (admin)',       icon: '📣', color: '#FF5555' },
    { command: '/clearchat',      description: 'Limpar chat (admin)',              icon: '🧹', color: '#FF5555' },
    { command: '/giveitem',       description: 'Dar item [id] [item] [qtd]',      icon: '🎁', color: '#FF5555' },
    { command: '/givemoney',      description: 'Dar dinheiro [id] [tipo] [qtd]',  icon: '💰', color: '#FF5555' },
    { command: '/removemoney',    description: 'Remover dinheiro [id] [tipo] [qtd]', icon: '💸', color: '#FF5555' },
    { command: '/setjob',         description: 'Definir emprego [id] [job] [grau]', icon: '💼', color: '#FF5555' },
    { command: '/setgang',        description: 'Definir gang [id] [gang] [grau]',  icon: '🔫', color: '#FF5555' },
    { command: '/setgroup',       description: 'Definir grupo [id] [grupo]',       icon: '👑', color: '#FF5555' },
    { command: '/tp',             description: 'Teleportar para jogador [id]',     icon: '⚡', color: '#FF5555' },
    { command: '/bring',          description: 'Trazer jogador [id]',              icon: '🧲', color: '#FF5555' },
    { command: '/revive',         description: 'Reviver jogador [id]',             icon: '❤️', color: '#FF5555' },
    { command: '/heal',           description: 'Curar jogador [id]',               icon: '💊', color: '#FF5555' },
    { command: '/kick',           description: 'Expulsar jogador [id] [motivo]',   icon: '🚫', color: '#FF5555' },
    { command: '/ban',            description: 'Banir jogador [id] [motivo]',      icon: '⛔', color: '#FF5555' },
    { command: '/addcar',         description: 'Adicionar veículo [id] [modelo]',  icon: '🚗', color: '#FF5555' },
    { command: '/delveh',         description: 'Apagar veículo [placa]',           icon: '🗑️', color: '#FF5555' },
    { command: '/garageadmin',    description: 'Painel admin garagem',             icon: '🏗️', color: '#FF5555' },
    { command: '/clearinventory', description: 'Limpar inventário [id]',           icon: '🧹', color: '#FF5555' },
    { command: '/logout',         description: 'Forçar logout jogador',            icon: '🚪', color: '#FF5555' },
];

function updateSuggestions() {
    const val = chatInput.value;

    if (!val.startsWith('/') || val.length < 2) {
        hideSuggestions();
        return;
    }

    const cmds = commands.length > 0 ? commands : defaultCommands;
    const filtered = cmds.filter(c =>
        c.command.toLowerCase().startsWith(val.toLowerCase()) ||
        c.description.toLowerCase().includes(val.toLowerCase().substring(1))
    );

    if (filtered.length === 0) {
        hideSuggestions();
        return;
    }

    suggestionsDropdown.innerHTML = filtered.map(c => `
        <button class="suggestion-item" data-cmd="${c.command}">
            <span class="suggestion-icon">${c.icon}</span>
            <div class="suggestion-info">
                <div class="suggestion-cmd" style="color:${c.color}">${c.command}</div>
                <div class="suggestion-desc">${c.description}</div>
            </div>
            <span class="suggestion-enter">Enter</span>
        </button>
    `).join('');

    suggestionsDropdown.style.display = '';

    // Add click handlers
    suggestionsDropdown.querySelectorAll('.suggestion-item').forEach(item => {
        item.addEventListener('click', () => {
            chatInput.value = item.dataset.cmd + ' ';
            chatInput.focus();
            updatePrefix();
            updateProgress();
            hideSuggestions();
        });
    });
}

function hideSuggestions() {
    suggestionsDropdown.style.display = 'none';
    suggestionsDropdown.innerHTML = '';
}

// ============ INIT ============

// Start in inactive/hidden state
chatContainer.className = 'chat-container hidden';
