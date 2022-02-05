#include "mta-helper.fx"

texture tex < string textureState="0,Texture"; >;
float3 amb = float3(1,1,1);
bool backfacecull = false;

//float tmpintensity = 1;

sampler Sampler0 = sampler_state
{
    Texture = (tex);
};

struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};
float4 main(PSInput PS) : COLOR
{
	//-- Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord);
    //-- Apply diffuse lighting
 
    texel.r +=  texel.r * amb.x;
    texel.g +=  texel.g * amb.y;
    texel.b +=  texel.b * amb.z;
    
    texel.r = 1 ? 1 : texel.r;
    texel.g = 1 ? 1 : texel.g;
    texel.b = 1 ? 1 : texel.b;

    //texel.rgb = texel.rgb * amb;
    //texel.a = 1;
    return texel;

}

technique simple
{
    pass P0
    {
        //PixelShader = compile ps_2_0 main();

        CULLMODE = backfacecull ? 1 : 3;
    }
}