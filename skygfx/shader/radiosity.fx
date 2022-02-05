texture tex;
float4 xform;
float limit = 1;
float intensity = 1;
float passes = 1;

sampler Sampler0 = sampler_state
{
    Texture = (tex);
};

struct PS_INPUT
{
	float3 texcoord0	: TEXCOORD0;
};


float4 main(PS_INPUT IN) : COLOR
{
	float2 uv = IN.texcoord0.xy;

//	uv = (uv - xform.xy) * xform.zw + xform.xy;
	uv = uv*xform.zw + xform.xy;

	float4 c = tex2D(Sampler0, uv);

	c += saturate(c*2.0 - float4(1,1,1,1)*limit) * intensity*passes;
	c.a = 1.0;

	return c;
}

technique ps2_radiosity
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}