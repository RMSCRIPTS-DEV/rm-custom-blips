fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'rm-custom-blips'
author 'raymans'
description 'Custom map blip icons + in-game blip editor (/blips)'
version '1.0.0'

shared_script '@ox_lib/init.lua'

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

files {
    'config.lua',
    'html/sheet.html',
    'sheets/*.png',
    'blips/*.png',
}

dependencies {
    'ox_lib',
    'oxmysql',
}
