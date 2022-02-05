#include "mta-helper.fx"
texture sTex0 < string textureState="0,Texture"; >;

float4x4	combined;
float4		envXform;
float3x3	envmat;
float3x3	specmat;
//float3		lightdir;

float fxSwitch = 1.0f;
float shininess = 1;
float specularity = 1;
float lightmult = 1;

struct VS_INPUT {
	float4 Position	: POSITION;
	float3 Normal	: NORMAL;
	float2 Texcoord1: TEXCOORD1;
};

struct VS_OUTPUT {
	float4 Position		: POSITION;
	float2 Texcoord0	: TEXCOORD0;
	float3 Texcoord1	: TEXCOORD1;
	float4 Envcolor		: COLOR0;
	float4 Speccolor	: COLOR1;
};

VS_OUTPUT main(VS_INPUT IN)
{	
	VS_OUTPUT OUT;
    float3 lightdir = gLightDirection;
	OUT.Position = mul(IN.Position, combined);

	float3 envNormal = mul(envmat, IN.Normal);
	if(fxSwitch == 1.0f){		// env1 map
		OUT.Texcoord0.xy = envNormal.xy - envXform.xy;
		OUT.Texcoord0.xy *= -envXform.zw;
	}else if(fxSwitch == 2.0f){		// env2 map ("x")
		OUT.Texcoord0 = envNormal.xy - envXform.xy;
		OUT.Texcoord0.y *= envXform.y;
		OUT.Texcoord0.xy += IN.Texcoord1;
		OUT.Texcoord0.xy *= -envXform.zw;
	}
	OUT.Envcolor = float4(192.0, 192.0, 192.0, 0.0)/128.0*shininess*lightmult;

	float3 N = mul(specmat, IN.Normal);
	// reflect V along N
	float3 V = lightdir - 2.0*N*dot(N, lightdir);
	// transform [-1,1] to [0,1] in xy ((0,0) = center of spec doc texture)
	OUT.Texcoord1.xyz = (V + float3(1.0, 1.0, 0.0))/2.0;


	if (OUT.Texcoord1.z < 0.0)
		OUT.Speccolor = float4(96.0, 96.0, 96.0, 0.0)/128.0*specularity*lightmult;
	else
		OUT.Speccolor = float4(0.0, 0.0, 0.0, 0.0);

	return OUT;
}

technique veh
{
    pass P0
    {
        VertexShader = compile vs_2_0 main();
        Texture[0] = sTex0;
    }
   
}