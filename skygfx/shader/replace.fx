#include "mta-helper.fx"
texture tex < string textureState="0,Texture"; >;
float brightness = 1;

sampler2D Sampler0 = sampler_state
{
    Texture = (tex);
};

struct VS_INPUT {
    float3 position : POSITION;
    float2 texCoord0 : TEXCOORD0;
    float4 color		: COLOR0;
};

struct PS_INPUT
{
	float4 Position		: POSITION;
	float2 Texcoord0	: TEXCOORD0;
	float4 color		: COLOR0;
};

PS_INPUT main_vs(VS_INPUT IN) {
    PS_INPUT OUT;

    OUT.Position = mul(float4(IN.position,1), gWorldViewProjection ) * 0;
 

    OUT.Texcoord0 = IN.texCoord0;
    OUT.color = IN.color;

    return OUT;
}

float4 main_ps(PS_INPUT IN) : COLOR
{
    return tex2D(Sampler0,IN.Texcoord0)  *IN.color ;
	//return float4(1,0,0,1);
}
technique simplePS
{
    pass P0
    {
        VertexShader = compile vs_2_0 main_vs();
        PixelShader  = compile ps_2_0 main_ps();
    }

}
