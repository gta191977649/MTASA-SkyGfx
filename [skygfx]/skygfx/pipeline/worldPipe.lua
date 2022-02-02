
function doWorldFX() 
    -- grass world amb, done by shader enmulation,not 100% accurate
    local amb = TIMECYC:getTimeCycleValue("amb")
    --[[
        if(config->grassAddAmbient){
            col[0] += CTimeCycle_GetAmbientRed()*255;
            col[1] += CTimeCycle_GetAmbientGreen()*255;
            col[2] += CTimeCycle_GetAmbientBlue()*255;
            if(col[0] > 255) col[0] = 255;
            if(col[1] > 255) col[1] = 255;
            if(col[2] > 255) col[2] = 255;
        }
        newcolor.red = (tmpintensity * col[0]) >> 8;
        newcolor.green = (tmpintensity * col[1]) >> 8;
        newcolor.blue = (tmpintensity * col[2]) >> 8;
        newcolor.alpha = color->alpha;
        material->color = newcolor;
    ]]
    local r,g,b = unpack(amb)


    dxSetShaderValue(shaderGrassFx, "amb",{r/255,g/255,b/255})
end
function initWorldMiscFx() 
    -- grass
    shaderGrassFx = dxCreateShader("shader/grass.fx", 0, 0, false, "world,object")
    engineApplyShaderToWorldTexture(shaderGrassFx, "tx*")
    dxSetShaderValue(shaderGrassFx, "backfacecull",SKYGFX.grassBackfaceCull)
    if SKYGFX.grassAddAmbient then
        addEventHandler("onClientPreRender", root, doWorldFX)
    end
end