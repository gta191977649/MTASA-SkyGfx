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
textureListTable.VehiclePSApplyList = {
    "predator92body128", "monsterb92body256a", "monstera92body256a", "andromeda92wing","fcr90092body128",
    "hotknifebody128b", "hotknifebody128a", "rcbaron92texpage64", "rcgoblin92texpage128", "rcraider92texpage128", 
    "rctiger92body128","rhino92texpage256", "petrotr92interior128","artict1logos","rumpo92adverts256","dash92interior128",
    "coach92interior128","combinetexpage128","hotdog92body256",
    "raindance92body128", "cargobob92body256", "andromeda92body", "at400_92_256", "nevada92body256",
    "polmavbody128a" , "sparrow92body128" , "hunterbody8bit256a" , "seasparrow92floats64" , 
    "dodo92body8bit256" , "cropdustbody256", "beagle256", "hydrabody256", "rustler92body256", 
    "shamalbody256", "skimmer92body128", "stunt256", "maverick92body128", "leviathnbody8bit256",
    "vehiclegrunge256","?emap*"
}

SKYGFX = {
    ps2Modulate=true,
    dualPass=true,
    zwriteThreshold=128,
    -- postfx
    colorFilter = "PS2", -- values: "PS2", "PC", "Mobile", (needs colorcycle.dat), "None"
    blurLeft = 0.0008, -- Override PS2 color filter blur offset 
    blurTop = 0.0008, -- to disable blur set these to 0
    blurRight = 0.0008,
    blurBottom = 0.0008,
    doRadiosity=true,-- Enable or disable radiosity
    radiosityFilterPasses=2,
    radiosityRenderPasses=1,
    radiosityIntensity=35,
    radiosityIntensityLimit=220,
    usePCTimecyc = false,
    RSPIPE_PC_CustomBuilding_PipeID = true,
    fogDisabled = false,
    brightnessMul = 1,
    -- grass
    grassAddAmbient=false, --0x5DAEC8, need fuck the memory, not fully done.
    --grassFixPlacement=true, 0x5DADB7, need fuck the memory
    grassBackfaceCull=true,
    vehiclePipe= "PS2", -- values: "PS2", "PC", "Xbox", "Spec" (like PS2 but with specular lighting), "Neo" (like III/VC Xbox), "LCS", "VCS", "Mobile", "Env"

}
w, h = guiGetScreenSize()