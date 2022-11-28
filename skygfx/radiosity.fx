float limit = 1.0;
float intensity = 1.0;
float passes = 1.0;
float4 xform = float4(1,1,1,1.0);
texture Tex0; 

sampler tex = sampler_state
{
    Texture = (Tex0);
};


struct PS_INPUT
{
	float3 texcoord0 : TEXCOORD0;
};

float4 main(PS_INPUT IN) : COLOR
{
	float2 uv = IN.texcoord0.xy;

//	uv = (uv - xform.xy) * xform.zw + xform.xy;
	uv = uv*xform.zw + xform.xy;

	float4 c = tex2D(tex, uv);

	c = saturate(c*2.0 - float4(1,1,1,1)*limit) * intensity*passes;
	c.a = 1.0;

	return c;
}

technique radiosity
{
    pass P0
    {
        PixelShader  = compile ps_2_0 main();
    }
}