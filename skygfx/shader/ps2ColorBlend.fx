/*
PS2 Alpha blending:
    After the final pixel has been calculated it is written to the framebuffer. 
    It can either replace the old value or be combined with the colour that is already there. 
    The latter is called blending. The PS2 GS blend equation is very different from the PC (D3D/OpenGL) blend equation. 
    Some modes can be achieved with both, some only with one of them. The following are the general PC and PS2 blend 
    equations. src is the new pixel, dst is the pixel in the frame buffer.
PS2: 
    dst = (A - B)*C + D. All values are considered to be in range [0, 255]. A*B is defined as (A×B)/128.
    where A, B, D are one of src, dst or 0
    and C is one of srcAlpha, dstAlpha or a constant value
    "Standard" alpha blending is a linear interpolation between src and dst by srcAlpha. This can easily be achieved 
    in both equations:
        PS2: A := src, B := dst, C := srcAlpha, D := dst
        → dst = (src - dst)*srcAlpha + dst

*/
texture src;
texture dst;

float srcAlpha = 1;

sampler dstSample = sampler_state
{
    Texture = (dst);
};
sampler srcSample = sampler_state
{
    Texture = (src);
};

struct PS_INPUT
{
	float3 texcoord0	: TEXCOORD0;
};

float4 main(PS_INPUT IN) : COLOR
{
	float4 dst = tex2D(dstSample, IN.texcoord0.xy);
	float4 src = tex2D(srcSample, IN.texcoord0.xy);
    dst.rgb = (src.rgb - dst.rgb) * srcAlpha + dst.rgb;
	return dst;
}


technique ps2ColorBlend
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}
