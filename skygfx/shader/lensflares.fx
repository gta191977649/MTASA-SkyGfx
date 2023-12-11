texture screenSource;
texture sunLight;
texture lensDirt;
texture lensChroma;

float2 sunPos = float2(0, 0);
float4 sunColor = float4(1, 1, 1, 1);

float2 screenSize = (1, 1);
float blurSize = 3;

sampler ScreenSourceSampler = sampler_state
{
    Texture = (screenSource);
	MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};

sampler SunSampler = sampler_state
{
    Texture = (sunLight);
	MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};

sampler LensDirtSampler = sampler_state
{
    Texture = (lensDirt);
	MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};

sampler LensChromaSampler = sampler_state
{
    Texture = (lensChroma);
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
	
    Color += tex2D(SunSampler, float2(Tex.x - 3.0*blurSizeX, Tex.y)) * 0.09f;
    Color += tex2D(SunSampler, float2(Tex.x - 2.0*blurSizeX, Tex.y)) * 0.11f;
    Color += tex2D(SunSampler, float2(Tex.x - blurSizeX, Tex.y)) * 0.18f;
    Color += tex2D(SunSampler, Tex) * 0.24f;
    Color += tex2D(SunSampler, float2(Tex.x + blurSizeX, Tex.y)) * 0.18f;
    Color += tex2D(SunSampler, float2(Tex.x + 2.0*blurSizeX, Tex.y)) * 0.11f;
    Color += tex2D(SunSampler, float2(Tex.x + 3.0*blurSizeX, Tex.y)) * 0.09f;

    return Color;
}

float4 BlurVertical(float2 Tex : TEXCOORD0)
{
    float4 Color = 0;
	
	float blurSizeY = (1 / screenSize.x) * blurSize;

    Color += tex2D(SunSampler, float2(Tex.x, Tex.y - 3.0*blurSizeY)) * 0.09f;
    Color += tex2D(SunSampler, float2(Tex.x, Tex.y - 2.0*blurSizeY)) * 0.11f;
    Color += tex2D(SunSampler, float2(Tex.x, Tex.y - blurSizeY)) * 0.18f;
    Color += tex2D(SunSampler, Tex) * 0.24f;
    Color += tex2D(SunSampler, float2(Tex.x, Tex.y + blurSizeY)) * 0.18f;
    Color += tex2D(SunSampler, float2(Tex.x, Tex.y + 2.0*blurSizeY)) * 0.11f;
    Color += tex2D(SunSampler, float2(Tex.x, Tex.y + 3.0*blurSizeY)) * 0.09f;

    return Color;
}
 

float4 LensflarePixelShader(float2 texCoords : TEXCOORD) : COLOR
{
	float4 mainColor = tex2D(ScreenSourceSampler, texCoords);
	float4 godRayColorRaw = tex2D(SunSampler, texCoords);
	float4 godrayColorV = BlurVertical(texCoords);
	float4 godrayColorH = BlurHorizontal(texCoords);
	
	float4 finalGodRayColor = (godrayColorV + godrayColorH + godRayColorRaw) / 3;
	
	float4 lensFlare1 = tex2D(LensDirtSampler, texCoords + sunPos / 2);
	float4 lensFlare2 = tex2D(LensDirtSampler, texCoords * sunPos);
	float4 lensFlare3 = tex2D(LensDirtSampler, (texCoords * 0.5) - sunPos / 2);

	float4 finalLensFlareDirt = (lensFlare1 + lensFlare2 + lensFlare3) / 2;
	float4 lensFlareChroma = tex2D(LensChromaSampler, texCoords + sunPos / 12);
	
	finalGodRayColor *= 1.1;
	
	lensFlareChroma *= finalLensFlareDirt;
	lensFlareChroma *= 0.8;

	finalLensFlareDirt *= finalGodRayColor;
	finalLensFlareDirt *= 1.3;
	
	float4 finalLensflareColor = finalGodRayColor + finalLensFlareDirt;
	
	finalLensflareColor *= sunColor;
	finalLensflareColor += lensFlareChroma;
	
	float distFromCenter = distance(sunPos, texCoords);
	float4 vignetteColor = lerp(float4(1, 1, 1, 1), float4(0, 0, 0, 1), saturate(distFromCenter) );
	
	finalLensflareColor *= vignetteColor;
	
	float4 finalColor = mainColor + finalLensflareColor;
	
	return finalColor;
}
 

technique LensFlares
{
	pass p0
    {
		AlphaBlendEnable	= true;
		PixelShader = compile ps_2_0 LensflarePixelShader();
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