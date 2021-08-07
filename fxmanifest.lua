fx_version "adamant"
games {'gta5'}


client_scripts {
	'client/*.lua'
}
files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    '/html/img/*.webp',
    '/html/img/*.png',
}

ui_page 'html/index.html'
server_scripts {
    '@vrp/lib/utils.lua',
    '@vrp/lib/Tools.lua',
	"server.lua"
}














