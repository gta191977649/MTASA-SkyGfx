#include "mta-helper.fx"
texture tex < string textureState="0,Texture"; >;
float brightness = 1;

sampler2D Sampler0 = sampler_state
{
    Texture = (tex);
};

struct VS_INPUT {
    float3 Position : POSITION0;
    float2 Texcoord0 : TEXCOORD0;
    float4 color		: COLOR0;
};

struct PS_INPUT
{
	float4 Position		: POSITION0;
	float2 Texcoord0	: TEXCOORD0;
	float4 color		: COLOR0;
};

PS_INPUT main_vs(VS_INPUT IN) {
    PS_INPUT OUT;

    IN.Position = float3(- 0.5 + IN.Texcoord0.xy, 0);
    IN.Position.xy *= 500;
    //OUT.Position.xy *= float2(1, 0.75);

    OUT.Position = mul(float4(IN.Position, 1), gProjection);

    OUT.Texcoord0 = IN.Texcoord0;
    OUT.color = IN.color;

    return OUT;
}

float4 main_ps(PS_INPUT IN) : COLOR
{
    return tex2D(Sampler0,IN.Texcoord0)  *IN.color * float4(1,0,0,1) ;
	//return float4(1,0,0,1);
}
technique simplePS
{
    pass P0
    {
         ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
        VertexShader = compile vs_2_0 main_vs();
        PixelShader  = compile ps_2_0 main_ps();
    }

}
