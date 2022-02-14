rotor = {
    ["GEN"] ={},
    ["HUNTER"] = {}
}

function init()
    -- load model
    -- rotor general
    local x, y, z = getElementPosition(localPlayer)
    rotor["GEN"]["ID_MAIN"] = engineRequestModel("object")
    txd = engineLoadTXD("model/rotor.txd")
    engineImportTXD(txd, rotor["GEN"]["ID_MAIN"])
    dff = engineLoadDFF("model/rotor_gen_main.dff")
    engineReplaceModel(dff, rotor["GEN"]["ID_MAIN"])
    rotor["GEN"]["ID_SIDE"] = engineRequestModel("object")
    engineImportTXD(txd, rotor["GEN"]["ID_SIDE"])
    dff = engineLoadDFF("model/rotor_gen_side.dff")
    engineReplaceModel(dff, rotor["GEN"]["ID_SIDE"])



    -- apply shader
    local myShader = dxCreateShader("rotor.fx")
    local myTexture = dxCreateTexture("model/black64aa.dds", "argb", true, "clamp")
    print(myTexture)
    dxSetShaderValue(myShader,"Tex0",myTexture)
    engineApplyShaderToWorldTexture(myShader, "cargobobrotorblack*")

    engineApplyShaderToWorldTexture(myShader, "black64aa")
end
init()

function getRotorModelByHeliType(heli)
    local heli_id = getElementModel(heli)
    if heli_id == 487 or heli_id == 488 or heli_id == 497 then 
        return rotor["GEN"]["ID_MAIN"],rotor["GEN"]["ID_SIDE"]
    end

    return nil
end

