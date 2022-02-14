local x, y, z = getElementPosition(localPlayer)
local id = engineRequestModel("object")
txd = engineLoadTXD("rotor.txd")
engineImportTXD(txd, id)
dff = engineLoadDFF("rotor.dff")
engineReplaceModel(dff, id)

local rotor = createObject(id,x, y, z)
setElementCollisionsEnabled(rotor,false)
local angle = 0

local myShader_raw_data = [[
	technique replace {
		pass P0 {
            ZEnable = true;
            ZWriteEnable = false;
            ShadeMode = 1;
            AlphaBlendEnable = true;
            SrcBlend = 1;
            DestBlend = 6;
            AlphaTestEnable = true;
            AlphaRef = 1;
            AlphaFunc = 7;
            Lighting = false;
            CullMode = 1;
            DepthBias = 0;
		}
	}
]]

local myShader = dxCreateShader(myShader_raw_data)
local myTexture = dxCreateTexture("black64aa.dds", "argb", true, "clamp")
engineApplyShaderToWorldTexture(myShader, "*",rotor)

addEventHandler( "onClientRender",root,function() 
    if rotor then 
        local veh = getPedOccupiedVehicle(localPlayer)
        if veh and getVehicleType(veh) == "Helicopter" then 
            angle = angle - getHelicopterRotorSpeed (veh) * 60
            attachElements(rotor,veh,0,0,2.5,0,0,angle)
        end
    end
end)


--[[
function onHeliEnter()
    if getVehicleType(source) == "Helicopter" then
        attachElements(rotor,source,0,0,2.5)
    end
 end
addEventHandler ("onClientVehicleEnter", root, onHeliEnter)
]]