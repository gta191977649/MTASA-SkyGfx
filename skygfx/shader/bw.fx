texture gDepthBuffer : DEPTHBUFFER;
matrix gProjectionMainScene : PROJECTION_MAIN_SCENE;

texture screenSource;

float viewDistance = 0.001;
 
sampler SamplerDepth = sampler_state
{
    Texture     = (gDepthBuffer);
    AddressU    = Clamp;
    AddressV    = Clamp;
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
 

float FetchDepthBufferValue( float2 uv )
{
    float4 texel = tex2D(SamplerDepth, uv);
#if IS_DEPTHBUFFER_RAWZ
    float3 rawval = floor(255.0 * texel.arg + 0.5);
    float3 valueScaler = float3(0.996093809371817670572857294849, 0.0038909914428586627756752238080039, 1.5199185323666651467481343000015e-5);
    return dot(rawval, valueScaler / 255.0);
#else
    return texel.r;
#endif
}
 

float Linearize(float posZ)
{
    return gProjectionMainScene[3][2] / (posZ - gProjectionMainScene[2][2]);
}
 

float4 BWPixelShader(float2 texCoords : TEXCOORD) : COLOR
{
    float BufferValue = FetchDepthBufferValue(texCoords);
    float Depth = Linearize(BufferValue);
	
	Depth *= viewDistance;
	
    float4 fogColorFinal = float4(Depth, Depth, Depth, 1);
	
	if (fogColorFinal.r > 0.05) {fogColorFinal.r = 1;}
	if (fogColorFinal.g > 0.05) {fogColorFinal.g = 1;}
	if (fogColorFinal.b > 0.05) {fogColorFinal.b = 1;}
	
    return fogColorFinal;
}
 
 
technique BW
{
    pass P0
    {
        PixelShader  = compile ps_2_0 BWPixelShader();
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