local myScreenSource = nil
local rt_radiosity = nil
local shader_radiosity = nil
local shader_addblend = nil
local sx,sy = guiGetScreenSize()
local config = {
    limit = 1,
    pass = 1,
    intensity = 1,
}
function processRadiosity()
    if myScreenSource then
        dxUpdateScreenSource( myScreenSource,true )
        dxSetRenderTarget(rt_radiosity,true)
        dxSetShaderValue(shader_radiosity, "Tex0",myScreenSource)
        dxSetShaderValue(shader_radiosity, "passes",config.pass)
        dxSetShaderValue(shader_radiosity, "intensity",config.intensity)
        dxSetShaderValue(shader_radiosity, "limit",config.limit)
        dxDrawImage(0,  0,  sx, sy, shader_radiosity )
        dxSetRenderTarget()
        if rt_radiosity then
            dxSetShaderValue( shader_addblend, "TEX0", rt_radiosity )
            dxDrawImage(0,  0,  sx, sy, shader_addblend )
        end
    end
end

function fx_toogleRadiosity(switch) 
    if switch then
        -- start shader
        shader_addblend = dxCreateShader( "addBlend.fx" )
        shader_radiosity = dxCreateShader("radiosity.fx", 0, 0, false, "world,object,ped")
        myScreenSource = dxCreateScreenSource (sx, sy) 
        dxSetShaderValue(shader_radiosity, "Tex0",myScreenSource)
        -- render targets
        rt_radiosity = dxCreateRenderTarget(sx,sy)
        -- add process handle
        addEventHandler( "onClientHUDRender", root,processRadiosity)
        --Timer = setTimer(updateWorldDiffuse, 1000, 0)
        print("SKYFX: Radiosity Enabled")
    else
        if isElement(shader_addblend) then destroyElement(shader_addblend) end
        if isElement(shader_radiosity) then destroyElement(shader_radiosity) end
        if isElement(myScreenSource) then destroyElement(myScreenSource) end
        if isElement(rt_radiosity) then destroyElement(rt_radiosity) end
        removeEventHandler( "onClientHUDRender", root,processRadiosity)
        print("SKYFX: Radiosity Disabled")
    end
end
function fx_setRadiosityConfig(intensity,limit) 
    config.limit = limit /255
    config.intensity = intensity/255
end


