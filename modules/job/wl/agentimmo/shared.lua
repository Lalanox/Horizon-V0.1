AgentImmmo = {
    InterieurAgence = vector3(-141, -616.8, 168.8),
    ExterieurAgence = vector3(-114.5, -603.3, 36.3),

    InputMenuHouse = 'F5',

    Possibility = {
        ['Maison'] = {

        },
        ['Appartement'] = {
            {
                name = 'Appartement N°1',
                tp = vector3(266.04, -1007.172, -101.00),
                coffre = 100,
                img = 'apart1',
                posImg = {
                    x = 500,
                    y = 500,
                },
            },
            {
                name = 'Appartement N°2',
                tp = vector3(346.43, -1012.777, -99.19),
                coffre = 150,
                img = 'apart2',
                posImg = {
                    x = 500,
                    y = 500,
                },
            },
            -- {
            --     name = 'Appartement N°3',
            --     tp = vector3(-107.86, -8.17, 70.151),
            --     coffre = 200,
            -- },
            {
                name = 'Appartement N°4',
                tp = vector3(151.43, -1007.70, -99.0),
                coffre = 250,
                img = 'apart3',
                posImg = {
                    x = 500,
                    y = 500,
                },
            }
        },
        ['Hangar'] = {
            -- {
            --     name = 'Stockage N°1',
            --     tp = vector3(242.35, 361.63, 105.73),
            -- },
            {
                name = 'Hangar N°1 (Petit)',
                tp = vector3(1087.78, -3099.38, -39.0),
                coffre = 500,
                img = 'Capture',
                posImg = {
                    x = 200,
                    y = 200,
                },
            },
            {
                name = 'Hangar N°1 (Moyen)',
                tp = vector3(1048.37, -3097.115, -38.99),
                coffre = 750,
                img = 'Capture2',
                posImg = {
                    x = 200,
                    y = 200,
                },
            },
            {
                name = 'Hangar N°1 (Grand)',
                tp = vector3(992.82, -3097.74, -38.99),
                coffre = 1000,
                img = 'Capture3',
                posImg = {
                    x = 200,
                    y = 200,
                },
            },
        }
    },

    ExitPose = {
        vector3(266.04, -1007.172, -101.00),
        vector3(346.43, -1012.777, -99.19),
        -- vector3(-107.86, -8.17, 70.151),
        vector3(151.5, -1007.5, -99.0),
        vector3(1087.78, -3099.38, -39.0),
        vector3(1048.37, -3097.115, -38.99),
        vector3(992.82, -3097.74, -38.99),
    }
}