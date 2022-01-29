texture tex;
float3 pxSz;

struct PS_INPUT
{
	float3 texcoord0	: TEXCOORD0;
};

sampler Sampler0 = sampler_state
{
    Texture = (tex);
};


float4 main(PS_INPUT IN) : COLOR
{
	float4 c = float4(0.0f, 0.0f, 0.0f, 0.0f);

	for(float i = 0; i < 10; i++){
		float2 uv = IN.texcoord0.xy + pxSz.xy*(i/9.0 - 0.5)*pxSz[2];
		c += tex2D(Sampler0, uv);
	}
	c /= 10;
	c.a = 1.0f;
	return c;
}

technique ps2_building_pipeline2
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}