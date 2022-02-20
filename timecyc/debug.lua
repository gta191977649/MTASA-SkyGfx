loadstring(exports.dgs:dgsImportFunction())()-- load functions

local h,m = getTime()
local time = h * 60 + m

debugWin = dgsCreateWindow ( 0.15, 0.33, 0.3, 0.34, "SKYGFX - DEBUG", true )
label_h = dgsCreateLabel(0.02, 0.04, 0.01, 0.1, "HOUR:MIN", true,debugWin)
input_h = dgsCreateEdit( 0.02, 0.1, 0.1, 0.1, math.floor(time/60), true,debugWin)
input_m = dgsCreateEdit( 0.13, 0.1, 0.1, 0.1,time%60, true,debugWin)
label_oldWea = dgsCreateLabel(0.4, 0.04, 0.01, 0.1, "CURRENT WEATHER: "..(Weather.old or 0), true,debugWin)
input_oldWea = dgsCreateEdit( 0.4, 0.1, 0.25, 0.1, Weather.old, true,debugWin)
label_nextWea = dgsCreateLabel(0.7, 0.04, 0.01, 0.1, "BLEND WEATHER: "..(Weather.new or 0), true,debugWin)
input_nextWea = dgsCreateEdit( 0.7, 0.1, 0.25, 0.1,Weather.new, true,debugWin)

label_cyc = dgsCreateLabel(0.02, 0.22, 0.01, 0.1, "TIME CYCLE", true,debugWin)
scroll_timecyc = dgsCreateScrollBar(0.02, 0.28, 0.96, 0.08, true, true,debugWin)

label_int = dgsCreateLabel(0.02, 0.4, 0.01, 0.1, "INTERPOLATION: 0", true,debugWin)
scroll_interp = dgsCreateScrollBar(0.02, 0.46, 0.96, 0.08, true, true,debugWin)
dgsSetProperty(scroll_timecyc,"map",{0,1440})
dgsSetProperty(scroll_interp,"map",{0,1})

function updateUI() 
    local h,m = getTime()
    
    dgsSetProperty(label_cyc,"text",string.format("TIME CYCLE: %d:%d",h,m))
    dgsSetProperty(input_h,"text",h)
    dgsSetProperty(input_m,"text",m)
    dgsSetProperty(label_int,"text",string.format("INTERPOLATION: %f",Weather.interpolation))
    dgsSetProperty(label_oldWea,"text",string.format("CURRENT WEATHER: %d",(Weather.old or 0)))
    dgsSetProperty(label_nextWea,"text",string.format("BLEND WEATHER: %d",(Weather.new or 0)))
end
addEventHandler("onDgsElementScroll",scroll_timecyc,function(source)
    time = dgsScrollBarGetScrollPosition( source )
    local h,m = math.floor(time/60),time%60
    setTime(h,m)
    
    updateUI()
end)

addEventHandler("onDgsElementScroll",scroll_interp,function(source)
    local intp = dgsScrollBarGetScrollPosition( source )
    Weather.interpolation = intp
    updateUI()
end)
addEventHandler("onDgsTextChange", input_oldWea, function() 
    local newOld = dgsGetText(source)
    if tonumber(newOld) then
        setWeather(tonumber(newOld))       
        outputChatBox("Old weather set to: "..newOld)
        updateUI()
    end
end)
addEventHandler("onDgsTextChange", input_nextWea, function() 
    local next = dgsGetText(source)
    if tonumber(next) then
        --Weather.new = tonumber(next)
        Weather.new = tonumber(next)
        outputChatBox("New weather set to: "..next)
        updateUI()
    end
end)


dgsSetVisible(debugWin,false)

addCommandHandler("skygfx",function(cmd)
    showCursor(not dgsGetVisible(debugWin))
    dgsSetVisible(debugWin,not dgsGetVisible(debugWin))    
end)

addEventHandler("onClientRender",root,function()
    updateUI()
end)
