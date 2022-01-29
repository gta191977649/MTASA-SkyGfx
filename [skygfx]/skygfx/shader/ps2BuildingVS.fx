#include "mta-helper.fx"

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


struct VS_INPUT
{
	float4 Position		: POSITION;
	float3 TexCoord		: TEXCOORD0;
	float4 NightColor	: COLOR0;
	float4 DayColor		: COLOR1;
};

struct VS_OUTPUT {
	float4 Position		: POSITION;
	float3 Texcoord0	: TEXCOORD0;
	float4 Color		: COLOR0;
};

VS_OUTPUT main(in VS_INPUT IN)
{
	VS_OUTPUT OUT;

	OUT.Position = mul(float4(IN.Position), gWorldViewProjection);
	//OUT.Texcoord0 = mul(texmat, float4(IN.TexCoord, 0.0, 1.0)).xy;
	OUT.Texcoord0.xy = IN.TexCoord.xy;
	OUT.Color = IN.DayColor*dayparam + IN.NightColor*nightparam;
	OUT.Color *= matCol / colorScale;
	OUT.Color.rgb += ambient*surfAmb;
	OUT.Texcoord0.z = clamp((OUT.Position.w - fogEnd)*fogRange, fogDisable, 1.0);
	return OUT;
}

technique ps2_building_pipeline
{
    pass P0
    {
        VertexShader = compile vs_2_0 main();
    }
   
}