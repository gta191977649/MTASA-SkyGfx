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