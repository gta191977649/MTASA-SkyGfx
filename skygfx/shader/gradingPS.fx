texture tex;
float4 redGrade;
float4 greenGrade;
float4 blueGrade;

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
	float4 c = tex2D(Sampler0, IN.texcoord0.xy);
	c.a = 1.0f;

	float4 o;
	o.r = dot(redGrade, c);
	o.g = dot(greenGrade, c);
	o.b = dot(blueGrade, c);
	o.a = 1.0f;
	return o;
}

technique grading
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
        //Texture[0] = sTex0;
    }
   
}