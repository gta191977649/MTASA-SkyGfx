#include "mta-helper.fx"
//float4x4	combined : register(c0);
//float4		envXform;
float		shininess;
float		lightmult;
//float3x3	envmat;




struct VS_INPUT {
	float4 Position		: POSITION;
	float3 Normal		: NORMAL;
    float2 TexCoord : TEXCOORD0;
};

struct VS_OUTPUT {
	float4 Position		: POSITION;
	float2 Texcoord0	: TEXCOORD0;
	float4 Envcolor		: COLOR0;
};

VS_OUTPUT main(VS_INPUT IN)
{

    //float4x4 combined = gWorldViewProjection;
    //float3x3	envmat = (float3x3)gWorld;
	VS_OUTPUT OUT = (VS_OUTPUT)0;
    /*
	OUT.Position = mul(IN.Position, combined);
	OUT.Texcoord0 = mul(envmat, IN.Normal).xy - envXform.xy;
	OUT.Texcoord0 *= -envXform.zw;
    */
    //OUT.Position = mul(float4(IN.Position, 1), gWorldViewProjection);
    OUT.Position = mul(float4(IN.Position), gWorldViewProjection);
    OUT.Texcoord0 = IN.TexCoord;
	OUT.Envcolor = float4(192.0, 192.0, 192.0, 0.0)/128.0*shininess*lightmult;

	return OUT;
}
technique ps2_building_pipeline2
{
    pass P0
    {
        VertexShader = compile vs_2_0 main();
        //PixelShader = compile vs_2_0 main();
    }
}