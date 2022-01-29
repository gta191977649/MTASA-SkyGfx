#include "mta-helper.fx"

float4x4	combined;
float4		envXform;
float3x3	envmat;
float shininess;
float lightmult;


struct VS_INPUT {
	float4 Position		: POSITION;
	float3 Normal		: NORMAL;
};

struct VS_OUTPUT {
	float4 Position		: POSITION;
	float2 Texcoord0	: TEXCOORD0;
	float4 Envcolor		: COLOR0;
};

VS_OUTPUT main(VS_INPUT IN)
{	
	VS_OUTPUT OUT;
	OUT.Position = mul(combined, IN.Position);

	OUT.Texcoord0 = mul(envmat, IN.Normal).xy - envXform.xy;
	OUT.Texcoord0 *= -envXform.zw;

	OUT.Envcolor = float4(192.0, 192.0, 192.0, 0.0)/128.0*shininess*lightmult;

	return OUT;
}


technique ps2_building_pipeline
{
    pass P0
    {
		AlphaTestEnable= TRUE;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = zwriteThreshold;
        VertexShader = compile vs_2_0 main();
    }
    pass P1
    {
        AlphaTestEnable= TRUE;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = zwriteThreshold;
        VertexShader = compile vs_2_0 main();
    }
   
}