TIMECYC = exports.timecyc

-- SA Timecyc.dat mapping
T = {
    ambR =1 , ambG =2 , ambB =3,
    ambR_obj =4 , ambG_obj =5 , ambB_obj =6,
    dirR =7, dirG =8, dirB =9,
    skyTopR = 10, skyTopG =11, skyTopB =12,
    skyBotR = 13, skyBotG =14, skyBotB =15,
    sunCoreR = 16, sunCoreG =17, sunCoreB =18,
    sunCoronaR = 19, sunCoronaG =20, sunCoronaB =21,
    sunSz = 22, sprSz =23, sprBght =24,
    shad = 25, lightShad =26, poleShad =27,
    farClp = 28, fogSt =29, lightGnd =30,
    cloudR = 31, cloudG =32, cloudB =33,
    fluffyBotR =34, fluffyBotG =35, fluffyBotB =36,
    waterR = 37,waterG =38, waterB=39, waterA=40,
    postfx1A =41, postfx1R =42, postfx1G = 43, postfx1B = 44,
    postfx2A =45, postfx2R = 46, postfx2G =47, postfx2B = 48,
    cloudAlpha = 49, radiosityLimit = 50, waterFogAlpha = 51, dirMult = 52
}

textureListTable = { }

textureListTable.BuildingPSRemoveList = {
    "",	"unnamed", "fire*",                                    -- unnamed
    "basketball2","skybox_tex*",                               -- other
    "font*","radar*","sitem16","snipercrosshair",              -- hud
    "siterocket","cameracrosshair",                            -- hud
    "*shad*",                                                  -- shadows
    "coronastar","coronamoon","coronaringa",
    "coronaheadlightline",                                     -- coronas
    "lunar",                                                   -- moon
    "tx*",                                                     -- grass effect
    "cj_w_grad",                                               -- checkpoint texture
    "*cloud*",                                                 -- clouds
    "*smoke*",                                                 -- smoke
    "sphere_cj",                                               -- nitro heat haze mask
    "water*","newaterfal1_256",
    "boatwake*","splash_up","carsplash_*",
    "fist","*icon","headlight*",
    "unnamed","sphere","plaintarmac*",
    "vehiclegrunge256","?emap*","vehiclegeneric*",
    "gensplash"
}


SKYGFX = {
    ps2Modulate=false,
    dualPass=true,
    zwriteThreshold=128,
    -- postfx
    radiosityFilterPasses=2,
    radiosityRenderPasses=1,
    radiosityIntensity=35,
    radiosityIntensityLimit=220,
    usePCTimecyc = false,
    RSPIPE_PC_CustomBuilding_PipeID = true,
    fogDisabled = false,
    brightnessMul = 1.2,
}
w, h = guiGetScreenSize()