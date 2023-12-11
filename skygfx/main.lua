local isStarted = false
-- event
function SKYGFX.onClientElementStreamIn()
    if SKYGFX.vehicleClassicFx then
        if getElementType( source ) == "vehicle" and not renderCache[source] then
            initVehicleRenderCache(source) 
        end
    end
end
function SKYGFX.onClientElementStreamOut()
    if SKYGFX.vehicleClassicFx then
        if renderCache[source]  then
            destoryAllVehicleClassicLights(source)
            renderCache[source] = nil
        end
    end
end
function SKYGFX.onClientRender() 
    doBuildingSimplePS()
    doVehiclePipeline()
    if SKYGFX.fixRotor then
        renderRotorEffect()
    end
    -- if SKYGFX.disableZTest then -- use the MTA 1.6.0 Native function instead
    --     doSunFX() 
    -- end
    if SKYGFX.vehicleClassicFx then
        doClassicFX() 
    end
    if SKYGFX.trashOnGround then
        --doTrashOnGround()
    end
end
function SKYGFX.onClientPreRender() 
    if SKYGFX.vehicleClassicFx then
        doClassicFXPreRender() 
    end
end
function SKYGFX.onClientHUDRender() 
    renderPostFX() 
end
function SKYGFX.onClientElementDestroy()
    if SKYGFX.vehicleClassicFx then
        destoryAllVehicleClassicLights(source)
    end
end



function SKYGFX.start() 
    if isStarted then return end
    -- init shits
    resetColorFilter()
    resetSunColor()
    resetSkyGradient()
    resetSunSize()
    -- loadtxdDB
    loadtxdDB()
    -- start skygfx
    initBuildingSimplePSPipeline()
    initVehiclePiple()
    initPostFx()
    initWorldMiscFx()
    if SKYGFX.sunGodray then
        enableSunShader()
    end
    if SKYGFX.fixRotor then 
        enableRotorPs2Fix()
    end
    --noZTest() -- no needed now
    -- add events
    addEventHandlerEx("onClientElementStreamIn", root,SKYGFX.onClientElementStreamIn)
    addEventHandlerEx("onClientElementStreamOut", root,SKYGFX.onClientElementStreamOut)
    addEventHandlerEx("onClientRender", root,SKYGFX.onClientRender,false,"low")
    addEventHandlerEx("onClientPreRender", root,SKYGFX.onClientPreRender,false,"low")
    addEventHandlerEx("onClientHUDRender", root,SKYGFX.onClientHUDRender,false,"low")
    addEventHandlerEx("onClientElementDestroy", root,SKYGFX.onClientElementDestroy)
    isStarted = true
end

function SKYGFX.stop() 
    if not isStarted then return end
    resetColorFilter()
    resetSunColor()
    resetSkyGradient()
    resetSunSize()
    if SKYGFX.fixRotor then 
        disableRotorPs2Fix()
    end
    -- remove events
    removeEventHandlerEx("onClientElementStreamIn", root,SKYGFX.onClientElementStreamIn)
    removeEventHandlerEx("onClientElementStreamOut", root,SKYGFX.onClientElementStreamOut)
    removeEventHandlerEx("onClientRender", root,SKYGFX.onClientRender)
    removeEventHandlerEx("onClientPreRender", root,SKYGFX.onClientPreRender)
    removeEventHandlerEx("onClientHUDRender", root,SKYGFX.onClientHUDRender)
    removeEventHandlerEx("onClientElementDestroy", root,SKYGFX.onClientElementDestroy)
    isStarted = false
end


addEventHandler( "onClientResourceStart",resourceRoot,function ( startedRes )
    if SKYGFX.autoStart then 
        SKYGFX.start() 
    end
    
end)

addEventHandler( "onClientResourceStop",resourceRoot,
    function (  )
        SKYGFX.stop() 
    end
)

