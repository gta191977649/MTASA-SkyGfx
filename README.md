![SKYGFX](doc/skygfx.png)
# MTASA-SkyGfx
A project brings the classic aesthetic look to MTA (Thanks to aap for the original work).
## What have done or working in progress?
- ⚪ Not Start yet/ not invesgate
- 🟠 Partically Work
- ✔️ Done & Fully Supported
- Pre-request Library
  * Timecyc Parser - ✔️
  * Timecyc Interpolation - ✔️, Source mainly conveted from librw, thanks to aap!
  * Timecyc Render - ✔️
  * Timecyc DebugTools (Optional) - DONE, But you're need dgs to work!
- Postfx 
  * Trails(Blur) - ✔️
    * blurLeft,blurTop,blurRight,blurBottom works!
  * Radiosity - ✔️
  * Color Filter - 🟠
    * PS2 ✔️
    * PC ✔️
    * Mobile - ⚪
  * Night Version Goggles - ⚪
  * Infrared Goggles - ⚪

- Building Pipeline
  * SimplePS - ✔️
  * BuildingVS - 🟠
    * partially, some engine data requires to work, still working on that
  * BuildingVSFX - For model with specular lighting property
    * Not even start yet
- Vehicle Pipeline
  * PS2 Pipeline - ✔️
    * Done, you happy?
  * Xbox Pipeline - 🟠
    * Only specular lighting works. 
* Pipeline tweaks
  * radiosityFilterPasses - ✔️
  * radiosityRenderPasses - ✔️
  * radiosityIntensity - ✔️
  * zwriteThreshold - ✔️
  * detailMaps - ⚪
  * leedsShininessMult - ⚪
  * neoShininessMult - ⚪
  * neoSpecularityMult - ⚪
  * envShininessMult - ⚪
  * envSpecularityMult - ⚪
  * envPower - ⚪
  * envFresnel - ⚪
  * sunGlare - ✔️ just see my feature [PR](https://github.com/multitheftauto/mtasa-blue/pull/2495). 
  * ps2ModulateBuilding - ⚪
- World Effect
  - Dual Pass Render - ✔️
    * Yeah, it's done, thanks to ren712
  - PS2 Alpha Test
    * not even start yet
  - Grass
    * dualPassGrass - ✔️
      * it overrides by dual pass render.
    * grassBackfaceCull - ✔️
    * grassAddAmbient - ⚪
    * grassFixPlacement - ❌ only can do it via modify the mta engine
    * ps2ModulateGrass - ⚪
  - Shadows
    * pedShadows - ⚪
    * stencilShadows - ⚪
  - Misc
    * disableClouds - ⚪
    * disableGamma - ⚪
    * neoWaterDrops(xbox rain postfx) - ⚪
    * neoBloodDrops - ⚪
    * transparentLockon - ⚪
    * lightningIlluminatesWorld - ⚪ toogle timecyc lighting on world object.
    * fixPcCarLight - ⚪
    * coronaZtest - 🟠
      * partially works, however this will breaks and bugs up the other corona's ztesting in mta.
      * needs to work on a new solution.
    * fixShadows - ⚪
  - Special Misc FX (Unique addon by nurupo)
    * vehicleClassicFx ✔️ show VC/III liked vehicle big headlight and light trails when you rotate the screen
    * vehicleTrailLength ✔️ Length of light trails (buffered frame)
    * vehicleTrailDrawDist ✔️ What distance should trails start visiable?
    * vehicleHeadLightAlpha ✔️ Alpha multiplier for head light
    * vehicleRearLightAlpha ✔️  Alpha multiplier for rear light
    
  
- Bugs/Issue
  * Sun can see through by walls -> Due to zTest disabled 