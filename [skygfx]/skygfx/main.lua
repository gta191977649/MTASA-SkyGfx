addEventHandler( "onClientResourceStart",resourceRoot,function ( startedRes )
    resetColorFilter()
    resetSunColor()
    resetSkyGradient()
    resetSunSize()
    -- start skygfx
    initBuildingSimplePSPipeline()
    worldPipeInit() 
    initPostFx()
    noZTest() 
    
end)