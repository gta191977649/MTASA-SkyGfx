--[[
    BUILDING PIPELINE (PORT FROM SKYGFX)
]]
shaderSimplePS = nil
shaderBuildingVS = nil
gDayNightBalance = 1
gWetRoadEffect = 0
gColorScale = SKYGFX.ps2Modulate and 0xFF / 0x80 or 1;

function updateDayNightBalance(currentHour,currentMinute)
	local minute = currentHour*60.0 + currentMinute;
	local morningStart = 6 * 60.0
	local morningEnd = 7 * 60.0
	local eveningStart = 20 * 60.0
	local eveningEnd = 21 * 60.0

	--1.0 is night, 0.0 is day
	if minute < morningStart then
		gDayNightBalance = 1.0
    elseif minute < morningEnd then
		gDayNightBalance = (morningEnd - minute) / (morningEnd - morningStart);
	elseif minute < eveningStart then
		gDayNightBalance = 0.0
    elseif minute < eveningEnd then
		gDayNightBalance = 1.0 - (eveningEnd - minute) / (eveningEnd - eveningStart)
	else
		gDayNightBalance = 1.0
    end
end

function doSimplePS() 
    -- obtain the timecyc gradient
    --[[
    local tr,tg,tb = unpack(TIMECYC:getTimeCycleValue("sky_top"))
    local br,bg,bb = unpack(TIMECYC:getTimeCycleValue("sky_bot"))
    -- code from aap
   
    fog_r = (tr + 2*br) / 3;
    fog_g = (tg + 2*bg) / 3;
    fog_b = (tb + 2*bb) / 3;
    ]]
    
    --dxSetShaderValue(shaderSimplePS,"fogColor",{fog_r/255,fog_g/255,fog_b/255})
    dxSetShaderValue(shaderSimplePS,"colorscale",gColorScale)
    dxSetShaderValue(shaderSimplePS,"brightness",SKYGFX.brightnessMul)
end

function doBuildingVS() 
    -- calc amb 
    --[[
        // do *not* use pAmbient light. It causes so many problems
        buildingAmbient.red = CTimeCycle_GetAmbientRed()*CCoronas__LightsMult;
        buildingAmbient.green = CTimeCycle_GetAmbientGreen()*CCoronas__LightsMult;
        buildingAmbient.blue = CTimeCycle_GetAmbientBlue()*CCoronas__LightsMult;

        if(config->lightningIlluminatesWorld && CWeather__LightningFlash && !CPostEffects__IsVisionFXActive())
            buildingAmbient = { 1.0, 1.0, 1.0, 0.0 };
    ]]
    local amb = TIMECYC:getTimeCycleValue("amb")
    if not amb then return end
    local dirMult = TIMECYC:getTimeCycleValue("dirMult")
    if not dirMult then return end

    local r,g,b = unpack(amb)
    buildingAmbient = {r * dirMult / 0xFF, g * dirMult  / 0xFF, b * dirMult  / 0xFF, 0}
    dxSetShaderValue(shaderBuildingVS,"ambient",buildingAmbient)
    -- texture material color
    dxSetShaderValue(shaderBuildingVS,"matCol",{1,1,1,1})
    --day / night params
    local currentHour,currentMinute = getTime()
    updateDayNightBalance(currentHour,currentMinute)
    local dayparam = {} local nightparam = {}
    if SKYGFX.RSPIPE_PC_CustomBuilding_PipeID then 
        dayparam = {0,0,0,1}
		nightparam = {1,1,1,1}
    else
        dayparam = {1.0-gDayNightBalance,1.0-gDayNightBalance,1.0-gDayNightBalance,gWetRoadEffect}
		nightparam = {gDayNightBalance,gDayNightBalance,gDayNightBalance,1.0-gWetRoadEffect}
    end
    dxSetShaderValue(shaderBuildingVS,"dayparam",dayparam)
    dxSetShaderValue(shaderBuildingVS,"nightparam",nightparam)
    dxSetShaderValue(shaderBuildingVS,"colorScale",gColorScale)
    dxSetShaderValue(shaderBuildingVS,"surfAmb",1)
    --fog 
    local fog_st = TIMECYC:getTimeCycleValue("fogSt")
    local fog_end = TIMECYC:getTimeCycleValue("farClp")
    local fog_range = math.abs(fog_st-fog_end)
    dxSetShaderValue(shaderBuildingVS,"fogStart",fog_st)
    dxSetShaderValue(shaderBuildingVS,"fogEnd",fog_end)
    dxSetShaderValue(shaderBuildingVS,"fogRange",fog_range)
    dxSetShaderValue(shaderBuildingVS,"fogDisable",SKYGFX.fogDisabled)
    
end
function initBuildingPipeline() 
    -- simplePS
    shaderSimplePS = dxCreateShader("shader/simplePS.fx",1,0,true,"world")
    engineApplyShaderToWorldTexture(shaderSimplePS,"*")
    for k, txd in pairs(textureListTable.BuildingPSRemoveList) do 
        engineRemoveShaderFromWorldTexture(shaderSimplePS,txd)
    end
    doSimplePS()

    
    -- buildingVS
    shaderBuildingVS = dxCreateShader("shader/ps2BuildingVS.fx",0,0,true,"world")
    engineApplyShaderToWorldTexture(shaderBuildingVS,"*")
    for k, txd in pairs(textureListTable.BuildingPSRemoveList) do 
        engineRemoveShaderFromWorldTexture(shaderBuildingVS,txd)
    end

    addEventHandler( "onClientHUDRender", root,function() 
        doBuildingVS()
    end)

end