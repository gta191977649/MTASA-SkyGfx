shaderBuildingSimplePS = nil
gDayNightBalance = 1
gWetRoadEffect = 0


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

function doBuildingSimplePS() 
    if not isElement(shaderBuildingSimplePS) then return end 
    local amb = TIMECYC:getTimeCycleValue("amb")
    if not amb then return end
    local dirMult = TIMECYC:getTimeCycleValue("dirMult")
    if not dirMult then return end

    local r,g,b = unpack(amb)
    buildingAmbient = {r * dirMult / 0xFF, g * dirMult  / 0xFF, b * dirMult  / 0xFF, 0}
    dxSetShaderValue(shaderBuildingSimplePS,"ambient",buildingAmbient)
    -- texture material color
    dxSetShaderValue(shaderBuildingSimplePS,"matCol",{1,1,1,1})
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
    dxSetShaderValue(shaderBuildingSimplePS,"dayparam",dayparam)
    dxSetShaderValue(shaderBuildingSimplePS,"nightparam",nightparam)
    if SKYGFX.ps2Modulate then -- 255 / 128
        dxSetShaderValue(shaderBuildingSimplePS,"colorScale",1.9921875)
    else
        dxSetShaderValue(shaderBuildingSimplePS,"colorScale",1)
    end
    dxSetShaderValue(shaderBuildingSimplePS,"surfAmb",1)
    --fog 
    local fog_st = TIMECYC:getTimeCycleValue("fogSt")
    local fog_end = TIMECYC:getTimeCycleValue("farClp")
    local fog_range = math.abs(fog_st-fog_end)
    dxSetShaderValue(shaderBuildingSimplePS,"fogStart",fog_st)
    dxSetShaderValue(shaderBuildingSimplePS,"fogEnd",fog_end)
    dxSetShaderValue(shaderBuildingSimplePS,"fogRange",fog_range)
    dxSetShaderValue(shaderBuildingSimplePS,"fogDisable",SKYGFX.fogDisabled)
end

function initBuildingSimplePSPipeline() 
    if SKYGFX.dualPass then 
        shaderBuildingSimplePS = dxCreateShader("shader/buildingSimplePSDual.fx",0,0,false,"world,object")
        dxSetShaderValue(shaderBuildingSimplePS,"zwriteThreshold",SKYGFX.zwriteThreshold)
    else
        shaderBuildingSimplePS = dxCreateShader("shader/buildingSimplePS.fx",0,0,false,"world,object")
    end
    engineApplyShaderToWorldTexture(shaderBuildingSimplePS,"*")
    for k, txd in pairs(textureListTable.BuildingPSRemoveList) do 
        engineRemoveShaderFromWorldTexture(shaderBuildingSimplePS,txd)
    end

    addEventHandler( "onClientHUDRender", root,function() 
        doBuildingSimplePS()
    end)

end