---------------------------------------------------------------------------------------------------
-- material primitive functions
---------------------------------------------------------------------------------------------------
trianglestrip = {}
trianglestrip.quad1x1 = {
    {-1, -1, 0, tocolor(255, 255, 255), 0, 0}, 
    {-1, 1, 0, tocolor(255, 255, 255), 0, 1}, 
    {1, -1, 0, tocolor(255, 255, 255), 1, 0},
    {1, 1, 0, tocolor(255, 255, 255), 1, 1}
}
function doSunFX() 
	if not sunShader then return end
    -- check time rage
    local h,m = getTime()
    if h >= 5 and h <= 19 then
        local c1r, c1g, c1b, c2r, c2g, c2b = getSunColor()
        local sunSize = getSunSize()
        dxSetShaderValue( sunShader, "sSunColor1", c1r / 255, c1g / 255, c1b / 255, 0  )
        dxSetShaderValue( sunShader, "sSunColor2", c2r / 255, c2g / 255, c2b / 255, 1  )
        dxSetShaderValue( sunShader, "sSunSize", sunSize  )
        -- update the sun position
        local h,m =	getTime()
        s = m
        sunAngle = (m + 60 * h + s/60.0) * 0.0043633231;
        x = 0.7 + math.sin(sunAngle);
        y = -0.7;
        z = 0.2 - math.cos(sunAngle);
        dxSetShaderValue( sunShader, "sSunVec",{x,y,z} )
        dxDrawMaterialPrimitive3D( "trianglestrip", sunShader, false, unpack( trianglestrip.quad1x1 ) )	

        --outputChatBox( )
        --debug
    
        local vecPlayer = getCamera().matrix:getPosition()
        local sunVec = vecPlayer + Vector3(x,y,z) * SKYGFX.sunZTestLength
        local isClear = isLineOfSightClear (vecPlayer.x,vecPlayer.y,vecPlayer.z,sunVec.x,sunVec.y,sunVec.z, true,  true,  true,
        true, false, true, false, localPlayer )
        --dxDrawLine3D(vecPlayer.x,vecPlayer.y,vecPlayer.z, sunVec.x,sunVec.y,sunVec.z,isClear and tocolor(0,255,0,255) or tocolor(255,0,0,255))
        
        dxSetShaderValue( sunShader, "zTest",not isClear)
    else
        dxSetShaderValue( sunShader, "sSunSize", 0 )
    end
end
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

function doClassicFX() 
    for veh,vehicle in pairs(renderCache) do 
        if isElement(veh) and isElementOnScreen(veh) and areVehicleLightsOn(veh) then

            doVehicleLightTrails(veh) 
        end
    end
end
function doClassicFXPreRender() 
    for veh,vehicle in pairs(renderCache) do 
        if isElement(veh) then
            if isElementOnScreen(veh) and areVehicleLightsOn(veh) then
                doVehicleClassicLight(veh) 
            else
                destoryAllVehicleClassicLights(veh)
            end
        end
    end
end
function doTrashOnGround() 
    CRubbish:render()
    CRubbish:update() 
end

function initWorldMiscFx() 
    -- sun glare vehicle
    setWorldSpecialPropertyEnabled("vehiclesunglare",SKYGFX.sunGlare)
    -- grass
    shaderGrassFx = dxCreateShader("shader/grass.fx", 0, 0, false, "world,object")
    engineApplyShaderToWorldTexture(shaderGrassFx, "tx*")
    dxSetShaderValue(shaderGrassFx, "backfacecull",SKYGFX.grassBackfaceCull)

    for k,v in ipairs(getElementsByType ("vehicle",root, true) ) do 
        initVehicleRenderCache(v) 
    end
    -- sun 
    if SKYGFX.disableZTest then
        sunShader = dxCreateShader("shader/sun.fx")
        local starTex = dxCreateTexture("txd/coronastar.png", "argb")
        dxSetShaderValue( sunShader, "fViewportSize", w, h )
        dxSetShaderValue( sunShader, "bResAspectBug", true )
        dxSetShaderValue( sunShader, "sTexStar", starTex  )
    end


    --[[ 
    shaderBigHeadlight = dxCreateShader("shader/replace.fx", 0, 0, false, "world")
    local headlight = dxCreateTexture("txd/coronaheadlightline.png")
    dxSetShaderValue(shaderBigHeadlight, "tex",headlight)
    
    engineApplyShaderToWorldTexture(shaderBigHeadlight,"coronaheadlightline")
    ]]
    -- rubbish effect
    if SKYGFX.trashOnGround then
        CRubbish:init()
    end
    if SKYGFX.vehicleClassicFx then
        COR:setCoronasDistFade(20,3)
        COR:enableDepthBiasScale(true)
    end
end