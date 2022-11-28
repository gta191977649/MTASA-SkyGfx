local getWeatherSA = getWeather
local setWeatherSA = setWeather
Timecyc = {}
Weather = {
    interpolationLength = 1, -- 1 hour
    interpolateStart = 0,
    numHours = 24,-- for vcs timecyc.dat 
    old = getWeatherSA(),
    new = getWeatherSA(),
    interpolation = 1,
    data ={},
}
-- VCS Timecyc.dat mapping
T = {
    ambR = 1, ambG = 2, ambB = 3,
    ambR_obj = 4, ambG_obj = 5, ambB_obj = 6,
    ambR_bl = 7, ambG_bl = 8, ambB_bl = 9,
    ambR_obj_bl = 10, ambG_obj_bl = 11, ambB_obj_bl = 12,
    dirR = 13, dirG = 14, dirB = 15,
    skyTopR = 16, skyTopG = 17, skyTopB = 18,
    skyBotR = 19, skyBotG = 20, skyBotB = 21,
    sunCoreR = 22, sunCoreG = 23, sunCoreB = 24,
    sunCoronaR = 25, sunCoronaG = 26, sunCoronaB = 27,
    sunSz = 28, sprSz = 29, sprBght = 30,
    shad = 31, lightShad = 32, poleShad = 33,
    farClp = 34, fogSt = 35, radiosityIntensity = 36, radiosityLimit = 37, lightGnd = 38,
    cloudR = 39, cloudG = 40, cloudB = 41,
    fluffyTopR = 42, fluffyTopG = 43, fluffyTopB = 44,
    fluffyBotR = 45, fluffyBotG = 46, fluffyBotB = 47,
    blurR = 48, blurG = 49, blurB = 50,
    waterR = 51, waterG = 52, waterB = 53, waterA = 54,
    blurAlpha = 55, blurOffset = 56,
}

function loadTimeCycle(filename) 
    local f = fileOpen(filename)
    local lines = fileRead(f,fileGetSize(f))
    lines = split(lines:gsub("\r",""),'\n')
    fileClose(f)
    local weather_id = 0
    for i=1,#lines do 
        if string.find(lines[i],"///////////////////////////////////////////") then
            weather_id = weather_id + 1
        end
        if lines[i]:sub(1, 1) ~= '/' and lines[i]:sub(2, 1) ~= '/' then
            local data = split(lines[i]:gsub("\t"," ")," ")
            if Timecyc[weather_id] == nil then
                Timecyc[weather_id] = {}
            end
            table.insert(Timecyc[weather_id],data)
            --iprint(data)
        end 
    end
    print("Total: ",weather_id)
end
-- timecyc interpolation shits from here
-- shits port from aap's euryopa.exe
function interpolateValue(a,b,fa,fb) 
    return fa * a + fb * b
end

function interpolateRGB(a1,b1,fa,fb) 
    local r = fa * a1[1] + fb * b1[1]
    local g = fa * a1[2] + fb * b1[2]
    local b = fa * a1[3] + fb * b1[3]
    return {r,g,b}
end

function interpolateRGBA(a1,b1,fa,fb) 
    local r = fa * a1[1] + fb * b1[1]
    local g = fa * a1[2] + fb * b1[2]
    local b = fa * a1[3] + fb * b1[3]
    local a = fa * a1[4] + fb * b1[4]
    return {r,g,b,a}
end

function interpolate(a,b,fa,fb,isCurrent)
    isCurrent = isCurrent or false
    local weather = {}
    if not isCurrent then -- interpolate direct from timecyc data
        weather.amb = interpolateRGB({a[T["ambR"]],a[T["ambG"]],a[T["ambB"]]}, {b[T["ambR"]],b[T["ambG"]],b[T["ambB"]]}, fa, fb)
        weather.amb_obj = interpolateRGB({a[T["ambR_obj"]],a[T["ambG_obj"]],b[T["ambB_obj"]]},{b[T["ambR_obj"]],b[T["ambG_obj"]],b[T["ambB_obj"]]}, fa, fb)
        weather.sky_top = interpolateRGB({a[T["skyTopR"]],a[T["skyTopG"]],a[T["skyTopB"]]}, {b[T["skyTopR"]],b[T["skyTopG"]],b[T["skyTopB"]]}, fa, fb)
        weather.sky_bot = interpolateRGB({a[T["skyBotR"]],a[T["skyBotG"]],a[T["skyBotB"]]}, {b[T["skyBotR"]],b[T["skyBotG"]],b[T["skyBotB"]]}, fa, fb)
        weather.sun_core = interpolateRGB({a[T["sunCoreR"]],a[T["sunCoreG"]],a[T["sunCoreB"]]}, {b[T["sunCoreR"]],b[T["sunCoreG"]],b[T["sunCoreB"]]}, fa, fb)
        weather.sun_corona = interpolateRGB({a[T["sunCoronaR"]],a[T["sunCoronaG"]],a[T["sunCoronaB"]]}, {b[T["sunCoronaR"]],b[T["sunCoronaG"]],b[T["sunCoronaB"]]}, fa, fb)
        weather.sun_size = interpolateValue(a[T["sunSz"]], b[T["sunSz"]], fa, fb)
        weather.postfx1 =  interpolateRGBA({a[T["fluffyTopR"]],a[T["fluffyTopG"]],a[T["fluffyTopB"]],a[T["blurAlpha"]]}, {b[T["fluffyTopR"]],b[T["fluffyTopG"]],b[T["fluffyTopB"]],b[T["blurAlpha"]]}, fa, fb)
        weather.postfx2 = interpolateRGBA({a[T["fluffyBotR"]],a[T["fluffyBotG"]],a[T["fluffyBotB"]],a[T["blurAlpha"]]}, {b[T["fluffyBotR"]],b[T["fluffyBotG"]],b[T["fluffyBotB"]],b[T["blurAlpha"]]}, fa, fb)
        --weather.dirMult = interpolateValue(a[T["lightShad"]],b[T["lightShad"]],fa,fb)
        weather.dirMult = 1
        weather.fogSt = interpolateValue(a[T["fogSt"]],b[T["fogSt"]],fa,fb)
        weather.farClp = interpolateValue(a[T["farClp"]],b[T["farClp"]],fa,fb)
        weather.radiosityLimit = interpolateValue(a[T["radiosityLimit"]],b[T["radiosityLimit"]],fa,fb)
        weather.radiosityIntensity = interpolateValue(a[T["radiosityIntensity"]],b[T["radiosityIntensity"]],fa,fb)

    else -- interpolate from exiting
        weather.amb = interpolateRGB(a.amb, b.amb, fa, fb)
        weather.amb_obj = interpolateRGB(a.amb_obj, b.amb_obj, fa, fb)
        weather.sky_top = interpolateRGB(a.sky_top, b.sky_top, fa, fb)
        weather.sky_bot = interpolateRGB(a.sky_bot, b.sky_bot, fa, fb)
        weather.sun_core = interpolateRGB(a.sun_core, b.sun_core, fa, fb)
        weather.sun_corona = interpolateRGB(a.sun_corona, b.sun_corona, fa, fb)
        weather.sun_size = interpolateValue(a.sun_size, b.sun_size, fa, fb)
        weather.postfx1 = interpolateRGBA(a.postfx1, b.postfx1, fa, fb)
        weather.postfx2 = interpolateRGBA(a.postfx2, b.postfx2, fa, fb)
        --weather.dirMult = interpolateValue(a.dirMult, b.dirMult, fa,fb)
        weather.dirMult = 1
        weather.fogSt = interpolateValue(a.fogSt, b.fogSt, fa,fb)
        weather.farClp = interpolateValue(a.farClp, b.farClp, fa,fb)
        weather.radiosityLimit = interpolateValue(a.radiosityLimit, b.radiosityLimit, fa,fb)
        weather.radiosityIntensity = interpolateValue(a.radiosityIntensity, b.radiosityIntensity, fa,fb)
    end
    
    --[[
	dst->sprSz = fa * a->sprSz + fb * b->sprSz;
	dst->sprBght = fa * a->sprBght + fb * b->sprBght;
	dst->shdw = fa * a->shdw + fb * b->shdw;
	dst->lightShd = fa * a->lightShd + fb * b->lightShd;
	dst->poleShd = fa * a->poleShd + fb * b->poleShd;
	dst->farClp = fa * a->farClp + fb * b->farClp;
	dst->lightOnGround = fa * a->lightOnGround + fb * b->lightOnGround;
	Interpolate(&dst->lowCloud, &a->lowCloud, &b->lowCloud, fa, fb);
	Interpolate(&dst->fluffyCloudTop, &a->fluffyCloudTop, &b->fluffyCloudTop, fa, fb);
	Interpolate(&dst->fluffyCloudBottom, &a->fluffyCloudBottom, &b->fluffyCloudBottom, fa, fb);
	Interpolate(&dst->water, &a->water, &b->water, fa, fb);
	Interpolate(&dst->postfx1, &a->postfx1, &b->postfx1, fa, fb);
	Interpolate(&dst->postfx2, &a->postfx2, &b->postfx2, fa, fb);
	dst->cloudAlpha = fa * a->cloudAlpha + fb * b->cloudAlpha;
	dst->radiosityLimit = fa * a->radiosityLimit + fb * b->radiosityLimit;
	dst->radiosityIntensity = fa * a->radiosityIntensity + fb * b->radiosityIntensity;
	dst->waterFogAlpha = fa * a->waterFogAlpha + fb * b->waterFogAlpha;
	dst->dirMult = fa * a->dirMult + fb * b->dirMult;
	dst->lightMapIntensity = fa * a->lightMapIntensity + fb * b->lightMapIntensity;
    ]]
    return weather
end


function getColourSet(h,s) 
    --h = h == 8 and 1 or h
    return Timecyc[s][h] 
end
function updateSA(weather_id,currentHour,currentMinute) 
    Weather.old = weather_id

    local hours = { 0, 1, 2, 3, 4, 5, 6, 7, 8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24}
    local time = currentHour + currentMinute/60.0;

    local curHour = 0 local nextHour = 0
	local curHourSel = 1 local nextHourSel = 1

    -- find current time in hour index
    while(time >= hours[curHourSel+1]) do
        curHourSel = curHourSel + 1
    end
    curHourSel = curHourSel == 0 and 1 or curHourSel
    
    nextHourSel = (curHourSel + 1) % Weather.numHours
    nextHourSel = nextHourSel == 0 and 1 or nextHourSel

	curHour = hours[curHourSel]
	nextHour = hours[curHourSel+1]

    local timeInterp = (time - curHour) / (nextHour - curHour)
    local curOld = getColourSet(curHourSel,Weather.old+1)
    local curNew = getColourSet(curHourSel, Weather.new+1)
	local nextOld = getColourSet(nextHourSel, Weather.old+1)
	local nextNew = getColourSet(nextHourSel, Weather.new+1)

    --interpolation
    local oldInterp = interpolate(curOld,nextOld, 1.0-timeInterp, timeInterp)
	local newInterp = interpolate(curNew,nextNew, 1.0-timeInterp, timeInterp)
	local currentColours = interpolate(oldInterp,newInterp, 1.0-Weather.interpolation, Weather.interpolation,true)

    -- more accurate gradient from https://github.com/GTAmodding/timecycle24/blob/master/src/TimeCycle.cpp
    -- thanks to aap's help
    --[[
    currentColours.sky_top[1] = currentColours.sky_top[1] * currentColours.dirMult
    currentColours.sky_top[1] = currentColours.sky_top[1] > 0xFF and 0xFF or currentColours.sky_top[1]
    currentColours.sky_top[2] = currentColours.sky_top[2] * currentColours.dirMult
    currentColours.sky_top[2] = currentColours.sky_top[2] > 0xFF and 0xFF or currentColours.sky_top[2]
    currentColours.sky_top[3] = currentColours.sky_top[3] * currentColours.dirMult
    currentColours.sky_top[3] = currentColours.sky_top[3] > 0xFF and 0xFF or currentColours.sky_top[3]
    currentColours.sky_bot[1] = currentColours.sky_top[1] * currentColours.dirMult
    currentColours.sky_bot[1] = currentColours.sky_bot[1] > 0xFF and 0xFF or currentColours.sky_bot[1]
    currentColours.sky_bot[2] = currentColours.sky_top[2] * currentColours.dirMult
    currentColours.sky_bot[2] = currentColours.sky_bot[2] > 0xFF and 0xFF or currentColours.sky_bot[2]
    currentColours.sky_bot[3] = currentColours.sky_top[3] * currentColours.dirMult
    currentColours.sky_bot[3] = currentColours.sky_bot[3] > 0xFF and 0xFF or currentColours.sky_bot[3]
    --]]
    --sky 
    setSkyGradient(currentColours.sky_top[1],currentColours.sky_top[2],currentColours.sky_top[3],currentColours.sky_bot[1],currentColours.sky_bot[2],currentColours.sky_bot[3])
    --sun
    setSunColor(currentColours.sun_core[1],currentColours.sun_core[2],currentColours.sun_core[3],currentColours.sun_corona[1],currentColours.sun_corona[2],currentColours.sun_corona[3])
    setSunSize(currentColours.sun_size)
    -- fog
    setFogDistance(currentColours.fogSt)
    setFarClipDistance(currentColours.farClp)
    Weather.data = currentColours

    -- update interpolation
    if Weather.interpolateStart ~= 0 then 
        if Weather.interpolation < 1 then 
            local endTime =  (Weather.interpolationLength * 60000)
            Weather.interpolation = (getTickCount() - Weather.interpolateStart) / endTime
        else -- stop weather interpolation
            Weather.old = Weather.new
            setWeatherSA(Weather.new)
            Weather.interpolateStart = 0 -- stop interpolation
        end
    end
end 
function getTimeCycleValue(key) 
    --local h,m = getTime()
    --local time = clampTimeIndex(h)
    --return tonumber(Timecyc[weather_id+1][time][offset])
    return Weather.data[key]
end
function setWeatherBlended(wea) 
    Weather.new = wea
    Weather.interpolateStart = getTickCount()
    Weather.interpolation = 0
end
function setWeather(wea) 
    Weather.old =wea
end
function getWeather() 
    return Weather.old,Weather.interpolation < 1 and Weather.new or nil
end
addEventHandler( "onClientResourceStart",resourceRoot,function ()
    loadTimeCycle("timecyc_vcs.dat")
    addEventHandler("onClientRender",root,function()
        local h,m = getTime()
        local wea = getWeather()
        updateSA(wea,h,m)
    end,false,"low")
end)
--setWeather(1) 
--setWeatherBlended(8) 