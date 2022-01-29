texture tex < string textureState="0,Texture"; >;
float colorscale;
float brightness = 1;

sampler2D Sampler0 = sampler_state
{
    Texture = (tex);
};


struct PS_INPUT
{
	float3 texcoord0	: TEXCOORD0;
	float4 color		: COLOR0;
};

float4 main(PS_INPUT IN) : COLOR
{
	return tex2D(Sampler0, IN.texcoord0.xy)*IN.color*colorscale * brightness;
}
technique simplePS
{
    pass P0
    {
        PixelShader  = compile ps_2_0 main();
    }

}
