local buildPipelineShaders = {}
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

function doBuildingSimplePS() 

    for _,buildingShader in ipairs(buildPipelineShaders) do
        if not isElement(buildingShader) then return end 
        local amb = TIMECYC:getTimeCycleValue("amb")
        if not amb then return end
        local dirMult = TIMECYC:getTimeCycleValue("dirMult") * SKYGFX.buildingExtraBrightness
        if not dirMult then return end

        local r,g,b = unpack(amb)
        buildingAmbient = {r * dirMult / 0xFF, g * dirMult  / 0xFF, b * dirMult  / 0xFF, 0}
        dxSetShaderValue(buildingShader,"ambient",buildingAmbient)
        -- texture material color
        dxSetShaderValue(buildingShader,"matCol",{1,1,1,1})
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
        dxSetShaderValue(buildingShader,"dayparam",dayparam)
        dxSetShaderValue(buildingShader,"nightparam",nightparam)
        dxSetShaderValue(buildingShader,"surfAmb",1)
        --fog 
        local fog_st = TIMECYC:getTimeCycleValue("fogSt")
        local fog_end = TIMECYC:getTimeCycleValue("farClp")
        local fog_range = math.abs(fog_st-fog_end)
        dxSetShaderValue(buildingShader,"fogStart",fog_st)
        dxSetShaderValue(buildingShader,"fogEnd",fog_end)
        dxSetShaderValue(buildingShader,"fogRange",fog_range)
        dxSetShaderValue(buildingShader,"fogDisable",SKYGFX.fogDisabled)
    end
end

function initBuildingSimplePSPipeline() 
    
    if SKYGFX.dualPass then
        shaderBuildingSimplePS = dxCreateShader("shader/buildingSimplePSDual.fx",0,SKYGFX.building_dist,false,"world")
        dxSetShaderValue(shaderBuildingSimplePS,"zwriteThreshold",SKYGFX.zwriteThreshold)
    else
        shaderBuildingSimplePS = dxCreateShader("shader/buildingSimplePS.fx",0,SKYGFX.building_dist,false,"world")
    end
    table.insert(buildPipelineShaders,shaderBuildingSimplePS)

    if SKYGFX.stochastic then
        shaderStochasticPS = dxCreateShader("shader/simpleStochasticPS.fx",0,SKYGFX.building_dist,false,"world")
        table.insert(buildPipelineShaders,shaderStochasticPS)
    end

    for txd,param in pairs(textureListTable.txddb) do 
        if SKYGFX.stochastic and isElement(shaderStochasticPS) and param.stochastic == 1 then 
            engineApplyShaderToWorldTexture(shaderStochasticPS,txd)
        else
            engineApplyShaderToWorldTexture(shaderBuildingSimplePS,txd)
        end
    end

    -- setup shader constants
    for _,pipeline in ipairs(buildPipelineShaders) do
        dxSetShaderValue(pipeline,"colorScale",gColorScale)
         -- removed from MTA related txds
        for k, txd in pairs(textureListTable.BuildingPSRemoveList) do 
            engineRemoveShaderFromWorldTexture(pipeline,txd)
        end
    end

end