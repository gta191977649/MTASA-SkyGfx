TIMECYC = exports.timecyc
COR = exports.custom_coronas

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
    "gensplash","cj_*","pinebranch*","cheerybox03_weights",
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

textureListTable.txddb = {}

SKYGFX = {
    -- start by default
    autoStart = true,
    -- vehicle
    vehiclePipe= "PS2", -- values: "PS2", "PC", "Xbox", "Spec" (like PS2 but with specular lighting), "Neo" (like III/VC Xbox), "LCS", "VCS", "Mobile", "Env"
    envPower=1.0, --Env specular light power (the higher the smaller the highlight)
    -- postfx
    colorFilter = "PS2", -- values: "PS2", "PC", "Mobile", (needs colorcycle.dat), "None"
    blurLeft = 0.0004, -- Override PS2 color filter blur offset 
    blurTop = 0.0004, -- to disable blur set these to 0
    blurRight = 0.0004,
    blurBottom = 0.0004,
    doRadiosity=true,-- Enable or disable radiosity
    radiosityFilterPasses=2,
    radiosityRenderPasses=1,
    radiosityIntensity=35,
    radiosityIntensityLimit=0, -- use to override the intensity limit, 0 for use the value from timecyc (by default)
    usePCTimecyc = false,
    RSPIPE_PC_CustomBuilding_PipeID = true,
    fogDisabled = false,
    buildingExtraBrightness = 1,
    vehicleExtraBrightness = 1,

    -- grass
    grassAddAmbient=false, --0x5DAEC8, need fuck the memory, not fully done.
    --grassFixPlacement=true, 0x5DADB7, need fuck the memory
    grassBackfaceCull=true,
    -- world fx
    ps2Modulate=true,
    dualPass=true,
    zwriteThreshold=128,
    disableZTest = true, -- if you want ps2 big sun lens
    sunZTestLength = 3000, -- sun ztest length
    -- misc
    sunGlare = true, -- this adds the vehicle sun glares like in vice city.
    -- Modify final colors in YCbCr space
    YCbCrCorrection=0,	-- turns this on or off (default 0)
    lumaScale=0.8588,	-- multiplier for Y (default 0.8588)
    lumaOffset=0.0627,	-- this is added to Y (default 0.0627)
    CbScale=1.22,		-- like above with Cb and Cr (default 1.22)
    CbOffset=0.0,		-- (default 0.0)
    CrScale=1.22,		-- (default 1.22)
    CrOffset=0.0,		-- (default 0.0)
    -- Heli Rotor Fix
    fixRotor = true, -- fix the helicopter rotor blur texture like in ps2
    rotorMaxAlpha = 120, -- max alpha for rotor
    -- special
    vehicleClassicFx = true, -- show vc/iii liked vehicle big headlight
    vehicleTrailLength = 6, -- length of buffered frame
    vehicleTrailDrawDist = 20,
    vehicleHeadLightAlpha = 255,
    vehicleRearLightAlpha = 120, 
    trashOnGround = true, -- toogle vc/iii like trash on ground
    num_rubbish_sheets = 64,
    rubbish_max_dist = 23,
    rubbish_fade_dist = 20,
    stochastic = false, 
    stochasticDist = 0,
   
}
w, h = guiGetScreenSize()

function getPropertyFromVars(vars,property) 
    for i,v in ipairs(vars) do
        local p = split(v,"=")
        if #p == 2 then 
            if p[1] == property then 
                return tonumber(p[2])
            end
        end
    end
    return nil
end
function loadtxdDB() 
    local f = fileOpen("models/texdb.txt",true)
    local str = fileRead(f,fileGetSize(f))
    fileClose(f)
    Lines = split(str,'\n' )
	local count = 0
    for i=1,#Lines do
        if not string.find(string.gsub(Lines[i], "\r", ""),"cat=") then 
            local p = split(string.gsub(Lines[i], "\r", "")," ")
	        local model = string.gsub(p[1], "\"", "")
            textureListTable.txddb[model] = {
                stochastic = getPropertyFromVars(p,"stochastic"),
                alphamode = getPropertyFromVars(p,"alphamode"),
                isdetail = getPropertyFromVars(p,"isdetail"),
                hasdetail = getPropertyFromVars(p,"hasdetail"),
                dualPass = getPropertyFromVars(p,"dualPass"),
                zwriteThreshold = getPropertyFromVars(p,"zwriteThreshold"),
                affiliate = getPropertyFromVars(p,"affiliate"),
                detailtile = getPropertyFromVars(p,"detailtile"),
            }
            --[[
            if textureListTable.txddb[model].zwriteThreshold then 
                iprint(textureListTable.txddb[model])
            end
            --]]
        end
	end
    
end