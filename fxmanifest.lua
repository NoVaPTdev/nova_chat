fx_version 'cerulean'
game 'gta5'

name 'nova_chat'
description 'NOVA Framework - Chat System'
author 'NOVA Framework'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
}

dependencies {
    'nova_core',
    'oxmysql',
}
