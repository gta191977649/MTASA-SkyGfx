texture tex;
float4 redGrade : register(c0);
float4 greenGrade : register(c1);
float4 blueGrade : register(c2);

sampler Sampler0 = sampler_state
{
    Texture = (tex);
};

struct PS_INPUT
{
	float3 texcoord0	: TEXCOORD0;
};

float4
main(PS_INPUT IN) : COLOR
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
