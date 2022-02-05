local renderCache = {}
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
function doVehicleLightTrails(veh) 
    local x,y,z = getElementPosition(veh)
    --local px,py,pz = getElementPosition(localPlayer)
    local px,py,pz = getElementPosition(getCamera())
    local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
    if dist < SKYGFX.vehicleTrailDrawDist then

        local fmlx,fmly,afmlx,afmly,afmlz = getDummyToScreenPos(veh,"light_front_main","l")
        local fmrx,fmry,afmrx,afmry,afmrz = getDummyToScreenPos(veh,"light_front_main","r")
        local frlx,frly,afrlx,afrly,afrlz = getDummyToScreenPos(veh,"light_rear_main","l")
        local frrx,frry,afrrx,afrry,afrrz = getDummyToScreenPos(veh,"light_rear_main","r")

        if fmlx and fmrx and frlx and frrx then
            local vehicle = renderCache[veh]
            --dxDrawText("L",fmlx,fmly)
        -- dxDrawText("R",fmrx,fmry)
            -- shift all array one after
            for i =SKYGFX.vehicleTrailLength,1,-1 do 
                if vehicle.trail_fl[i] ~= nil and vehicle.trail_fl[i-1] ~= nil then 
                    vehicle.trail_fl[i] = vehicle.trail_fl[i-1]
                    vehicle.trail_fr[i] = vehicle.trail_fr[i-1]
                    vehicle.trail_rl[i] = vehicle.trail_rl[i-1]
                    vehicle.trail_rr[i] = vehicle.trail_rr[i-1]
                end
                if i == 1 then 
                    if #vehicle.trail_fl < SKYGFX.vehicleTrailLength then 
                        vehicle.trail_fl[#vehicle.trail_fl+1] = {fmlx,fmly}
                        vehicle.trail_fr[#vehicle.trail_fr+1] = {fmrx,fmry}
                        vehicle.trail_rl[#vehicle.trail_rl+1] = {frlx,frly}
                        vehicle.trail_rr[#vehicle.trail_rr+1] = {frrx,frry}
                    else
                        vehicle.trail_fl[1] = {fmlx,fmly}
                        vehicle.trail_fr[1] = {fmrx,fmry}
                        vehicle.trail_rl[1] = {frlx,frly}
                        vehicle.trail_rr[1] = {frrx,frry}
                    end
                end
            
            end

            for i =1,SKYGFX.vehicleTrailLength do 
                if vehicle.trail_fl[i] and vehicle.trail_fl[i+1] then
                    local distFade =  1- (dist / SKYGFX.vehicleTrailDrawDist)
                    local alpha1 = (1- (i / SKYGFX.vehicleTrailLength))  * distFade 
                    local alpha2 = (1- (i / SKYGFX.vehicleTrailLength  )) * distFade 
                    --outputChatBox(alpha2)

                    if getVehicleLightState(veh,1) == 0 and #vehicle.trail_fl == SKYGFX.vehicleTrailLength and isPosVisable(afmlx,afmly,afmlz)  then
                        dxDrawLine(vehicle.trail_fl[i][1],vehicle.trail_fl[i][2],vehicle.trail_fl[i+1][1],vehicle.trail_fl[i+1][2],tocolor(255,255,255,100* alpha1))
                    end
                    if getVehicleLightState(veh,0) == 0  and #vehicle.trail_fr == SKYGFX.vehicleTrailLength and isPosVisable(afmrx,afmry,afmrz)  then
                        dxDrawLine(vehicle.trail_fr[i][1],vehicle.trail_fr[i][2],vehicle.trail_fr[i+1][1],vehicle.trail_fr[i+1][2],tocolor(255,255,255, 100* alpha1))
                    end
                    -- back
                    if getVehicleLightState(veh,2) == 0  and #vehicle.trail_rl == SKYGFX.vehicleTrailLength and isPosVisable(afrlx,afrly,afrlz)  then
                        dxDrawLine(vehicle.trail_rl[i][1],vehicle.trail_rl[i][2],vehicle.trail_rl[i+1][1],vehicle.trail_rl[i+1][2],tocolor(255,0,0,255* alpha2))
                    end
                    if getVehicleLightState(veh,3) == 0  and #vehicle.trail_rr == SKYGFX.vehicleTrailLength and isPosVisable(afrrx,afrry,afrrz)  then
                        dxDrawLine(vehicle.trail_rr[i][1],vehicle.trail_rr[i][2],vehicle.trail_rr[i+1][1],vehicle.trail_rr[i+1][2],tocolor(255,0,0,255* alpha2))
                    end
                    
                end
            end

        end
    end
  
end

function doVehicleBigLight(veh) 
    -- front 
    local function createFrontLight() 
        local cor = COR:createCorona(0,0,0,1,0,0,0,0)
        --COR:setCoronaSizeXY(cor,1,0.1)
        return cor
    end
    local function createHeadLight() 
        local cor = COR:createCorona(0,0,0,1,0,0,0,0)
        COR:setCoronaSizeXY(cor,3,0.2)
        return cor
    end
    local function createRearLight() 
        local cor = COR:createCorona(0,0,0,1,0,0,0,0)
        COR:setCoronaSizeXY(cor,0.8,0.2)
        return cor
    end
    local vec_cam = getCamera().matrix:getForward()
    local vec_veh = veh.matrix:getForward()
    local angle = math.deg(math.acos(vec_veh:dot(vec_cam) / vec_veh:getSquaredLength() * vec_cam:getSquaredLength()))
    local fade_front = angle > 90 and 1-vec_veh:dot(vec_cam) or 0
    local fade_back = angle <= 90 and vec_veh:dot(vec_cam) or 0

    if renderCache[veh].cor.front_l == nil then
        local cor = createFrontLight() 
        addEventHandler("onClientElementDestroy", veh, function ()
            COR:destroyCorona(cor)
            renderCache[veh].cor.front_l = nil
        end)
        renderCache[veh].cor.front_l = cor
    else
        local dx,dy,dz = unpack(renderCache[veh].dummy["light_front_main"])
        local x,y,z = getPositionFromElementOffset(veh,dx,dy,dz)
        COR:setCoronaPosition(renderCache[veh].cor.front_l,x,y,z)
        COR:setCoronaColor(renderCache[veh].cor.front_l,255,255,255,SKYGFX.vehicleHeadLightAlpha*fade_front)
    end
    if renderCache[veh].cor.front_c == nil then
        local cor = createHeadLight() 
        addEventHandler("onClientElementDestroy", veh, function ()
            COR:destroyCorona(cor)
            renderCache[veh].cor.front_c = nil
        end)
        renderCache[veh].cor.front_c = cor
    else
        local dx,dy,dz = unpack(renderCache[veh].dummy["light_front_main"])
        local x,y,z = getPositionFromElementOffset(veh,0,dy,dz)
        COR:setCoronaPosition(renderCache[veh].cor.front_c,x,y,z)
        COR:setCoronaColor(renderCache[veh].cor.front_c,255,255,255,SKYGFX.vehicleHeadLightAlpha*fade_front)
    end


    if renderCache[veh].cor.front_r == nil then
        local cor = createFrontLight() 
        addEventHandler("onClientElementDestroy", veh, function ()
           COR:destroyCorona(cor)
           renderCache[veh].cor.front_r = nil
        end)
        renderCache[veh].cor.front_r = cor
    else
        local dx,dy,dz = unpack(renderCache[veh].dummy["light_front_main"])
        local x,y,z = getPositionFromElementOffset(veh,-dx,dy,dz)
        COR:setCoronaPosition(renderCache[veh].cor.front_r,x,y,z)
        COR:setCoronaColor(renderCache[veh].cor.front_r,255,255,255,SKYGFX.vehicleHeadLightAlpha*fade_front)
    end

    -- back light
    if renderCache[veh].cor.back_l == nil then
        local cor = createRearLight() 
        addEventHandler("onClientElementDestroy", veh, function ()
           COR:destroyCorona(cor)
           renderCache[veh].cor.back_l = nil
        end)
        renderCache[veh].cor.back_l = cor
    else
        local dx,dy,dz = unpack(renderCache[veh].dummy["light_rear_main"])
        local x,y,z = getPositionFromElementOffset(veh,dx,dy,dz)
        COR:setCoronaPosition(renderCache[veh].cor.back_l,x,y,z)
        COR:setCoronaColor(renderCache[veh].cor.back_l,255,0,0,SKYGFX.vehicleRearLightAlpha*fade_back)
        --COR:setCoronaSizeXY(renderCache[veh].cor.back_l,1,1 * vec_veh:dot(vec_cam))
    end
    if renderCache[veh].cor.back_r == nil then

        local cor = createRearLight() 
        addEventHandler("onClientElementDestroy", veh, function ()
           COR:destroyCorona(cor)
           renderCache[veh].cor.back_r = nil
        end)
        renderCache[veh].cor.back_r = cor
    else
        local dx,dy,dz = unpack(renderCache[veh].dummy["light_rear_main"])
        local x,y,z = getPositionFromElementOffset(veh,-dx,dy,dz)
        COR:setCoronaPosition(renderCache[veh].cor.back_r,x,y,z)
        COR:setCoronaColor(renderCache[veh].cor.back_r,255,0,0,SKYGFX.vehicleRearLightAlpha*fade_back)
    end
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
        if isElement(veh) and isElementOnScreen(veh) and areVehicleLightsOn(veh) then

            doVehicleBigLight(veh) 
        end
    end
end

function initVehicleRenderCache(v) 
    if not renderCache[v] then
        renderCache[v] = {
            veh = v,
            trail_fl = {},
            trail_fr = {},
            trail_rl = {},
            trail_rr = {},
            dummy = {},
            cor = {
                front_l = nil,
                front_c = nil,
                front_r = nil,
                back_l = nil,
                back_r = nil,
            },
        }
        -- get the constants
        local x,y,z = getVehicleDummyPosition (v,"light_front_main")
        local rx,ry,rz = getVehicleDummyPosition (v,"light_rear_main")
        renderCache[v].dummy["light_front_main"] = {x,y,z}
        renderCache[v].dummy["light_rear_main"] = {rx,ry,rz}
    end
end
function initWorldMiscFx() 
    -- grass
    shaderGrassFx = dxCreateShader("shader/grass.fx", 0, 0, false, "world,object")
    engineApplyShaderToWorldTexture(shaderGrassFx, "tx*")
    dxSetShaderValue(shaderGrassFx, "backfacecull",SKYGFX.grassBackfaceCull)

    for k,v in ipairs(getElementsByType ("vehicle",root, true) ) do 
        initVehicleRenderCache(v) 
    end

    --[[
    if SKYGFX.vehicleBigHeadLight then 
        shaderBigHeadlight = dxCreateShader("shader/replace.fx", 0, 0, false, "vehicle")
        local headlight = dxCreateTexture("txd/coronaheadlightline.png")
        dxSetShaderValue(shaderBigHeadlight, "tex",headlight)
        
        engineApplyShaderToWorldTexture(shaderBigHeadlight,"unnamed")
        
    end
    --]]

    COR:setCoronasDistFade(20,3)
    COR:enableDepthBiasScale(true)
    -- vehicle classic effect
    if SKYGFX.vehicleClassicFx then
        addEventHandler( "onClientElementStreamIn", root,function ()
            if getElementType( source ) == "vehicle" then
                initVehicleRenderCache(source) 
            end
        end)
        addEventHandler( "onClientElementStreamOut", root,function ()
            if getElementType( source ) == "vehicle" then
                renderCache[source] = nil

            end
        end)
        addEventHandler("onClientRender", root, function() 
            doClassicFX() 
            --dxDrawImage(0,0,800,600,shaderBigHeadlight)
        end)
        addEventHandler("onClientPreRender", root, function() 
            doClassicFXPreRender() 
            --dxDrawImage(0,0,800,600,shaderBigHeadlight)
        end)
    end

end