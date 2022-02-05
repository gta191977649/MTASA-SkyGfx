//
// Example shader - addBlend.fx
//
// Add pixels to render target
//

//---------------------------------------------------------------------
// addBlend settings
//---------------------------------------------------------------------
texture sTex0 < string textureState="0,Texture"; >;
//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique addblend
{
    pass P0
    {
        Texture[0] = sTex0;
        ZENABLE = FALSE;
        //DITHERENABLE = TRUE;
        //DEPTHBIAS = 0.01;
        //ZFUNC = LESSEQUAL;
    }

}
