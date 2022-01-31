texture tex;


technique simple
{
    pass P0
    {
        //-- Set up texture stage 0
        Texture[0] = tex;

        //-- Leave the rest of the states to the default settings
    }
}