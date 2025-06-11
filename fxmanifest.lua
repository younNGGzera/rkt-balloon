fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'
author 'RKT SCRIPTS'

client_scripts {
	"client/*.lua",
}

server_scripts {
	"server/server.lua",
	'@oxmysql/lib/MySQL.lua',
}

ui_page 'web/index.html'

files {
    'web/*',
    'locales/*.json',
}

shared_scripts {'@jo_libs/init.lua', '@ox_lib/init.lua','shared/*.lua'}

jo_libs {
	'prompt',
}
