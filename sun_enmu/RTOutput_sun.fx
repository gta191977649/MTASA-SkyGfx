//
// RTOutput_sun.fx
//

//------------------------------------------------------------------------------------------
//-- Settings
//------------------------------------------------------------------------------------------
float2 fViewportSize = float2(800, 600);

bool bResAspectBug = true;
float3 sSunVec = float3(0.65345698595047, 0.40483558177948, 0.63961094617844);
float sSunSize = 2;
float4 sSunColor1 = float4(0,1,0,0.5);
float4 sSunColor2 = float4(0,1,1,0.5);	

//--------------------------------------------------------------------------------------
// Textures
//--------------------------------------------------------------------------------------
texture sTexStar;

//------------------------------------------------------------------------------------------
// Include some common stuff
//------------------------------------------------------------------------------------------
static const float PI = 3.14159265f;
float4x4 gProjection : PROJECTION;
float4x4 gView : VIEW;
float4x4 gViewInverse : VIEWINVERSE;
float gTime : TIME;
int CUSTOMFLAGS < string skipUnusedParameters = "yes"; >;

//------------------------------------------------------------------------------------------
//-- Sampler for the main texture (needed for pixel shaders)
//------------------------------------------------------------------------------------------
sampler2D SamplerStar = sampler_state
{
    Texture = (sTexStar);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = Border;
    AddressV = Border;
    BorderColor = float4(0,0,0,0);
    MaxMipLevel = 0;
    MipMapLodBias = 0;
};


//------------------------------------------------------------------------------------------
// Structure of data sent to the vertex shader
//------------------------------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION0;
    float3 Normal : NORMAL0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//------------------------------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//------------------------------------------------------------------------------------------
// Returns a translation matrix
//------------------------------------------------------------------------------------------
float4x4 makeTranslation( float3 trans) 
{
  return float4x4(
     1,  0,  0,  0,
     0,  1,  0,  0,
     0,  0,  1,  0,
     trans.x, trans.y, trans.z, 1
  );
}

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunctionSun(VSInput VS, uniform float sunSize, uniform float4 sunColor)
{
    PSInput PS = (PSInput)0;
	
    // set proper position and scale of the quad
    VS.Position.xyz = float3(- 0.5 + VS.TexCoord.xy, 0);
	
    VS.Position.xy *= 200 * sunSize;
    VS.Position.xy *= float2(1, 0.75);
	
    // recreate resolution aspect bug for sun
    if (bResAspectBug) VS.Position.y /= (fViewportSize.x / fViewportSize.y) * 0.75;
	
    // create WorldMatrix for the quad
    float farClip = (gProjection[3][2] / (1 - gProjection[2][2]));
    float3 elementPosition = gViewInverse[3].xyz + farClip * normalize(sSunVec);
    float4x4 sWorld = makeTranslation(elementPosition);

    // calculate screen position of the vertex
    float4x4 sWorldView = mul(sWorld, gView);
    float3 sBillView = VS.Position.xyz + sWorldView[3].xyz;
    PS.Position = mul(float4(sBillView, 1), gProjection);

    // pass texCoords and vertex color to PS
    VS.TexCoord.y = 1 - VS.TexCoord.y;
    PS.TexCoord = VS.TexCoord;
	
    PS.Diffuse = sunColor;
	
    return PS;
}

//------------------------------------------------------------------------------------------
// Structure of color data sent to the renderer ( from the pixel shader  )
//------------------------------------------------------------------------------------------
struct Pixel
{
    float4 World : COLOR0;      // Render target #0
    float Depth : DEPTH;        // Depth target
};

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
Pixel PixelShaderFunctionSun(PSInput PS)
{
    Pixel output;
	
    // sample color texture
    float4 finalColor = tex2D(SamplerStar, PS.TexCoord.xy);
    finalColor *= PS.Diffuse;
	
    // output
    output.World = saturate(finalColor);
    output.Depth = 0.9997f;
 
    return output;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique RTOutput_sun
{
  pass P0
  {
    ZEnable = false;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionSun(sSunSize, sSunColor2);
    PixelShader  = compile ps_2_0 PixelShaderFunctionSun();
  }
   pass P1
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionSun(0.46 * sSunSize, sSunColor1);
    PixelShader  = compile ps_2_0 PixelShaderFunctionSun();
  }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
