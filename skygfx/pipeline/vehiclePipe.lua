
function doVehiclePipeline() 
    local dirMult = TIMECYC:getTimeCycleValue("dirMult") * SKYGFX.vehicleExtraBrightness
    if not dirMult then return end
    dxSetShaderValue(shaderPS2CarEnvPS,"lightmult",dirMult)
end

function initVehiclePiple() 
    if SKYGFX.vehiclePipe == "PS2" then
        shaderPS2CarEnvPS = dxCreateShader("shader/ps2CarFxVSPS.fx",0,0,false,"vehicle")
        for _,txd in pairs(textureListTable.VehiclePSApplyList) do
            engineApplyShaderToWorldTexture(shaderPS2CarEnvPS,string.format("*%s*",txd))
        
        end
    
        local txd_envMap = dxCreateTexture("txd/vehicleenvmap128.png")
        local txd_envMap_2 = dxCreateTexture("txd/xvehicleenv128.png")
        local txd_envDot = dxCreateTexture("txd/vehiclespecdot64.png")
        dxSetShaderValue(shaderPS2CarEnvPS,"envXform",txd_envMap)
        dxSetShaderValue(shaderPS2CarEnvPS,"envmat",txd_envMap)
        dxSetShaderValue(shaderPS2CarEnvPS,"specmat",txd_envDot)
        dxSetShaderValue(shaderPS2CarEnvPS,"tx1",txd_envMap)
        dxSetShaderValue(shaderPS2CarEnvPS,"tx2",txd_envDot)
        dxSetShaderValue(shaderPS2CarEnvPS,"shininess",SKYGFX.envPower)
    end

    if SKYGFX.vehiclePipe == "Xbox" then
        shaderPS2CarEnvPS = dxCreateShader("shader/envCarPS.fx",0,0,false,"vehicle")
        for _,txd in pairs(textureListTable.VehiclePSApplyList) do
            engineApplyShaderToWorldTexture(shaderPS2CarEnvPS,txd)
        end
        

        local txd_envMap = dxCreateTexture("txd/vehicleenvmap128.png")
        local txd_envMap_2 = dxCreateTexture("txd/xvehicleenv128.png")
        local txd_envDot = dxCreateTexture("txd/vehiclespecdot64.png")
        dxSetShaderValue(shaderPS2CarEnvPS,"tx1",txd_envMap)
        dxSetShaderValue(shaderPS2CarEnvPS,"tx2",txd_envDot)
    end

end