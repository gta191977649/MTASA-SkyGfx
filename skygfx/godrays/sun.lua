
Sun = {}

function Sun:constructor(parent)
	self.parent = parent
	self.player = localPlayer
	
	self.isDebugMode = "false"
	
	self.x = 0
	self.y = 0
	self.z = 0
	self.rx = 0
	self.ry = 0
	self.rz = 0
	self.height = 100
	self.posVec = {0,0,0}
	
	self.rzOffset = 0
	self.heightCurrentOffset = 0
	self.heightMinOffset = 100
	self.heightMaxOffset = 250
	self.heightOffsetDirection = "up"

	self.m_Update = function() self:update() end
	addEventHandler("onClientRender", root, self.m_Update)
	
	self.m_ToggleTestMode = function() self:toggleTestMode() end
	--bindKey("N", "down", self.m_ToggleTestMode)
end

function Sun:toggleTestMode()
	if (self.isDebugMode == "true") then
		self.isDebugMode = "false"
	elseif (self.isDebugMode == "false") then
		self.isDebugMode = "true"
	end
end

function Sun:update()
	self.px, self.py, self.pz = getElementPosition(self.player)
	self.x, self.y, self.z = getAttachedPosition(self.px, self.py, self.pz, self.rx, self.ry, self.rz + self.rzOffset, 1500, 0, self.height + self.heightCurrentOffset)
	
	--update the sun position
	local h,m =	getTime()
	s = m
	sunAngle = (m + 60 * h + s/60.0) * 0.0043633231;
	local x = 0.7 + math.sin(sunAngle);
	local y = -0.7;
	local z = 0.2 - math.cos(sunAngle);
	--local vecPlayer = getCamera().matrix:getPosition()
	local vecPlayer = getLocalPlayer().matrix:getPosition()

	local sunVec = vecPlayer + Vector3(x,y,z) * SKYGFX.sunZTestLength 
	self.x = sunVec.x
	self.y = sunVec.y
	self.z = sunVec.z

	
	--self.posVec = {x,y,z}
	if SKYGFX.debug then
		dxDrawLine3D(vecPlayer.x,vecPlayer.y,vecPlayer.z,sunVec.x,sunVec.y,sunVec.z, tocolor(255, 255, 0, 255), 4)
	end
	-- print(vecPlayer.x,vecPlayer.y,vecPlayer.z)
	-- print(sunVec.x,sunVec.y,sunVec.z)
end

function time2Height(time)
	return (0.0181*math.pow(time,6)) - (1.1807*math.pow(time,5)) + (30.636*math.pow(time,4)) - (407.98*math.pow(time,3)) + (2965.1*math.pow(time,2)) - (11005*time) + 16238
end
function time2RzOff(t)
	return 0.0222*t^4 - (0.9552*t^3) + 13.675 * t^2 - (80.193*t) + 405.73
end

function Sun:getSunPosition()
	return self.x, self.y, self.z
end

function Sun:destructor()	
	removeEventHandler("onClientRender", root, self.m_Update)

end