-- Script by ren712 & moditfied by nurupo
--
-- c_main.lua
--
local shader = nil
local scx, scy = guiGetScreenSize()
--normalize(xyz);
addEventHandler( "onClientResourceStart", resourceRoot,function()
	sunShader = dxCreateShader("RTOutput_sun.fx")
	starTex = dxCreateTexture("coronastar.png", "argb")
	if not sunShader or not starTex then return end
	dxSetShaderValue( sunShader, "fViewportSize", scx, scy )
	dxSetShaderValue( sunShader, "bResAspectBug", true )
	dxSetShaderValue( sunShader, "sTexStar", starTex  )
	
end)


--getFogDistance
addEventHandler( "onClientPreRender", root, function()
	if not sunShader then return end
	local c1r, c1g, c1b, c2r, c2g, c2b = getSunColor()
	local sunSize = getSunSize()
	dxSetShaderValue( sunShader, "sSunColor1", c1r / 255, c1g / 255, c1b / 255, 1  )
	dxSetShaderValue( sunShader, "sSunColor2", c2r / 255, c2g / 255, c2b / 255, 1  )
	dxSetShaderValue( sunShader, "sSunSize", sunSize  )
	-- update the sun position
	local h,m =	getTime()
	s = m
	sunAngle = (m + 60 * h + s/60.0) * 0.0043633231;
	x = 0.7 + math.sin(sunAngle);
	y = -0.7;
	z = 0.2 - math.cos(sunAngle);
	dxSetShaderValue( sunShader, "sSunVec",{x,y+1.5,z} )
	dxDrawMaterialPrimitive3D( "trianglestrip", sunShader, false, unpack( trianglestrip.quad1x1 ) )	
end)

---------------------------------------------------------------------------------------------------
-- material primitive functions
---------------------------------------------------------------------------------------------------
trianglestrip = {}
trianglestrip.quad1x1 = {
    {-1, -1, 0, tocolor(255, 255, 255), 0, 0}, 
    {-1, 1, 0, tocolor(255, 255, 255), 0, 1}, 
    {1, -1, 0, tocolor(255, 255, 255), 1, 0},
    {1, 1, 0, tocolor(255, 255, 255), 1, 1}
}