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
}
aSheets = {}

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
	{ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
	  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 },
	--Normal move
	{ 0.0, 0.05, 0.12, 0.25, 0.42, 0.57, 0.68, 0.8, 0.86, 0.9, 0.93, 0.95, 0.96, 0.97, 0.98, 0.99, 1.0,	--// XY movemnt
	  0.15, 0.35, 0.6, 0.9, 1.2, 1.25, 1.3, 1.2, 1.1, 0.95, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0 },	--// Z movement
	--Stirred up by ast vehicle
	{ 0.0, 0.05, 0.12, 0.25, 0.42, 0.57, 0.68, 0.8, 0.95, 1.1, 1.15, 1.18, 1.15, 1.1, 1.05, 1.03, 1.0,
	  0.15, 0.35, 0.6, 0.9, 1.2, 1.25, 1.3, 1.2, 1.1, 0.95, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0 }
};

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

textMarker = createMarker(0, 0, 0, "cylinder", 1, 255, 255, 255, 255)
function CRubbish:render() 
    for type,mat in pairs(self.gpRubbishTexture) do
        local tempBufferIndicesStored = 0
		local tempBufferVerticesStored = 0
        for idx,sheet in ipairs(aSheets) do
            if sheet.m_state ~= 0 then
                local pos
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

function CRubbish:Update() 
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
        local spawnDist = random(0,100) * SKYGFX.rubbish_max_dist * 0.01;
		local spawnAngle
        local r = random(0,1)
        if r == 1 then 
            spawnAngle = random(0,359) 
        else
            local _,_,z = getElementRotation(getCamera())
            spawnAngle = z;
        end
        local cx,cy,cz = getCameraMatrix()
        foundGround = getGroundPosition(cx,cy, cz+0.1)
        if foundGround ~= 0 and foundGround ~= false then
            sheet.m_basePos.x = cx + spawnDist*sin(spawnAngle);
            sheet.m_basePos.y = cy + spawnDist*cos(spawnAngle);
            sheet.m_basePos.z = foundGround
            -- Found ground, so add to statics list
			sheet.m_angle = spawnAngle
			sheet.m_state = 1
            --[[ CULL ZONE IS NOT SUPPORT BY MTA AT NOW
			if(CCullZones::FindAttributesForCoors(sheet->m_basePos, nil) & ATTRZONE_NORAIN)
				sheet->m_isVisible = false;
			else
				sheet->m_isVisible = true;
            --]]
            sheet.m_isVisible = true
			removeFromList(sheet)
			addToList(sheet,self.startStaticsList)
        end
		
    end

    -- Process animation
	sheet = self.startMoversList.m_next
	while sheet ~= self.endMoversList do
        print(getTickCount())
	end

    local vecWind = Vector3(getWindVelocity ())
    --print(vecWind:getLength())
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
	self.endEmptyList.m_prev = aSheets[SKYGFX.num_rubbish_sheets-1]

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

    self.bRubbishInvisible = false
    self.rubbishVisibility = 255
end
