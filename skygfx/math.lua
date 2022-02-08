local getElementPosition = getElementPosition
local getElementRotation = getElementRotation
cos = math.cos
sin = math.sin
max = math.max
min = math.min
mathSin = sin
mathCos = cos
mathAtan2 = math.atan2
degToPi = math.pi/180
mathAtan = math.atan
mathPi = math.pi
radToDeg = 180/math.pi
degToRad = math.pi/180
mathRandom = math.random
random = math.random

function mathAbs(x)
	return x < 0 and -x or x
end


function angleWrapping(x)
    x = x % 360
    if x < 0 then
        x = x + 360
	end
    return x
end
function getPercentageInLine(x,y,x1,y1,x2,y2)
	x,y = x-x1,y-y1
	local yx,yy = x2-x1,y2-y1
	return (x*yx+y*yy)/(yx*yx+yy*yy)
end

function getAngleInBend(x,y,x0,y0,x1,y1,x2,y2)
	x,y = x-x0,y-y0
	local yx,yy = x1-x0,y1-y0
	local xx,xy = x2-x0,y2-y0
	local rx = (x*yy-y*yx)/(xx*yy-xy*yx)
	local ry = (x*xy-y*xx)/(yx*xy-yy*xx)
	return mathAtan2(rx,ry)
end

function getPosFromBend(ang,x0,y0,x1,y1,x2,y2)
	local yx,yy = x1-x0,y1-y0
	local xx,xy = x2-x0,y2-y0
	local rx,ry = sin(ang),cos(ang)
	return
		rx*xx+ry*yx+x0,
		rx*xy+ry*yy+y0
end

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
	local car = getPedOccupiedVehicle(theElement)
	if car then 
		return (Vector3(getElementVelocity(car)) * mult).length
	end
	return (Vector3(getElementVelocity(theElement)) * mult).length
end

--[[
function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end
--]]
function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end
function getPositionFromElementOffset(element,offx,offy,offz)
	local x,y,z = getElementPosition(element)
	local rx,ry,rz = getElementRotation(element)
    local rx,ry,rz = rx*degToPi,ry*degToPi,rz*degToPi
	local rxCos,ryCos,rzCos,rxSin,rySin,rzSin = cos(rx),cos(ry),cos(rz),sin(rx),sin(ry),sin(rz)
	m11,m12,m13,m21,m22,m23,m31,m32,m33 = rzCos*ryCos-rzSin*rxSin*rySin,ryCos*rzSin+rzCos*rxSin*rySin,-rxCos*rySin,-rxCos*rzSin,rzCos*rxCos,rxSin,rzCos*rySin+ryCos*rzSin*rxSin,rzSin*rySin-rzCos*ryCos*rxSin,rxCos*ryCos
	return offx*m11+offy*m21+offz*m31+x,offx*m12+offy*m22+offz*m32+y,offx*m13+offy*m23+offz*m33+z
end

function getPositionFromOffsetByPosRot(x,y,z,rx,ry,rz,offx,offy,offz)
    local rx,ry,rz = rx*degToPi,ry*degToPi,rz*degToPi
	local rxCos,ryCos,rzCos,rxSin,rySin,rzSin = cos(rx),cos(ry),cos(rz),sin(rx),sin(ry),sin(rz)
	m11,m12,m13,m21,m22,m23,m31,m32,m33 = rzCos*ryCos-rzSin*rxSin*rySin,ryCos*rzSin+rzCos*rxSin*rySin,-rxCos*rySin,-rxCos*rzSin,rzCos*rxCos,rxSin,rzCos*rySin+ryCos*rzSin*rxSin,rzSin*rySin-rzCos*ryCos*rxSin,rxCos*ryCos
	return offx*m11+offy*m21+offz*m31+x,offx*m12+offy*m22+offz*m32+y,offx*m13+offy*m23+offz*m33+z
end

function getRotationMatrix(rx,ry,rz)
    local rx,ry,rz = -rx*degToPi,-ry*degToPi,rz*degToPi
	local rxCos,ryCos,rzCos,rxSin,rySin,rzSin = cos(rx),cos(ry),cos(rz),sin(rx),sin(ry),sin(rz)
	return rzCos*ryCos-rzSin*rxSin*rySin,ryCos*rzSin+rzCos*rxSin*rySin,-rxCos*rySin,-rxCos*rzSin,rzCos*rxCos,rxSin,rzCos*rySin+ryCos*rzSin*rxSin,rzSin*rySin-rzCos*ryCos*rxSin,rxCos*ryCos
end

function getPositionFromOffsetByRotMatrix(x,y,z,offx,offy,offz,m11,m12,m13,m21,m22,m23,m31,m32,m33)
	return offx*m11+offy*m21+offz*m31+x,offx*m12+offy*m22+offz*m32+y,offx*m13+offy*m23+offz*m33+z
end

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end
function isPosVisable(x,y,z) 
    local px,py,pz = getCameraMatrix ()
    --local px,py,pz = getElementPosition(localPlayer)
	
	local clear = isLineOfSightClear(px,py,pz,x,y,z)
	--dxDrawLine3D(px,py,pz,x,y,z,clear and tocolor(0,255,0,255) or tocolor(255,0,0,255),1)
    return clear
end

function getDummyToScreenPos(element,dmmy,dir) 
	dir = dir or "l"
	local offset = dmmy == "light_front_main" and 0.5 or -0.5
	--local offset = 0
	if dir == "l" then
		local fx,fy,fz = getVehicleDummyPosition (element,dmmy)
		local fax,fay,faz = getPositionFromElementOffset(element,fx,fy,fz)
		local sfx,sfy = getScreenFromWorldPosition(fax,fay,faz)

		local ofax,ofay,ofaz = getPositionFromElementOffset(element,fx,fy+offset,fz)
		if fx and fy then
			return sfx,sfy,ofax,ofay,ofaz
		end
	elseif dir == "r" then
		local fx,fy,fz = getVehicleDummyPosition (element,dmmy)
		local fax,fay,faz = getPositionFromElementOffset(element,-fx,fy,fz)
		local sfx,sfy = getScreenFromWorldPosition(fax,fay,faz)
		local ofax,ofay,ofaz = getPositionFromElementOffset(element,-fx,fy+offset,fz)
		if fx and fy then
			return sfx,sfy,ofax,ofay,ofaz
		end
	end
	return false
end

function table.clone(tab)
    if tab== nil then
        return nil
    end
    local copy = {}
    for k, v in pairs(tab) do
        if type(v) == 'table' then
            copy[k] = table.clone(v)
        else
            copy[k] = v
        end
    end
    setmetatable(copy, table.clone(getmetatable(tab)))
    return copy
end
