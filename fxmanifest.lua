fx_version "cerulean"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'RDX Inventory HUD'

version '1.1'

ui_page 'html/ui.html'

client_scripts {
  '@rdx_core/locale.lua',
  'client/main.lua',
  'config.lua'	
}

files {
    'html/ui.html',
    'html/css/contextMenu.min.css',
    'html/css/jquery.dialog.min.css',
    'html/css/ui.min.css',
    'html/js/config.js',
    'html/js/contextMenu.min.js',
    'html/js/jquery.dialog.min.js',
    'html/locales/cs.js',
    'html/locales/en.js',
    'html/locales/fr.js',
    'html/fonts/osifont.ttf',
    -- ICONS
    'html/img/items/*.png'
}