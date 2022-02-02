texture tex < string textureState="0,Texture"; >;

technique simple
{
    pass P0
    {
        Texture[0] = tex;
        CULLMODE = CCW;

    }
}