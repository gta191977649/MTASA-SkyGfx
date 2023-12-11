local sunPreRotation = {25, 0, 0}
local timeHMS = {0,0,0}
local minuteStartTickCount
local minuteEndTickCount

----------------------------------------------------------------
-- Math helper functions
----------------------------------------------------------------
function math.lerp(from,alpha,to)
    return from + (to-from) * alpha
end

function math.unlerp(from,pos,to)
	if ( to == from ) then
		return 1
	end
	return ( pos - from ) / ( to - from )
end

function math.clamp(low,value,high)
    return math.max(low,math.min(value,high))
end

function math.unlerpclamped(from,pos,to)
	return math.clamp(0,math.unlerp(from,pos,to),1)
end

function eulerToVectorXY(rotX, rotY, rotZ)
	local sinX = math.sin(rotX) local cosX = math.cos(rotX)
	local sinY = math.sin(-rotY) local cosY = math.cos(-rotY)	
	return cosX*sinY,sinX,cosX*cosY
end
function getTimeHMS()
    local h, m = getTime ()
    local s = 0
    if m ~= timeHMS[2] then
        minuteStartTickCount = getTickCount ()
        local gameSpeed = math.clamp( 0.01, getGameSpeed(), 10 )
        minuteEndTickCount = minuteStartTickCount + 1000 / gameSpeed
    end
    if minuteStartTickCount then
        local minFraction = math.unlerpclamped( minuteStartTickCount, getTickCount(), minuteEndTickCount )
        s = math.min ( 59, math.floor ( minFraction * 60 ) )
    end
    return h, m, s
end
function getTimeAspect()
	local ho,mi,se = getTimeHMS()
	return ((( ho * 60 ) + mi ) + ( se / 60 )) / 1440
end

function getNormalAngle(rotation)
	return math.mod( rotation, 360 )
end
function getDynamicSunVector()
    getTimeAspect()
	local vecX, vecY, vecZ = eulerToVectorXY(math.rad(getNormalAngle(sunPreRotation[1])), math.rad(getNormalAngle(( getTimeAspect() * 360 ) + 
	sunPreRotation[2])), math.rad(getNormalAngle(sunPreRotation[3])))
	return vecX, vecY, vecZ
end

function getAttachedPosition(x, y, z, rx, ry, rz, distance, angleAttached, height)
 
    local nrx = math.rad(rx);
    local nry = math.rad(ry);
    local nrz = math.rad(angleAttached - rz);
    
    local dx = math.sin(nrz) * distance;
    local dy = math.cos(nrz) * distance;
    local dz = math.sin(nrx) * distance;
    
    local newX = x + dx;
    local newY = y + dy;
    local newZ = (z + height) - dz;
    
    return newX, newY, newZ;
end