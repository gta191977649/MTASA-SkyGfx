#include "mta-helper.fx"
texture tex < string textureState="0,Texture"; >;
texture tex_1 < string textureState="1,Texture"; >;

float zwriteThreshold = 128;
float brightness = 1;

float3		ambient;
float4		matCol;
float4		dayparam;
float4		nightparam;
float 		colorScale;
float 		surfAmb;
float  		fogStart;
float 		fogEnd;
float 		fogRange;
bool 		fogDisable;

sampler2D sampleTxd = sampler_state 
{
    Texture = (tex);
};
sampler2D sampleTxd_1 = sampler_state 
{
    Texture = (tex_1);
};

struct VS_INPUT
{
	float4 Position		: POSITION;
	float3 TexCoord		: TEXCOORD0;
	float4 NightColor	: COLOR0;
	float4 DayColor		: COLOR1;
};

struct VS_OUTPUT {
	float4 Position		: POSITION;
	float3 Texcoord	    : TEXCOORD0;
	float4 Color		: COLOR0;
};


struct PS_INPUT
{
    float4 position : POSITION0;
	float3 texcoord0	: TEXCOORD0;
    float2 texcoord1	: TEXCOORD1;
	float4 color		: COLOR0;
    float4 envcolor		: COLOR1;
};

//hash for randomness
float2 hash2D2D(float2 s)
{
	//magic numbers
	return frac(sin(fmod(float2(dot(s, float2(127.1, 311.7)), dot(s, float2(269.5, 183.3))), 3.14159)) * 43758.5453);
}

//stochastic sampling
float4 tex2DStochastic(sampler2D tex, float2 UV)
{
	//triangle vertices and blend weights
	//BW_vx[0...2].xyz = triangle verts
	//BW_vx[3].xy = blend weights (z is unused)
	float4x3 BW_vx;

	//uv transformed into triangular grid space with UV scaled by approximation of 2*sqrt(3)
	float2 skewUV = mul(float2x2 (1.0, 0.0, -0.57735027, 1.15470054), UV * 3.464);

	//vertex IDs and barycentric coords
	float2 vxID = float2 (floor(skewUV));
	float3 barry = float3 (frac(skewUV), 0);
	barry.z = 1.0 - barry.x - barry.y;

	BW_vx = ((barry.z > 0) ?
			 float4x3(float3(vxID, 0), float3(vxID + float2(0, 1), 0), float3(vxID + float2(1, 0), 0), barry.zyx) :
			 float4x3(float3(vxID + float2 (1, 1), 0), float3(vxID + float2 (1, 0), 0), float3(vxID + float2 (0, 1), 0), float3(-barry.z, 1.0 - barry.y, 1.0 - barry.x)));

	//calculate derivatives to avoid triangular grid artifacts
	float2 dx = ddx(UV);
	float2 dy = ddy(UV);

	//blend samples with calculated weights
	return mul(tex2D(tex, UV + hash2D2D(BW_vx[0].xy), dx, dy), BW_vx[3].x) +
		mul(tex2D(tex, UV + hash2D2D(BW_vx[1].xy), dx, dy), BW_vx[3].y) +
		mul(tex2D(tex, UV + hash2D2D(BW_vx[2].xy), dx, dy), BW_vx[3].z);
}

VS_OUTPUT main_vs(in VS_INPUT IN)
{
	VS_OUTPUT OUT;

	OUT.Position = mul(float4(IN.Position), gWorldViewProjection);
	//OUT.Texcoord0 = mul(texmat, float4(IN.TexCoord, 0.0, 1.0)).xy;
	OUT.Texcoord = IN.TexCoord;
	OUT.Color = IN.DayColor*dayparam + IN.NightColor*nightparam;
	OUT.Color *= matCol / colorScale;
	OUT.Color.rgb += ambient*surfAmb;
	OUT.Texcoord.z = clamp((OUT.Position.w - fogEnd)*fogRange, fogDisable, 1.0);
	return OUT;
}


float4 main_ps(PS_INPUT IN) : COLOR
{
	return tex2DStochastic(sampleTxd, IN.texcoord0.xy * 1.2) * IN.color * colorScale.x * brightness;
	//return tex2DStochastic(sampleTxd, IN.texcoord0.xy * 1.2) * IN.color * colorScale.x * brightness  + tex2D(sampleTxd_1, IN.texcoord1)*IN.envcolor * brightness;
	//return tex2D(tex, IN.texcoord0.xy)*IN.color*colorscale.x;
}

technique simplePS
{
    pass P0
    {        
        VertexShader = compile vs_3_0 main_vs();
        PixelShader  = compile ps_3_0 main_ps();
    }
    
}