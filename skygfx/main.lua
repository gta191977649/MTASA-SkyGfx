addEventHandler( "onClientResourceStart",resourceRoot,function ( startedRes )
    resetColorFilter()
    resetSunColor()
    resetSkyGradient()
    resetSunSize()
    -- start skygfx
    initBuildingSimplePSPipeline()
    initVehiclePiple()
    initPostFx()
    initWorldMiscFx()
    --noZTest() 
    
end)

addEventHandler( "onClientResourceStop",resourceRoot,
    function (  )
        resetColorFilter()
        resetSunColor()
        resetSkyGradient()
        resetSunSize()
    end
);
-- event
addEventHandler( "onClientElementStreamIn", root,function ()
    if SKYGFX.vehicleClassicFx then
        if getElementType( source ) == "vehicle" and not renderCache[source] then
            initVehicleRenderCache(source) 
        end
    end
end)
addEventHandler( "onClientElementStreamOut", root,function ()
    if SKYGFX.vehicleClassicFx then
        if renderCache[source]  then
            destoryAllVehicleClassicLights(source)
            renderCache[source] = nil
        end
    end
end)
addEventHandler("onClientRender", root, function() 
    doVehiclePipeline()
    if SKYGFX.disableZTest then
        doSunFX() 
    end
    if SKYGFX.vehicleClassicFx then
        doClassicFX() 
    end
    if SKYGFX.trashOnGround then
        doTrashOnGround()
    end
end)
addEventHandler("onClientPreRender", root, function() 
    if SKYGFX.vehicleClassicFx then
        doClassicFXPreRender() 
    end
end)
addEventHandler("onClientHUDRender", root,function() 
    doBuildingSimplePS()
    renderPostFX() 
end)

addEventHandler("onClientElementDestroy", root, function ()
    if SKYGFX.vehicleClassicFx then
        destoryAllVehicleClassicLights(source)
    end
end)


