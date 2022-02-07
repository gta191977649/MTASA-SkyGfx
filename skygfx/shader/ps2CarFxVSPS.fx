#include "mta-helper.fx"
//texture sTex0 < string textureState="0,Texture"; >;
texture tx1;
texture tx2;


float4		envXform = float4(0,0,1,1);
float3x3	envmat;
float3x3	specmat;
//float3		lightdir;

float fxSwitch = 2.0f;
float shininess = 1;
float specularity = 0.1;
float lightmult = 1;


struct VS_INPUT {
	float4 Position	: POSITION;
	float3 Normal	: NORMAL;
	float2 Texcoord0: TEXCOORD0;
	float3 Texcoord1: TEXCOORD1;
	float3 Texcoord2: TEXCOORD2;
    float4 Diffuse 	: COLOR0;
};

struct VS_OUTPUT {
	float4 Position		: POSITION;
	float2 Texcoord0	: TEXCOORD0;
	float3 Texcoord1	: TEXCOORD1;
	float3 Texcoord2	: TEXCOORD2;
	float4 Envcolor		: COLOR0;
	float4 Speccolor	: COLOR1;
};


sampler2D tex0 = sampler_state
{
    Texture = (gTexture0);
};
sampler2D tex1 = sampler_state
{
    Texture = (tx1);
};
sampler2D tex2 = sampler_state
{
    Texture = (tx2);
};

VS_OUTPUT main_vs(VS_INPUT IN)
{	

	VS_OUTPUT OUT;
	float4 worldPos = mul ( IN.Position, gWorld );
    float4 viewPos  = mul ( worldPos, gView );
	OUT.Position = mul(viewPos,gProjection);
	//OUT.Position = mul(float4(IN.Position,1), gWorldViewProjection);

  
    float3 WorldNormal = MTACalcWorldNormal( IN.Normal );
	//float3 envNormal = mul(normal,IN.Normal);
	float3 envNormal = WorldNormal;
    
   
	OUT.Texcoord0 =	IN.Texcoord0;
	OUT.Texcoord1 =	IN.Texcoord1;
	OUT.Texcoord2 =	IN.Texcoord2;
	if(fxSwitch == 1.0f){		// env1 map
		OUT.Texcoord1.xy = envNormal.xy - envXform.xy;
		OUT.Texcoord1.xy *= -envXform.zw;
	}else if(fxSwitch == 2.0f){		// env2 map ("x")
		OUT.Texcoord1.xy = envNormal.xy - envXform.xy;
		OUT.Texcoord1.y *= envXform.y;
		OUT.Texcoord1.xy += IN.Texcoord1;
		OUT.Texcoord1.xy *= -envXform.zw;
	}

   
	//OUT.Envcolor = float4(192.0, 192.0, 192.0, 0.0)/128.0*shininess*lightmult;
    
	OUT.Envcolor = MTACalcGTAVehicleDiffuse( WorldNormal,IN.Diffuse ) * float4(192.0, 192.0, 192.0, 0.0)/128.0*shininess*lightmult;

	//float3 N = mul(combined, IN.Normal);
	float3 lightdir = normalize(gLightDirection);
	float3 N = mul((float3x3)gView, IN.Normal);
	// reflect V along N

	float3 V = lightdir - 2.0*N*dot(N, lightdir);
	// transform [-1,1] to [0,1] in xy ((0,0) = center of spec doc texture)
	OUT.Texcoord1 = (V + float3(1.0, 1.0, 0.0))/2.0;
	OUT.Texcoord2 = N;


	if (OUT.Texcoord1.z < 0.0)
		OUT.Speccolor = float4(96.0, 96.0, 96.0, 0.0)/128.0*specularity*lightmult;
	else
		OUT.Speccolor = float4(0.0, 0.0, 0.0, 0.0);

	return OUT;
}

float4 main_ps(VS_OUTPUT IN) : COLOR0
{
	//return tex2D(tex0, IN.Texcoord0.xy) * IN.Envcolor + tex2D(tex1, IN.Texcoord1.xy) * IN.Speccolor + tex2D(tex1, IN.Texcoord1.xy)  * IN.Speccolor + tex2D(tex2, IN.Texcoord2.xy)  * IN.Speccolor;
	return tex2D(tex0, IN.Texcoord0.xy) * IN.Envcolor + tex2D(tex2, IN.Texcoord2.xy) * IN.Speccolor;
}

technique veh
{
    pass P0
    {
        VertexShader = compile vs_2_0 main_vs();
        PixelShader = compile ps_2_0 main_ps();
    }
   
}