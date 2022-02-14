renderList = {}
function applyHeliRotorFix(heli)
    local ROTOR_MAIN_ID,CROTOR_SIDE_ID = getRotorModelByHeliType(heli)

    if ROTOR_MAIN_ID == nil then 
        print("Unknown plane, cannot apply fix.")
        return 
    end
    --create objects
    renderList[heli] = {}
    renderList[heli].a = 0
    renderList[heli].rotor_main = createObject(ROTOR_MAIN_ID,0, 0,0)
    setElementCollisionsEnabled(renderList[heli].rotor_main,false)
    setElementDoubleSided(renderList[heli].rotor_main,true)


    renderList[heli].rotor_side = createObject(CROTOR_SIDE_ID,0, 0,0)
    setElementCollisionsEnabled(renderList[heli].rotor_side,false)
    setElementDoubleSided(renderList[heli].rotor_side,true)
    
    --print("Rotor fixed apply")
end

function removeHeliRotorFix(heli)
    if renderList[heli] ~= nil then 
        destroyElement(renderList[heli].rotor_main)
        destroyElement(renderList[heli].rotor_side)
        renderList[heli] = nil
        --print("Rotor fixed removed")
    end
end

function renderRotorEffect() 
    for heli,v in pairs(renderList) do 
        local spd = getHelicopterRotorSpeed (heli) * 70
        --print(spd)
        if spd > 0 then 
            v.a = v.a - spd
        end
        local a = spd / 0.051 > 255 and 255 or spd / 0.051
        setElementAlpha(v.rotor_main,a)
        setElementAlpha(v.rotor_side,a)
        attachElements(v.rotor_main,heli,0,0,2.5,0,0,v.a)
        attachElements(v.rotor_side,heli,-0.1,-7.45,1.25,v.a,0,0)
    end

end

addEventHandler("onClientRender",root,renderRotorEffect)

addEventHandler( "onClientElementStreamIn", root,
    function ( )
        if getElementType( source ) == "vehicle" then
            if getVehicleType(source) == "Helicopter" or getVehicleType(source) == "Plane" then
                if renderList[source] == nil then 
                    applyHeliRotorFix(source)
                    
                end
            end
        end
    end
);

addEventHandler( "onClientElementStreamOut", root,
    function ( )
        if renderList[source] ~= nil then 
            removeHeliRotorFix(source)
        end
    end
);


-- test cmd
addCommandHandler ( "rotor", function() 
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh and getVehicleType(veh) == "Helicopter" then 
        applyHeliRotorFix(veh)
    else
        outputChatBox( "You are not in a helicopter!")
    end
end) 
