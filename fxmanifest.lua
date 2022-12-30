fx_version "adamant"
game "gta5"
description "horizon-core"

files {
    "require/extended/exports.lua",
}

shared_scripts {
    "config.lua",

    -- Extended
    "require/extended/config.lua",
    "require/extended/locale.lua",
	"require/extended/locales/fr.lua",
	"require/extended/config.weapons.lua",

    -- Autres
    "fct-horizon/shared.lua",

    -- Métier
    "modules/job/notwl/concess/shared.lua",

    -- Métier Whitelist
    "modules/job/wl/burgershot/shared/config.lua",
    -- "modules/job/wl/agentimmo/shared.lua",

    -- Gestionnaire du Joueur
    "modules/gestion/banque/shared/config.lua",
    "modules/gestion/crew/shared/shared.lua",
    "modules/gestion/utilsCar/statCar/shared.lua",
    "modules/gestion/utilsCar/garage/shared.lua",
    "modules/gestion/utilsCar/trunk/shared.lua",
    
    -- Boutique
    "modules/shop/market/shared/config.lua",

}

--[[ 
    Pour exporter mysql mettre ca dans le fxmanifest.lua: 
        @Horizon/require/mysql/lib/MySQL.lua
        @Horizon/require/extended/exports.lua
        @Horizon/require/extended/locale.lua
]]

server_scripts {
    -- Es Extended
    -- "require/mysql/mysql-async.js",
    -- "require/mysql/lib/MySQL.lua",

    "@mysql-async/lib/MySQL.lua",


    "require/extended/server/common.lua",
	"require/extended/server/classes/player.lua",
	"require/extended/server/functions.lua",
	"require/extended/server/paycheck.lua",
	"require/extended/server/main.lua",
	"require/extended/server/commands.lua",

	"require/extended/common/modules/math.lua",
	"require/extended/common/modules/table.lua",
	"require/extended/common/functions.lua",
    "require/extended/imports.lua",

    -- others
    "fct-horizon/server.lua",


    "modules/player/server/skin.lua",

    -- Métier
    "modules/job/notwl/concess/server.lua",
    
    -- Métier Whitelist
    "modules/job/wl/burgershot/server/server.lua",
    -- "modules/job/wl/agentimmo/server.lua",

    -- Gestionnaire du Joueur
    "modules/gestion/banque/server/server.lua",

    "modules/gestion/crew/server/server.lua",

    "modules/gestion/utilsCar/statCar/server.lua",
    "modules/gestion/utilsCar/keyCarSysteme/server.lua",
    "modules/gestion/utilsCar/garage/server.lua",
    "modules/gestion/utilsCar/trunk/server.lua",

    "modules/gestion/menuF5/server.lua",
    "modules/gestion/banSysteme/server.lua",

    -- Boutique
    "modules/shop/market/server/server.lua",

}

client_scripts {
    -- Es Extended
    "modules/player/client/skin.lua",

	"require/extended/client/common.lua",
	"require/extended/client/entityiter.lua",
	"require/extended/client/functions.lua",
	"require/extended/client/wrapper.lua",
	"require/extended/client/main.lua",

	"require/extended/client/modules/death.lua",
	"require/extended/client/modules/scaleform.lua",
	"require/extended/client/modules/streaming.lua",

	"require/extended/common/modules/math.lua",
	"require/extended/common/modules/table.lua",
	"require/extended/common/functions.lua",
    "require/extended/imports.lua",

    "require/RageUI/RMenu.lua",
    "require/RageUI/menu/RageUI.lua",
    "require/RageUI/menu/Menu.lua",
    "require/RageUI/menu/MenuController.lua",
    "require/RageUI/components/*.lua",
    "require/RageUI/menu/elements/*.lua",
    "require/RageUI/menu/items/*.lua",
    "require/RageUI/menu/panels/*.lua",
    "require/RageUI/menu/windows/*.lua",

    "fct-horizon/client.lua",

    -- Métier
    "modules/job/notwl/concess/client.lua",
    
    -- Métier Whitelist
    "modules/job/wl/burgershot/client/client.lua",
    -- "modules/job/wl/agentimmo/client.lua",

    -- Gestionnaire du Joueur
    "modules/gestion/banque/client/client.lua",
    "modules/gestion/crew/client/client.lua",
    "modules/gestion/utilsCar/statCar/client.lua",
    "modules/gestion/utilsCar/keyCarSysteme/client.lua",
    "modules/gestion/utilsCar/garage/client.lua",
    "modules/gestion/utilsCar/trunk/client.lua",

    "modules/gestion/menuF5/client.lua",

    "modules/gestion/banSysteme/client.lua",

    -- Boutique
    "modules/shop/market/client/client.lua",

    -- Utilitaire
    "modules/utils/richPresence/RichPresence.lua",
}

export "getSharedObject"

server_exports {
    "getSharedObject"
}