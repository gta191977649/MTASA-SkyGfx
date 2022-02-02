
function worldPipeInit() 
    if SKYGFX.grassBackfaceCull then
        shaderBackfaceCull = dxCreateShader("shader/backfaceCull.fx", 0, 0, false, "world,object")
        engineApplyShaderToWorldTexture(shaderBackfaceCull, "tx*")
    end
end