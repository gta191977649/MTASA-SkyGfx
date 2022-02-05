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
    noZTest() 
    
end)

addEventHandler( "onClientResourceStop",resourceRoot,
    function (  )
        resetColorFilter()
        resetSunColor()
        resetSkyGradient()
        resetSunSize()
    end
);