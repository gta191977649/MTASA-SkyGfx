#include "mta-helper.fx"

texture tex < string textureState="0,Texture"; >;

float zwriteThreshold = 128;
float brightness = 1;

//float4x4	combined; we use the transform matrix from MTA instead
float3		ambient;
float4		matCol;
float4		dayparam;
float4		nightparam;
//float4x4	texmat; we use the transform matrix from MTA instead
float 		colorScale;
float 		surfAmb;
float  		fogStart;
float 		fogEnd;
float 		fogRange;
bool 		fogDisable;


sampler Sampler0 = sampler_state 
{
    Texture = (tex);
};


struct VS_INPUT
{
	float4 Position		: POSITION;
	float3 TexCoord		: TEXCOORD0;
	float4 NightColor	: COLOR0;
	float4 DayColor		: COLOR1;
};

struct VS_OUTPUT {
	float4 Position		: POSITION;
	float3 Texcoord	    : TEXCOORD0;
	float4 Color		: COLOR0;
};


struct PS_INPUT
{
	float3 texcoord0	: TEXCOORD0;
	float4 color		: COLOR0;
};

VS_OUTPUT main_vs(in VS_INPUT IN)
{
	VS_OUTPUT OUT;

	OUT.Position = mul(float4(IN.Position), gWorldViewProjection);
	//OUT.Texcoord0 = mul(texmat, float4(IN.TexCoord, 0.0, 1.0)).xy;
	OUT.Texcoord = IN.TexCoord;
	OUT.Color = IN.DayColor*dayparam + IN.NightColor*nightparam;
	OUT.Color *= matCol / colorScale;
	OUT.Color.rgb += ambient*surfAmb;
	OUT.Texcoord.z = clamp((OUT.Position.w - fogEnd)*fogRange, fogDisable, 1.0);

    
	return OUT;
}

float4 main_ps(PS_INPUT IN) : COLOR
{
	return tex2D(Sampler0, IN.texcoord0.xy)*IN.color*colorScale * brightness;
}

technique simplePS
{
    pass P0
    {
        /*
            flags & (rxGEOMETRY_TEXTURED2 | rxGEOMETRY_TEXTURED:
                RwD3D9SetTexture(texture, 0);
                RwD3D9SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);
                RwD3D9SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
                RwD3D9SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
                RwD3D9SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
                RwD3D9SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
                RwD3D9SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
        */
        ColorOp[0] = MODULATE;//D3DTOP_MODULATE - 0x4
        ColorArg1[0] = TEXTURE;//D3DTA_TEXTURE - 0x2
        ColorArg2[0] = DIFFUSE;//D3DTA_DIFFUSE - 0x0
        AlphaOp[0] = MODULATE;//D3DTOP_MODULATE - 0x4
        AlphaArg1[0] = TEXTURE;//D3DTA_TEXTURE - 0x2
        AlphaArg2[0] = DIFFUSE;//D3DTA_DIFFUSE - 0x0
        
 
        AlphaTestEnable= true;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = zwriteThreshold;
        ZFunc = LESSEQUAL;
        zWriteEnable = true;
        VertexShader = compile vs_2_0 main_vs();
        PixelShader  = compile ps_2_0 main_ps();
    }
    pass P1 {
       
        ZWriteEnable = false;
        AlphaRef = 1;
        
        VertexShader = compile vs_2_0 main_vs();
        PixelShader  = compile ps_2_0 main_ps();



    }

}
