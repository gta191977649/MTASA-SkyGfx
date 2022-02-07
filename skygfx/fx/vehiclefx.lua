renderCache = {}

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

function doVehicleClassicLight(veh) 
    local vec_cam = getCamera().matrix:getForward()
    local vec_veh = veh.matrix:getForward()
    local angle = math.deg(math.acos(vec_veh:dot(vec_cam) / vec_veh:getSquaredLength() * vec_cam:getSquaredLength()))
    local fade_front = angle > 90 and 1-vec_veh:dot(vec_cam) or 0
    local fade_back = angle <= 90 and vec_veh:dot(vec_cam) or 0
    
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

    local function createOrUpateVehicleLight(key,dummy,dir) 
        dir = dir or "l"
        local offset = dir == "l" and 1 or dir == "c" and 0 or -1
        if dummy == "light_front_main" then
            if renderCache[veh].cor[key] == nil then
                local cLight = dir == "c" and createHeadLight or createFrontLight
                local cor = cLight()
                renderCache[veh].cor[key] = cor
            else
                local dx,dy,dz = unpack(renderCache[veh].dummy[dummy])
                local x,y,z = getPositionFromElementOffset(veh,offset*dx,dy,dz)
                COR:setCoronaPosition(renderCache[veh].cor[key],x,y,z)
                COR:setCoronaColor(renderCache[veh].cor[key],255,255,255,SKYGFX.vehicleHeadLightAlpha*fade_front)
            end
        end
        if dummy == "light_rear_main" then
            if renderCache[veh].cor[key] == nil then
                local cor = createRearLight() 
                renderCache[veh].cor[key] = cor
            else
                local dx,dy,dz = unpack(renderCache[veh].dummy[dummy])
                local x,y,z = getPositionFromElementOffset(veh,offset*dx,dy,dz)
                COR:setCoronaPosition(renderCache[veh].cor[key],x,y,z)
                COR:setCoronaColor(renderCache[veh].cor[key],255,0,0,SKYGFX.vehicleRearLightAlpha*fade_back)
            end
        end

    end

    local function destroyVehicleLight(key) 
        if renderCache[veh].cor[key] then
            COR:destroyCorona(renderCache[veh].cor[key])
            renderCache[veh].cor[key] = nil
        end
    end

    if getVehicleLightState(veh,1) == 0 then
        createOrUpateVehicleLight("front_l","light_front_main","l") 
    else
        destroyVehicleLight("front_l") 
    end
    if getVehicleLightState(veh,0) == 0 then
        createOrUpateVehicleLight("front_r","light_front_main","r")
    else
        destroyVehicleLight("front_r") 
    end
    if getVehicleLightState(veh,1) == 0 or getVehicleLightState(veh,1) == 0 then
        createOrUpateVehicleLight("front_c","light_front_main","c") 
    else
        destroyVehicleLight("front_c") 
    end

    if getVehicleLightState(veh,2) == 0 then
        createOrUpateVehicleLight("back_l","light_rear_main","l")
    else
        destroyVehicleLight("back_l") 
    end
    
    if getVehicleLightState(veh,3) == 0 then
        createOrUpateVehicleLight("back_r","light_rear_main","r")
    else
        destroyVehicleLight("back_r") 
    end
end

function destoryAllVehicleClassicLights(veh) 
    if renderCache[veh] then
        if renderCache[veh].cor.front_l then
            COR:destroyCorona(renderCache[veh].cor.front_l)
            renderCache[veh].cor.front_l = nil
        end
        if renderCache[veh].cor.front_c then
            COR:destroyCorona(renderCache[veh].cor.front_c)
            renderCache[veh].cor.front_c = nil
        end
        if renderCache[veh].cor.front_r then
            COR:destroyCorona(renderCache[veh].cor.front_r)
            renderCache[veh].cor.front_r = nil
        end
        if renderCache[veh].cor.back_l then
            COR:destroyCorona(renderCache[veh].cor.back_l)
            renderCache[veh].cor.back_l = nil
        end
        if renderCache[veh].cor.back_r then
            COR:destroyCorona(renderCache[veh].cor.back_r)
            renderCache[veh].cor.back_r = nil
        end
    end
end