aSheets = {}
cSheet = {
    m_basePos = {},
    m_animatedPos = {},
    m_targetZ = nil,
    m_state = 0,
    m_animationType = 0,
    m_moveStart = 0,
    m_moveDuration = 0,
    m_animHeight = 0,
    m_xDist = 0,
    m_yDist = 0,
    m_angle = 0,
    m_isVisible = false,
    m_targetIsVisible = false,
    m_next,
	m_prev,
}
function cSheet:addToList(list) 
    self.m_next = list.m_next
	self.m_prev = list
	list.m_next = self
	self.m_next.m_prev = self
end
function cSheet:removeFromList() 
	self.m_next.m_prev = self.m_prev
	self.m_prev.m_next = self.m_next
end


m_FrameCounter = 0;
-- CRubbish Class
CRubbish = {
    rubbishIndexList = {},
    gpRubbishTexture = {},
    startEmptyList = table.clone(cSheet),
    endEmptyList = table.clone(cSheet),
    startStaticsList = table.clone(cSheet),
    endStaticsList = table.clone(cSheet),
    startMoversList = table.clone(cSheet),
    endMoversList = table.clone(cSheet),
    bRubbishInvisible = false,
    rubbishVisibility = 255,
}

TestPrimitive = {
    {-1, -1, 0, tocolor(255, 255, 255), 0, 0}, 
    {-1, 1, 0, tocolor(255, 255, 255), 0, 1}, 
    {1, -1, 0, tocolor(255, 255, 255), 1, 0},
    {1, 1, 0, tocolor(255, 255, 255), 1, 1}
}
aAnimations = {
	[0] = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 },
    -- Normal move
    [1] = { 0.0, 0.05, 0.12, 0.25, 0.42, 0.57, 0.68, 0.8, 0.86, 0.9, 0.93, 0.95, 0.96, 0.97, 0.98, 0.99, 1.0,
	  0.15, 0.35, 0.6, 0.9, 1.2, 1.25, 1.3, 1.2, 1.1, 0.95, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0 },	-- Z movement
    -- Stirred up by ast vehicle
    [2] = { 0.0, 0.05, 0.12, 0.25, 0.42, 0.57, 0.68, 0.8, 0.95, 1.1, 1.15, 1.18, 1.15, 1.1, 1.05, 1.03, 1.0,
	  0.15, 0.35, 0.6, 0.9, 1.2, 1.25, 1.3, 1.2, 1.1, 0.95, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0 }
}
--[[
function addToList(this,new) 
	this.m_next = new.m_next
	this.m_prev = new
	new.m_next = this
	this.m_next.m_prev = this
end

function removeFromList(this)
	this.m_next.m_prev = this.m_prev
	this.m_prev.m_next = this.m_next
end
--]]
textMarker = createMarker(0, 0, 0, "cylinder", 1, 255, 255, 255, 255)
function CRubbish:render() 
    for type,mat in pairs(self.gpRubbishTexture) do
        local tempBufferIndicesStored = 0
		local tempBufferVerticesStored = 0

        for idx,sheet in ipairs(aSheets) do
            if sheet.m_state ~= 0 then
                local pos =sheet.m_basePos
                local alpha = 100
                if sheet.m_state == 1 then 
                    pos = sheet.m_basePos
                    if not sheet.m_isVisible then alpha = 0 end
                else
                    pos = sheet.m_animatedPos
                    --Not fully visible during animation, calculate current alpha
                    if not sheet.m_isVisible or not sheet.m_targetIsVisible then 
                        local t = (getTickCount() - sheet.m_moveStart)/sheet.m_moveDuration;
                        local f1 = sheet.m_isVisible and 1.0-t or 0.0
                        local f2 = sheet.m_targetIsVisible and t or 0.0;
                        alpha = 100 * (f1+f2)
                    end
                end
                local camX, camY, camZ = getCameraMatrix()
            
                local camDist = getDistanceBetweenPoints3D(pos.x,pos.y,pos.z,camX, camY, camZ)
                if camDist < SKYGFX.rubbish_max_dist then
                    if camDist >= SKYGFX.rubbish_fade_dist then
                        alpha = alpha - alpha*(camDist-SKYGFX.rubbish_fade_dist)/(SKYGFX.rubbish_max_dist-SKYGFX.rubbish_fade_dist)
                    end
                    alpha = (self.rubbishVisibility*alpha)/256;
    
                    local vx1, vy1, vx2, vy2
                    if type == 0 or type == 1 then
    
                        vx1 = 0.9*sin(sheet.m_angle * degToRad)
                        vy1 = 0.9*cos(sheet.m_angle * degToRad)
                        vx2 = 0.3*cos(sheet.m_angle * degToRad)
                        vy2 = -0.3*sin(sheet.m_angle * degToRad)
                    else
                        vx1 = 0.3*sin(sheet.m_angle * degToRad)
                        vy1 = 0.3*cos(sheet.m_angle * degToRad)
                        vx2 = 0.3*cos(sheet.m_angle * degToRad)
                        vy2 = -0.3*sin(sheet.m_angle * degToRad)
                    end

                    local v = tempBufferVerticesStored
                    local SheetPrimitive = {
                        {pos.x + vx1 + vx2, pos.y + vy1 + vy2, pos.z, tocolor(255, 255, 255, alpha), 0, 0}, 
                        {pos.x + vx1 - vx2, pos.y + vy1 - vy2, pos.z, tocolor(255, 255, 255, alpha), 1, 0}, 
                        {pos.x - vx1 + vx2, pos.y - vy1 + vy2, pos.z, tocolor(255, 255, 255, alpha), 0, 1},
                        {pos.x - vx1 - vx2, pos.y - vy1 - vy2, pos.z, tocolor(255, 255, 255, alpha), 1, 1},
                    }
                    --[[
                        int i = TempBufferIndicesStored;
                        TempBufferRenderIndexList[i+0] = RubbishIndexList[0] + TempBufferVerticesStored;
                        TempBufferRenderIndexList[i+1] = RubbishIndexList[1] + TempBufferVerticesStored;
                        TempBufferRenderIndexList[i+2] = RubbishIndexList[2] + TempBufferVerticesStored;
                        TempBufferRenderIndexList[i+3] = RubbishIndexList[3] + TempBufferVerticesStored;
                        TempBufferRenderIndexList[i+4] = RubbishIndexList[4] + TempBufferVerticesStored;
                        TempBufferRenderIndexList[i+5] = RubbishIndexList[5] + TempBufferVerticesStored;
                        TempBufferVerticesStored += 4;
                        TempBufferIndicesStored += 6;
                    ]]
                    dxDrawLine3D(pos.x + vx1 + vx2, pos.y + vy1 + vy2, pos.z,pos.x + vx1 - vx2, pos.y + vy1 - vy2, pos.z)
                    setElementPosition(textMarker, pos.x + vx1 + vx2, pos.y + vy1 + vy2, pos.z)
                    dxDrawMaterialPrimitive3D("trianglestrip", mat, false, unpack( SheetPrimitive ) )

                end
               

            end
        end	
    end
    --[[
        RwRenderStateSet(rwRENDERSTATEFOGENABLE, (void*)FALSE);
        RwRenderStateSet(rwRENDERSTATEZWRITEENABLE, (void*)FALSE);
        RwRenderStateSet(rwRENDERSTATEVERTEXALPHAENABLE, (void*)TRUE);
    ]]
end

function CRubbish:update() 
    local foundGround = false

    -- FRAMETIME
    if self.bRubbishInvisible then 
        self.rubbishVisibility = max(self.rubbishVisibility-5,0)
    else
        self.rubbishVisibility = min(self.rubbishVisibility+5,255)
    end
    -- Spawn a new sheet
    local sheet = self.startEmptyList.m_next;
    if sheet ~= self.startEmptyList then 
        local spawnDist = bitAnd(random(0,UINT16_MAX),0xFF)/256 * SKYGFX.rubbish_max_dist;
		local spawnAngle
        local r = random(0,UINT16_MAX)
        if bitAnd(r,1) then 
            spawnAngle = bitAnd(random(0,UINT16_MAX),0xFF)/256 * 6.28
        else
            local _,_,z = getElementRotation(getCamera())
            spawnAngle = (r-128)/160.0 + z;
        end
        local cx,cy,cz = getCameraMatrix()
        foundGround = getGroundPosition(cx,cy, cz+0.1)
        if foundGround ~= 0 and foundGround ~= false then
            sheet.m_basePos.x = cx + spawnDist*sin(spawnAngle);
            sheet.m_basePos.y = cy + spawnDist*cos(spawnAngle);
            sheet.m_basePos.z = foundGround + 0.1
            -- Found ground, so add to statics list
			sheet.m_angle = bitAnd(random(0,UINT16_MAX),0xFF)/256 * 6.28;
			sheet.m_state = 1
            --[[ CULL ZONE IS NOT SUPPORT BY MTA AT NOW
			if(CCullZones::FindAttributesForCoors(sheet->m_basePos, nil) & ATTRZONE_NORAIN)
				sheet->m_isVisible = false;
			else
				sheet->m_isVisible = true;
            --]]
            sheet.m_isVisible = true
			sheet:removeFromList()
			sheet:addToList(self.startStaticsList)
            
        end
		
    end

    -- Process animation
	sheet = self.startMoversList.m_next
	while sheet ~= self.endMoversList do
        local currentTime = getTickCount() - sheet.m_moveStart
		if currentTime < sheet.m_moveDuration then
			--// Animation
			local step = 16 * currentTime / sheet.m_moveDuration	-- 16 steps in animation
			local stepTime = sheet.m_moveDuration/16	-- time in each step
			local s = (currentTime - stepTime*step) / stepTime	-- position on step
			local t = currentTime / sheet.m_moveDuration	-- position on total animation
           
			-- factors for xy and z-movment
			local fxy = aAnimations[sheet.m_animationType][step]*(1.0-s) + aAnimations[sheet.m_animationType][step+1]*s
			local fz = aAnimations[sheet.m_animationType][step+17]*(1.0-s) + aAnimations[sheet.m_animationType][step+1+17]*s
            
			sheet.m_animatedPos.x = sheet.m_basePos.x + fxy*sheet.m_xDist
			sheet.m_animatedPos.y = sheet.m_basePos.y + fxy*sheet.m_yDist
			sheet.m_animatedPos.z = (1.0-t)*sheet.m_basePos.z + t*sheet.m_targetZ + fz*sheet.m_animHeight
			sheet.m_angle = sheet.m_angle + getGameSpeed()*0.04
            
			if sheet.m_angle > 6.28 then
				sheet.m_angle = sheet.m_angle - 6.28
            end
			sheet = sheet.m_next;
		else
			-- End of animation, back into statics list
			sheet.m_basePos.x = sheet.m_basePos.x + sheet.m_xDist
			sheet.m_basePos.y = sheet.m_basePos.y + sheet.m_yDist
			sheet.m_basePos.z = sheet.m_targetZ
			sheet.m_state = 1
			sheet.m_isVisible = sheet.m_targetIsVisible

			local next = sheet.m_next
			sheet:removeFromList()
			sheet:addToList(self.startStaticsList)
			sheet = next
        end
	end
 
 
    -- Stir up a sheet by wind
	-- FRAMETIME
    local vecWind = Vector3(getWindVelocity ()):getLength()
    
    local freq;
	if vecWind < 0.1 then
		freq = 31
    elseif vecWind < 0.4 then
		freq = 7
	elseif vecWind < 0.7 then
		freq = 1
	else
		freq = 0
    end
   
    
    if bitAnd(m_FrameCounter,freq) == 0 then
        local i = random(1,SKYGFX.num_rubbish_sheets)
        --print(i)
        if aSheets[i].m_state == 1 then
			aSheets[i].m_moveStart = getTickCount()
			aSheets[i].m_moveDuration = vecWind*1500.0 + 1000.0;
			aSheets[i].m_animHeight = 0.2;
			aSheets[i].m_xDist = 3.0*vecWind;
			aSheets[i].m_yDist = 3.0*vecWind;
            -- Check if target position is ok
			local tx = aSheets[i].m_basePos.x + aSheets[i].m_xDist;
			local ty = aSheets[i].m_basePos.y + aSheets[i].m_yDist;
			local tz = aSheets[i].m_basePos.z + 3.0;
			-- Check if target position is ok
            local foundGround = getGroundPosition(tx, ty, tz) + 0.1
            if foundGround ~= 0 or foundGround ~= false then
                local tx = aSheets[i].m_basePos.x + aSheets[i].m_xDist
                local ty = aSheets[i].m_basePos.y + aSheets[i].m_yDist
                local tz = aSheets[i].m_basePos.z + 3.0
                aSheets[i].m_targetZ = foundGround

                --[[ NO CULL ZONE
                if CCullZones::FindAttributesForCoors(CVector(tx, ty, aSheets[i].m_targetZ), nil) & ATTRZONE_NORAIN then
                    aSheets[i].m_targetIsVisible = false
                else
                    aSheets[i].m_targetIsVisible = true
                end
                --]]
                -- start animation
                aSheets[i].m_state = 2
                aSheets[i].m_animationType = 1
                aSheets[i]:removeFromList()
                aSheets[i]:addToList(self.startMoversList)

            end
		end
    end
    -- Remove sheets that are too far away
	local last = (m_FrameCounter % (SKYGFX.num_rubbish_sheets/4))*4 + 1
	for i = (m_FrameCounter % (SKYGFX.num_rubbish_sheets/4))*4, last do
        i = i == 0 and 1 or i
        local cx,cy,cz = getCameraMatrix()
		if aSheets[i].m_state == 1 and getDistanceBetweenPoints2D(aSheets[i].m_basePos.x,aSheets[i].m_basePos.y,cx, cy) > math.sqrt(SKYGFX.rubbish_max_dist+1) then
			aSheets[i].m_state = 0;
			aSheets[i]:removeFromList()
			aSheets[i]:addToList(self.startEmptyList)
        end
	end

    m_FrameCounter = m_FrameCounter + 1
end

function CRubbish:init()
    -- init aSheets array
    for i = 1,SKYGFX.num_rubbish_sheets do 
        aSheets[i] = table.clone(cSheet)
    end

    for i = 1,SKYGFX.num_rubbish_sheets do 
        if i < SKYGFX.num_rubbish_sheets then 
            aSheets[i].m_next = aSheets[i+1]
        else
            aSheets[i].m_next = self.endEmptyList          
        end 
        if i > 1 then 
            aSheets[i].m_prev = aSheets[i-1]
        else
            aSheets[i].m_prev = self.startEmptyList
        end
    end
    
    self.startEmptyList.m_next = aSheets[1]
	self.startEmptyList.m_prev = nil
	self.endEmptyList.m_next = nil
	self.endEmptyList.m_prev = aSheets[SKYGFX.num_rubbish_sheets]

	self.startStaticsList.m_next = self.endStaticsList
	self.startStaticsList.m_prev = nil
	self.endStaticsList.m_next = nil
	self.endStaticsList.m_prev = self.startStaticsList

	self.startMoversList.m_next = self.endMoversList
	self.startMoversList.m_prev = nil
    
	self.endMoversList.m_next = nil
	self.endMoversList.m_prev = self.startMoversList

   


    self.rubbishIndexList = {
        0,1,2,1,3,2
    }

    self.gpRubbishTexture["leaf"] = dxCreateTexture("txd/gameleaf01_64.png")
    self.gpRubbishTexture["leaf2"] = dxCreateTexture("txd/gameleaf02_64.png")
    self.gpRubbishTexture["leaf2"] = dxCreateTexture("txd/newspaper01_64.png")
    self.gpRubbishTexture["leaf2"] = dxCreateTexture("txd/newspaper02_64.png")

    self.bRubbishInvisible = false
    self.rubbishVisibility = 255
end
