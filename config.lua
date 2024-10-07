Config = {}

Config.Business = {
    ["hogspub"]={
        npc = {
            pos = vec3(-582.46, -295.08, 35.09),
            heading = 198.64,
        },
        items = {
            ['ngd_standardcigpack'] = {price=60},
            ['ngd_stdcigarbox'] = {price=60},
        },
        minPerDelivery = 4,
        maxPerDelivery = 11,
        additionalDeliveryReward = {min=50,max=100},
        negativeTips = -20, -- When player refuse additional event
        positiveTips = 60 -- When player done additional delivery
    },
}

Config.Locations = {
    vec4(257.61, -380.57, 44.71, 340.5),
    vec4(-48.58, -790.12, 44.22, 340.5),
    vec4(240.06, -862.77, 29.73, 341.5),
    vec4(826.0, -1885.26, 29.32, 81.5),
    vec4(350.84, -1974.13, 24.52, 318.5),
    vec4(-229.11, -2043.16, 27.75, 233.5),
    vec4(-1053.23, -2716.2, 13.75, 329.5),
    vec4(-774.04, -1277.25, 5.15, 171.5),
    vec4(-1184.3, -1304.16, 5.24, 293.5),
    vec4(-1321.28, -833.8, 16.95, 140.5),
    vec4(-1613.99, -1015.82, 13.12, 342.5),
    vec4(-1392.74, -584.91, 30.24, 32.5),
    vec4(-515.19, -260.29, 35.53, 201.5),
    vec4(-760.84, -34.35, 37.83, 208.5),
    vec4(-1284.06, 297.52, 64.93, 148.5),
    vec4(-808.29, 828.88, 202.89, 200.5),
}