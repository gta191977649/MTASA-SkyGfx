local zTestIgnoreTxds = {
    "coronastar"
}
function noZTest() 
    zTestShader = dxCreateShader("shader/ztest.fx")
    for _,txd in ipairs(zTestIgnoreTxds) do
        engineApplyShaderToWorldTexture(zTestShader, txd)
    end
    
end