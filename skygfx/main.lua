
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
    if SKYGFX.disableZTest then
        doSunFX() 
    end
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

function addEventHandlerEx(sEventName, pElementAttachedTo, func ) 
    if not isEventHandlerAdded( sEventName, pElementAttachedTo, func ) then 
        addEventHandler( sEventName, pElementAttachedTo, func )
    end
end
function removeEventHandlerEx(sEventName, pElementAttachedTo, func ) 
    if isEventHandlerAdded( sEventName, pElementAttachedTo, func ) then 
        removeEventHandler( sEventName, pElementAttachedTo, func )
    end
end


function SKYGFX.start() 
    -- init shits
    resetColorFilter()
    resetSunColor()
    resetSkyGradient()
    resetSunSize()
    -- start skygfx
    initBuildingSimplePSPipeline()
    initVehiclePiple()
    initPostFx()
    initWorldMiscFx()
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
end

function SKYGFX.stop() 
    resetColorFilter()
    resetSunColor()
    resetSkyGradient()
    resetSunSize()
    disableRotorPs2Fix()
    -- remove events
    removeEventHandlerEx("onClientElementStreamIn", root,SKYGFX.onClientElementStreamIn)
    removeEventHandlerEx("onClientElementStreamOut", root,SKYGFX.onClientElementStreamOut)
    removeEventHandlerEx("onClientRender", root,SKYGFX.onClientRender)
    removeEventHandlerEx("onClientPreRender", root,SKYGFX.onClientPreRender)
    removeEventHandlerEx("onClientHUDRender", root,SKYGFX.onClientHUDRender)
    removeEventHandlerEx("onClientElementDestroy", root,SKYGFX.onClientElementDestroy)
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

