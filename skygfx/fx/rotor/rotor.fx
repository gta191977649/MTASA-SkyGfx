texture Tex0;
float alpha = 1;
sampler Sampler0 = sampler_state
{
    Texture = <Tex0>;
};

struct VSInput
{
    float3 Position : POSITION;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
//-- Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
};



float4 PixelShaderExample(PSInput PS) : COLOR0
{
    //-- Grab the pixel from the texture
    float4 finalColor = tex2D(Sampler0, PS.TexCoord);
    //-- Apply color tint
    finalColor = finalColor * float4(1,1,1,alpha);
    return finalColor;
}


technique replace {
    pass P0 {
        
       
        Texture[0] = Tex0;
        AlphaOp[0] = SelectArg1;

        ZEnable = true;
        ZWriteEnable = false;
        ShadeMode = 1;
        AlphaBlendEnable = true;
        SrcBlend = 1;
        DestBlend = 6;
        AlphaTestEnable = true;
        AlphaRef = 1;
        AlphaFunc = 7;
        Lighting = true;
        DepthBias = 0;

        PixelShader  = compile ps_2_0 PixelShaderExample();

    }
}