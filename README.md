# nova_chat

Sistema de chat do NOVA Framework: mensagens de proximidade, comandos RP (/me, /do, /ooc, /ad), canais de rádio (/911, /ems, /mec) e comandos de administração.

## Dependências

- **nova_core** (obrigatório)
- **oxmysql**

## Instalação

1. Coloca a pasta `nova_chat` em `resources/[nova]/`.
2. No `server.cfg`:

```cfg
ensure nova_core
ensure oxmysql
ensure nova_chat
```

## Configuração

Em `config.lua` definem-se a tecla de abrir chat, comandos RP, departamentos de rádio, permissões de anúncio e cores.

## Estrutura

- `client/main.lua` — UI e input
- `server/main.lua` — processamento de comandos e rádios
- `config.lua` — configuração
- `html/` — interface (index, css, js)

## Documentação

[NOVA Framework Docs](https://github.com/NoVaPTdev) — guia Chat.

## Licença

Parte do ecossistema NOVA Framework.
