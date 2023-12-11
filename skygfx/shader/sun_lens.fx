texture bwSource;
texture screenSource;

float2 sunPos = (0, 0);
float sunSize = 0.15;
float4 sunColorInner = float4(1, 0.9, 0.6, 1);
float4 sunColorOuter = float4(0.8, 0.7, 0.4, 1);


sampler BWSourceSampler = sampler_state
{
    Texture = (bwSource);
	MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};

sampler ScreenSourceSampler = sampler_state
{
    Texture = (screenSource);
	MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};


float4 SunPixelShader(float2 texCoords : TEXCOORD) : COLOR
{
		
	float4 mainColor = tex2D(ScreenSourceSampler, texCoords);
	float4 bwColor = tex2D(BWSourceSampler, texCoords);
	
    float distfromcenter = distance(sunPos, texCoords);
	float4 lensColor1 = lerp(sunColorOuter, (sunColorOuter / 10) * mainColor.a, saturate(distfromcenter)/sunSize);
	float4 lensColor2 = lerp(sunColorInner, (sunColorInner / 10) * mainColor.a, saturate(distfromcenter)/sunSize / 4);
    float4 finalsSunColor = (lensColor1 + lensColor2) / 2;
	
    finalsSunColor *= bwColor;

	return mainColor + finalsSunColor * mainColor.b;
}


technique SunShader
{
    pass P0
    {
        PixelShader  = compile ps_2_0 SunPixelShader();
    }
}
 
// Fallback
technique Fallback
{
    pass P0
    {
        // Just draw normally
    }
}