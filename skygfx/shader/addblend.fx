//
// Example shader - addBlend.fx
//
// Add pixels to render target
//

//---------------------------------------------------------------------
// addBlend settings
//---------------------------------------------------------------------
texture src;


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique addblend
{
    pass P0
    {
        SrcBlend			= SRCALPHA;
        DestBlend			= ONE;

        // Set up texture stage 0
        Texture[0] = src;
    }
}
