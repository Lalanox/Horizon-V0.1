BurgerShotConfig = {
    BossMenu = 'F6',
    Time = {
        craftBurger = 10000,
        craftFrite = 10000,
    },

    Point = {
        CraftBurger = vector3(-1199.8, -900.6, 13),
        CraftFrite = vector3(-1201.6, -897.8, 13),
        clothePoint = vector3(-1204.5, -892.1, 13),
        carPoint = vector3(-1192.1, -898, 13),
        carSpawnPoint = vector3(-1170.2, -892.2, 13.9),
        deleteCarSpawn = vector3(-1170.8, -895.6, 13),
        shopItems  = vector3(841, -1924.6, 29.3)
    },

    Burger = {                      --- Craft de Burger / les ingrédiants qu'il faut et leurs quantité
        ['giant'] = {
            ['steak'] = 2,
            ['mayonnaise'] = 3,
            ['pain'] = 2,
            ['salade'] = 1,
        },

        ['wooper'] = {
            ['steak'] = 2,
            ['mayonnaise'] = 1,
            ['ketchup'] = 2,
            ['pain'] = 2,
            ['salade'] = 1,
        },

    },

    Frites = {                         --- Craft de Frite / les ingrédiants qu'il faut et leurs quantité

        ['frite'] = {
            ['patate'] = 2,
            ['sel'] = 1,
        },

        ['frite-bacon'] = {
            ['patate'] = 2,
            ['bacon'] = 2,
            ['sel'] = 1,
        }, 
    },

    UtilisableItem = {                 ----Les items comestible et le nom que ça donc quand on les mange(nom / faim)
        ['steak']= 10000,
        ['mayonnaise'] = 20000,
        ['pain']= 5000,
        ['salade'] = 5000 ,
        ['ketchup']= 5000,
        ['patate']= 5000,
        ['sel']= 5000,
        ['bacon']= 5000,
        ['giant'] = 5000,
        ['wooper'] = 10000,
        ['frite'] = 7500,
        ['frite-Bacon'] = 7500
    },

    ItemsToBuy = {                      ---Items dans le shop (nom / prix)
        ['steak'] = { price = 10, index = 1},
        ['mayonnaise'] = { price = 10, index = 1},
        ['pain'] = { price = 10, index = 1},
        ['salade'] = { price = 10, index = 1},
        ['ketchup'] = { price = 10, index = 1},
        ['patate'] = { price = 10, index = 1},
        ['sel'] = { price = 10, index = 1},
        ['bacon'] = { price = 10, index = 1},
    },

    Tenues = {
        Male = {
            ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
            ['torso_1'] = 281,   ['torso_2'] = 1,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 4,
            ['pants_1'] = 52,   ['pants_2'] = 2,
            ['shoes_1'] = 1,   ['shoes_2'] = 10,
            ['chain_1'] = 0,  ['chain_2'] = 0
        },
        Female = {
            ['tshirt_1'] = 2,   ['tshirt_2'] = 0,
            ['torso_1'] = 294,    ['torso_2'] = 2,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 1,
            ['pants_1'] = 54,   ['pants_2'] = 1,
            ['shoes_1'] = 4,    ['shoes_2'] = 3,
            ['chain_1'] = 0,    ['chain_2'] = 0
        },
    },
}



