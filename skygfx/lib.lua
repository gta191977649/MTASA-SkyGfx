function addEventHandlerEx(sEventName, pElementAttachedTo, func,pro,priority) 
    if not isEventHandlerAdded( sEventName, pElementAttachedTo, func ) then 
        addEventHandler( sEventName, pElementAttachedTo, func,pro,priority )
    end
end
function removeEventHandlerEx(sEventName, pElementAttachedTo, func ) 
    if isEventHandlerAdded( sEventName, pElementAttachedTo, func ) then 
        removeEventHandler( sEventName, pElementAttachedTo, func )
    end
end

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end