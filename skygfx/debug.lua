loadstring(exports.dgs:dgsImportFunction())()-- load functions

label_debug = dgsCreateLabel(0,0,0,0.5,"SKYGFX CORONAS: 0", true)
dgsSetProperty(label_debug,"alignment",{"left","top"})
dgsSetProperty(label_debug,"shadow",{1,1,tocolor(0,0,0,255),2})
dgsSetProperty(label_debug,"textSize",{1.5,1.5})
