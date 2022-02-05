#include "mta-helper.fx"
texture sTex0 < string textureState="0,Texture"; >;
texture tx1;
texture tx2;


float4		envXform;
float3x3	envmat;
float3x3	specmat;
//float3		lightdir;

float fxSwitch = 2.0f;
float shininess = 2;
float specularity = 1;
float lightmult = 1;

float2 uvMul = float2(1,1);
float2 uvMov = float2(0,0);

struct VS_INPUT {
	float3 Position	: POSITION;
	float3 Normal	: NORMAL;
	float3 Texcoord0: TEXCOORD0;
	float3 Texcoord1: TEXCOORD1;
	float3 Texcoord2: TEXCOORD2;
    float4 Diffuse : COLOR0;
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

//------------------------------------------------------------------------------------------
// GetUV from WorldPos
//------------------------------------------------------------------------------------------
float3 GetUV(float3 position, float4x4 ViewProjection)
{
    float4 pVP = mul(float4(position, 1.0f), ViewProjection);
    pVP.xy = float2(0.5f, 0.5f) + float2(0.5f, -0.5f) * ((pVP.xy / pVP.w) * uvMul) + uvMov;
    return float3(pVP.xy, pVP.z / pVP.w);
}


VS_OUTPUT main_vs(VS_INPUT IN)
{	
	VS_OUTPUT OUT;
	OUT.Texcoord0 = IN.Texcoord0;
	OUT.Texcoord1 = IN.Texcoord1;
	OUT.Texcoord2 = IN.Texcoord2;
	OUT.Position = mul(float4(IN.Position,1), gWorldViewProjection);

	//float3 envNormal = mul(envmat, IN.Normal);
	float3 envNormal = MTACalcWorldNormal( IN.Normal );

	float scale = 1;
	float4 envXform = float4(0,0,scale,scale);


	if(fxSwitch == 1.0f){		// env1 map
		OUT.Texcoord2.xy = envNormal.xy - envXform.xy;
		OUT.Texcoord2.xy *= -envXform.zw;
	}else if(fxSwitch == 2.0f){		// env2 map ("x")
		OUT.Texcoord2.xy = envNormal.xy - envXform.xy;
		OUT.Texcoord2.y *= envXform.y;
		OUT.Texcoord2.xy += IN.Texcoord1;
		OUT.Texcoord2.xy *= -envXform.zw;
	}

	OUT.Envcolor = MTACalcGTAVehicleDiffuse( envNormal,IN.Diffuse )  * float4(192.0, 192.0, 192.0, 0.0)/128.0*shininess*lightmult;

	float3 specmat = float3(0,0,1);
	float3 N = mul(specmat, IN.Normal);
	// reflect V along N
	float3 light = MTACalcWorldNormal(IN.Normal);

	float3 V = light - 2.0*dot(N, light);
	// transform [-1,1] to [0,1] in xy ((0,0) = center of spec doc texture)
	OUT.Texcoord2.xyz = (V + float3(1.0, 1.0, 0.0))/2.0;
	// reflection direction
    float3 view = normalize(IN.Position.xyz - gCameraPosition);
   
	
	if (IN.Texcoord2.z < 0.0)
		OUT.Speccolor = float4(96.0, 96.0, 96.0, 0.0)/128.0*specularity*lightmult;
	else
		OUT.Speccolor = float4(0.0, 0.0, 0.0, 0.0);

	OUT.Speccolor = float4(1.0, 1.0, 1.0, 1.0);

	return OUT;
}

float4 main_ps(VS_OUTPUT IN) : COLOR
{
	//return tex2D(tex0, IN.Texcoord0.xy) * IN.Envcolor + tex2D(tex1, IN.Texcoord1.xy) * IN.Speccolor + tex2D(tex1, IN.Texcoord1.xy)  * IN.Speccolor + tex2D(tex2, IN.Texcoord2.xy)  * IN.Speccolor;
	//tex2D(tex1, IN.texcoord1.xy) * IN.envcolor + IN.speccolor;
	return tex2D(tex0, IN.Texcoord0.xy) * IN.Envcolor + tex2D(tex1, IN.Texcoord1.xy) * IN.Speccolor +  tex2D(tex2, IN.Texcoord2.xy) * IN.Speccolor;
}

technique veh
{
    pass P0
    {
        //Texture[0] = sTex0;
        //VertexShader = compile vs_2_0 main_vs();
        PixelShader = compile ps_2_0 main_ps();
    }
   
}