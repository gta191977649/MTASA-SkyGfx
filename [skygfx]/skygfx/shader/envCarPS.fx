//texture tx0;
texture tx0 < string textureState="0,Texture"; >;
texture tx1;
texture tx2;

float4		surfProps	: register(c0);
float4		fxParams	: register(c1);
float3		eye		: register(c2);
//float3		directDir	: register(c3);

float4		directCol	: register(c5);
float4		lightCol[6]	: register(c6);
float3		directDir	: register(c12);
float3		lightDir[6]	: register(c13);


float power = 1.0;
float lightmult = 1.0;
float surfSpec = 1.0;

sampler2D tex0 = sampler_state
{
    Texture = (tx0);
};
sampler2D tex1 = sampler_state
{
    Texture = (tx1);
};
sampler2D tex2 = sampler_state
{
    Texture = (tx2);
};

struct PS_INPUT
{
	float3 texcoord0	: TEXCOORD0;
	float3 WorldNormal	: TEXCOORD1;
	float3 WorldPos		: TEXCOORD2;
	float4 color		: COLOR0;
	float4 envColor		: COLOR1;
};

float
specTerm(float3 reflVec, float3 light, float pwr)
{
	return pow(max(dot(reflVec, light), 0.0), pwr);
}

float4
main(PS_INPUT IN) : COLOR
{
	float3 ViewVector = normalize(IN.WorldPos - eye);
	float3 ReflVector = normalize(ViewVector - 2.0*dot(ViewVector, IN.WorldNormal)*IN.WorldNormal);
	float3 EnvTex = ReflVector;

	float4 spec = directCol*specTerm(ReflVector, -directDir, power);
//	for(int i = 0; i < 6; i++)	// too much for PS 2.0
	for(int i = 0; i < 5; i++)
		spec += lightCol[i]*specTerm(ReflVector, -lightDir[i], power*2) * 0.8;
	spec *= surfSpec;

	float4 diff = tex2D(tex0, IN.texcoord0.xy);
	float4 mask = tex2D(tex2, EnvTex.xy*0.5 + 0.5);
	float2 ReflPos = normalize(EnvTex.xy) * (EnvTex.z*0.5 + 0.5);
	ReflPos = ReflPos*float2(0.5, -0.5) + float2(0.5, 0.5);
	float4 env = tex2D(tex1, ReflPos)*lightmult*2;

	float4 diffpass = diff*IN.color;
	float4 envpass = env*mask;
	float4 specpass = spec;
	float4 final = lerp(diffpass, envpass, IN.envColor) + specpass;
	final.a = diffpass.a;
	return final;
}

technique veh
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
        //Texture[0] = sTex0;
    }
   
}