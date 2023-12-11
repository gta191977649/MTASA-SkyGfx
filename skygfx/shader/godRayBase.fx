texture renderTargetBW;
texture renderTargetSun;
texture screenSource;

float2 screenSize = (1, 1);
float blurSize = 6;

sampler RenderTargetBWSampler = sampler_state
{
    Texture = (renderTargetBW);
	MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};

sampler RenderTargetSunSampler = sampler_state
{
    Texture = (renderTargetSun);
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


float4 BlurHorizontal(float2 Tex : TEXCOORD0)
{
    float4 Color = 0;
	
	float blurSizeX = (1 / screenSize.x) * blurSize;
	
    Color += tex2D(RenderTargetBWSampler, float2(Tex.x - 3.0*blurSizeX, Tex.y)) * 0.09f;
    Color += tex2D(RenderTargetBWSampler, float2(Tex.x - 2.0*blurSizeX, Tex.y)) * 0.11f;
    Color += tex2D(RenderTargetBWSampler, float2(Tex.x - blurSizeX, Tex.y)) * 0.18f;
    Color += tex2D(RenderTargetBWSampler, Tex) * 0.24f;
    Color += tex2D(RenderTargetBWSampler, float2(Tex.x + blurSizeX, Tex.y)) * 0.18f;
    Color += tex2D(RenderTargetBWSampler, float2(Tex.x + 2.0*blurSizeX, Tex.y)) * 0.11f;
    Color += tex2D(RenderTargetBWSampler, float2(Tex.x + 3.0*blurSizeX, Tex.y)) * 0.09f;

    return Color;
}

float4 BlurVertical(float2 Tex : TEXCOORD0)
{
    float4 Color = 0;
	
	float blurSizeY = (1 / screenSize.x) * blurSize;

    Color += tex2D(RenderTargetBWSampler, float2(Tex.x, Tex.y - 3.0*blurSizeY)) * 0.09f;
    Color += tex2D(RenderTargetBWSampler, float2(Tex.x, Tex.y - 2.0*blurSizeY)) * 0.11f;
    Color += tex2D(RenderTargetBWSampler, float2(Tex.x, Tex.y - blurSizeY)) * 0.18f;
    Color += tex2D(RenderTargetBWSampler, Tex) * 0.24f;
    Color += tex2D(RenderTargetBWSampler, float2(Tex.x, Tex.y + blurSizeY)) * 0.18f;
    Color += tex2D(RenderTargetBWSampler, float2(Tex.x, Tex.y + 2.0*blurSizeY)) * 0.11f;
    Color += tex2D(RenderTargetBWSampler, float2(Tex.x, Tex.y + 3.0*blurSizeY)) * 0.09f;

    return Color;
}

float4 GodrayBasePixelShader(float2 texCoord : TEXCOORD) : COLOR0
{
	float4 mainColor = tex2D(ScreenSourceSampler, texCoord);
	float4 bwColor = tex2D(RenderTargetBWSampler, texCoord);
	float4 sunColor = tex2D(RenderTargetSunSampler, texCoord);
	float4 sunColor2 = tex2D(RenderTargetSunSampler, texCoord) * 0.4;
	float4 invertedBWColor = float4(bwColor.a - bwColor.rgb, bwColor.a);
	
	sunColor *= bwColor;
	
    float4 color1 = BlurHorizontal(texCoord);
	float4 color2 = BlurVertical(texCoord);
    
	float4 finalColor = (color1 + color2) / 2;
	finalColor *= invertedBWColor;
	finalColor += sunColor + sunColor2;
	finalColor *= 1.5;
	
    return finalColor; 
}

technique GodrayBase
{
    pass
    {
        PixelShader = compile ps_2_0 GodrayBasePixelShader();
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