#version 120
#define composite1
#ifdef composite1
uniform float viewHeight;
uniform float viewWidth;
#else
uniform float viewHeight
uniform float viewWidth
#endif
#include "/files/filters/distort.glsl"
#include "/files/filters/dither.glsl"
#include "/files/shading/lightmap.glsl"
#include "/files/filters/noises.glsl"
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
varying vec2 TexCoords;

uniform vec3 sunPosition;
uniform vec3 shadowLightPosition;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform int worldTime;
uniform sampler2D gaux1;
uniform sampler2D gaux4;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 upPosition;
uniform float wetness;
uniform float rainStrength;
uniform float frameTimeCounter;

uniform ivec2 eyeBrightnessSmooth;
uniform ivec2 eyeBrightness;

const float eyeBrightnessHalflife = 5.0f;

float eyeAdaptY = eyeBrightnessSmooth.y / 240.0; //sky
float eyeAdaptX = eyeBrightnessSmooth.x / 180.0; //block
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
const float sunPathRotation = -40.0f;
const int noiseTextureResolution = 128;
const float shadowDistance = 60.0f;

const float Ambient = 0.025f;

float Raining = clamp(wetness, 1.0, 100.0);

#define SSR
//#define LongSSR
//#define SSRfilter

#define Fog
#define FogDefaultDensity 0.75  ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define FogAffectSky 0.5  //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define FogStart 70 //[0 1 5 10 15 20 25 30 25 40 45 50 60 70 80 90 100 150 200 250 300 400 500 600 700 800 900 1000]
#define FogEnd 130 //[0 1 5 10 15 20 25 30 25 40 45 50 60 70 80 90 100 150 200 250 300 400 500 600 700 800 900 1000]

#define WaterFog
#define WaterFogDensity 0.015  ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define WaterFogColor

//#define ShadowRendering
#define ShadowLightmap
//#define ShadowLightmapLightOrDark
//#define LightmapCustomColor

#define shadowMapResolution 256 //[64 128 256 512 768 912 1024 1536 2048]
#define SHADOW_SAMPLES 2 //[1 2 3 4]

#define LightingMultiplayer 1.0 //[1.0 1.25 1.50 1.75 2.0 2.50 3.0]

#define Clouds

#define RainPuddles

#define FakeFoam
#define WaterFoamHeight 0.35 //[0.1 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]

#ifdef SSR
const float stp = 1.2;			//size of one step for raytracing algorithm
const float ref = 0.1;			//refinement multiplier
const float inc = 2.2;			//increasement factor at each step
const int maxf = 4;				//number of refinements
float Id =  texture2D(colortex6, TexCoords).r * 255;
#endif

#ifdef RainPuddles
#define PuddlesDestiny 1.2 //[0.1 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
#define PuddlesStrenght 10 //[1 2 3 4 5 6 7 8 9 10 11 1213 14 15 16 17 18 19 20 21 22 23 24 25]
#define PuddlesResolution 10000 //[100 200 300 400 500 600 700 800 900 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000]
#endif
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
const int colortex0Format = RGBA32F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
const int colortex6Format = RGB16;
const int colortex8Format = RGBA32F;
const int colortex7Format = RGBA32F;
*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef SSR
vec3 nvec3(vec4 pos){
    return pos.xyz/pos.w;
}
//-----------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------
vec4 nvec4(vec3 pos){
    return vec4(pos.xyz, 1.0);
}
//-----------------------------------------------------------------------------------------
float cdist(vec2 coord) {
	return max(abs(coord.s-0.5),abs(coord.t-0.5))*2.0;
}
#endif
//-----------------------------------------------------------------------------------------
#ifdef FakeFoam
uniform float near;
uniform float far;

float get_linear_depth(in float depth)
{
      return 2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near));
}
//-----------------------------------------------------------------------------------------
float depth_solid = get_linear_depth(texture2D(depthtex0, TexCoords).x);
float depth_translucent = get_linear_depth(texture2D(depthtex1, TexCoords).x);

vec3 Foam(in vec3 Color){
  float dist_fog = distance(depth_solid, depth_translucent);

      if (dist_fog <= WaterFoamHeight){
        Color += vec3(0.05,0.05,0.05);
      }
      return Color;
}

#endif
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
vec3 GetLightmapColor(in vec2 Lightmap, in float sunAmount){

    Lightmap = AdjustLightmap(Lightmap);

    vec3 TorchColor = vec3(1.0f, 0.25f, 0.08f);
    vec3 TorchLighting = Lightmap.x * TorchColor;
    vec3 LMSky = skyColor;
  //  vec3 LMFog = fogColor; LMFog.r +=0.8*TimeSunrise+0.0*TimeNoon+0.8*TimeSunset+0.0*TimeMidnight; //СВЕЧЕНИЕ от сонца
    vec3 LMFog = fogColor; LMFog.r +=0.0*TimeSunrise+0.0*TimeNoon+0.0*TimeSunset+0.0*TimeMidnight; //СВЕЧЕНИЕ от сонца
    vec3 SkyLighting = Lightmap.y * mix(LMSky, LMFog, pow(sunAmount, 2.0));
//-----------------------------------------------------------------------------------------
#ifdef ShadowLightmap
#ifdef ShadowLightmapLightOrDark
if (Lightmap.y > 0.7){
     SkyLighting += vec3(0.3);
    }
    if (Lightmap.y > 0.705){
     SkyLighting += vec3(0.3);
    }
    if (Lightmap.y > 0.71){
     SkyLighting += vec3(0.3);
    }
//-----------------------------------------------------------------------------------------
#else
if (Lightmap.y > 0.7){
 SkyLighting += vec3(0.15);
}
if (Lightmap.y > 0.705){
 SkyLighting += vec3(0.15);
}
if (Lightmap.y > 0.71){
 SkyLighting += vec3(0.15);
}
SkyLighting+= vec3(0.55)*eyeAdaptY;
#endif
#endif
//-----------------------------------------------------------------------------------------
    vec3 LightmapLighting = TorchLighting + SkyLighting/1.25;

    return LightmapLighting;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef ShadowRendering
float Visibility(in sampler2D ShadowMap, in vec3 SampleCoords) {
    return step(SampleCoords.z - 0.001f, texture2D(ShadowMap, SampleCoords.xy).r);
}
//-----------------------------------------------------------------------------------------
vec3 TransparentShadow(in vec3 SampleCoords){
    float ShadowVisibility0 = Visibility(shadowtex0, SampleCoords);
    float ShadowVisibility1 = Visibility(shadowtex1, SampleCoords);
    vec4 ShadowColor0 = texture2D(shadowcolor0, SampleCoords.xy);
    vec3 TransmittedColor = ShadowColor0.rgb * (1.0f - ShadowColor0.a); // Perform a blend operation with the sun color
    //vec3(1.52f,1.0f,1.0f)*vec3(1.52f,1.0f,1.0f)*TimeSunrise+vec3(1.52f,1.0f,1.0f)/2*TimeNoon+skyColor*TimeSunset+vec3(0.1)*TimeMidnight
    return mix(TransmittedColor * ShadowVisibility1, //vec3(1.52f,1.0f,1.0f)*
     vec3(1.52f,1.0f,1.0f)*TimeSunrise+vec3(1.52f,1.0f,1.0f)/2*TimeNoon+vec3(1.52f,1.0f,1.0f)*TimeSunset+vec3(0.1)*TimeMidnight, ShadowVisibility0)*eyeAdaptY;
}

//-----------------------------------------------------------------------------------------
const int ShadowSamplesPerSize = 2 * SHADOW_SAMPLES + 1;
const int TotalSamples = ShadowSamplesPerSize * ShadowSamplesPerSize;

vec3 GetShadow(float depth) {
    vec3 ClipSpace = vec3(TexCoords, depth) * 2.0f - 1.0f;
    vec4 ViewW = gbufferProjectionInverse * vec4(ClipSpace, 1.0f);
    vec3 View = ViewW.xyz / ViewW.w;
    vec4 World = gbufferModelViewInverse * vec4(View, 1.0f);
    vec4 ShadowSpace = shadowProjection * shadowModelView * World;
    ShadowSpace.xy = DistortPosition(ShadowSpace.xy);
    vec3 SampleCoords = ShadowSpace.xyz * 0.5f + 0.5f;
    float RandomAngle = texture2D(noisetex, TexCoords * 20.0f).r * 100.0f;
    float cosTheta = cos(RandomAngle);
	float sinTheta = sin(RandomAngle);
    mat2 Rotation =  mat2(cosTheta, -sinTheta, sinTheta, cosTheta) / shadowMapResolution; // We can move our division by the shadow map resolution here for a small speedup
    vec3 ShadowAccum = vec3(0.0f);
    for(int x = -SHADOW_SAMPLES; x <= SHADOW_SAMPLES; x++){
        for(int y = -SHADOW_SAMPLES; y <= SHADOW_SAMPLES; y++){
            vec2 Offset = Rotation * vec2(x, y);
            vec3 CurrentSampleCoordinate = vec3(SampleCoords.xy + Offset, SampleCoords.z);
            ShadowAccum += TransparentShadow(CurrentSampleCoordinate);
        }
    }
    ShadowAccum /= TotalSamples;
    return ShadowAccum;
}
#endif
//----------------------------------------------------------------------------------------
#ifdef SSR
vec4 raytrace(vec3 viewdir, vec3 normal){

  //http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2381727-shader-pack-datlax-onlywater-only-water
    vec4 color = vec4(0.0);


vec3 rvector = normalize(reflect(normalize(viewdir), normalize(normal)*sqrt(0.0+max(dot(normal,normalize(upPosition)),0.0))));
    vec3 vector = stp * rvector;
    vec3 oldpos = viewdir;
    viewdir += vector;
    int sr = 0;

    for(int i = 0; i < 40; i++){
    vec3 pos = nvec3(gbufferProjection * nvec4(viewdir)) * 0.5 + 0.5;

        if(pos.x < 0 || pos.x > 1 || pos.y < 0 || pos.y > 1 || pos.z < 0 || pos.z > 1.0) break;

        vec3 spos = vec3(pos.st, texture2D(depthtex0, pos.st).r);
        spos = nvec3(gbufferProjectionInverse * nvec4(spos * 2.0 - 1.0));
	    	float err = abs(viewdir.z-spos.z);

		if(err < pow(length(vector)*1.85,1.15) && texture2D(gaux1,pos.st).g < 0.01)
    {      sr++;   if(sr >= maxf){

  float border = clamp(1.0 - pow(cdist(pos.st), 1.0), 0.0, 1.0);
  color = texture2D(colortex0, pos.st);
					float land = texture2D(gaux1, pos.st).g;
					land = float(land < 0.03);
					spos.z = mix(viewdir.z,2000.0*(0.4+1.0*0.6),land);
					color.a = 1.0;
                    color.a *= border;
                    break;
                }
                viewdir = oldpos;
                vector *=ref;
        }
        vector *= inc;
        oldpos = viewdir;
        viewdir += vector;
    }
    return color;

}
#endif

//-----------------------------------------------------------------------------------------
#ifdef RainPuddles
float getRainPuddles(vec3 worldpos, vec3 Normal){

	vec2 coord = (worldpos.xz/PuddlesResolution);

	float rainPuddles = texture2D(noisetex, (coord.xy*8)).x;
	rainPuddles += texture2D(noisetex, (coord.xy*4)).x;
	rainPuddles += texture2D(noisetex, (coord.xy*2)).x;
	rainPuddles += texture2D(noisetex, (coord.xy/2)).x;

	float strength = max(rainPuddles-PuddlesDestiny/Raining,0.0);

	return strength;
}
#endif

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void main(){
  vec2 UsrrTexcoord = TexCoords;
//----------------------------------------------------------------------------------
#ifdef SSR
vec3 ClipSpace = vec3(TexCoords, texture2D(depthtex0, TexCoords).x) * 2.0f - 1.0f;
vec4 ClipSpaceToViewSpace = gbufferProjectionInverse * vec4(ClipSpace, 1.0f);
vec3 ViewSpace = ClipSpaceToViewSpace.xyz / ClipSpaceToViewSpace.w;
vec3 ViewDirect = normalize(ViewSpace);
#endif
//-----------------------------------------------------------------------------------------

    vec3 Albedo = pow(texture2D(colortex0, TexCoords).rgb, vec3(2.2f*clamp(1.0,1.0,eyeAdaptY)));
    vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);

    vec3 fragpos = vec3(TexCoords, texture2D(depthtex0, TexCoords).r);
    fragpos = nvec3(gbufferProjectionInverse * nvec4(fragpos * 2.0 - 1.0));
//----------------------------------------------------------------------------------
//float avgSceneColor = dot(textureLod(colortex0, TexCoords, 100.0).rgb, vec3(1.0/3.0));
//Albedo *= 1.0 / avgSceneColor;
//----------------------------------------------------------------------------------
    float Depth = texture2D(depthtex0, TexCoords).r;
    bool isCloud = texture2D(colortex7, TexCoords).x > 1.1f;
//----------------------------------------------------------------------------------
    vec3 screenPos = vec3(TexCoords, texture2D(depthtex0, TexCoords).r);
    vec3 clipPos = screenPos * 2.0 - 1.0;
    vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);

    vec3 viewPos = tmp.xyz / tmp.w;
    vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
    vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;
    vec3 worldPos = feetPlayerPos + cameraPosition;
    vec4 world_position = gbufferModelViewInverse * vec4(viewPos, 1.0);
    vec3 P_world = (gbufferModelViewInverse * vec4(viewPos,1.0)).xyz + cameraPosition;
//----------------------------------------------------------------------------------
    float FogDistance = length(viewPos);
    float FogDistanceSetup = 1;
//-----------------------------------------------------------------------------------------
if(isCloud){

FogDistanceSetup = smoothstep(-30, FogEnd, FogDistance*FogDefaultDensity*Raining);
  }
  else
  {
FogDistanceSetup = smoothstep(FogStart, FogEnd, FogDistance*FogDefaultDensity*Raining);
   }

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
    vec3 L = mat3(gbufferModelViewInverse) * normalize(sunPosition.xyz);
    vec3 rd = normalize(vec3(world_position.x,world_position.y,world_position.z));
    float sunAmount = max(dot(rd, L), 0.0);
//-----------------------------------------------------------------------------------------
    vec2 Lightmap = texture2D(colortex2, TexCoords).rg;
    vec3 LightmapColor = GetLightmapColor(Lightmap, sunAmount);
//-----------------------------------------------------------------------------------------
#ifdef Clouds
    vec3 Cloud_Pos = vec3(1);
    Cloud_Pos = world_position.xyz / world_position.y;
    Cloud_Pos.y *= 8000.0;
    Cloud_Pos.zx += frameTimeCounter/10;
    float awan = 0;
    awan += simplex3d_fractal(Cloud_Pos)*clamp(1.0 - rainStrength,0.1,1.0);

#endif
//=============================REALSHADOWS==================================================================
#ifdef ShadowRendering
    float NdotL = max(dot(Normal, normalize(shadowLightPosition)), 0.0f);
    float Id =  texture2D(colortex6, TexCoords).r * 255;

    if(Id == 2.0 || Id == 2.0){
      NdotL = 0.14*TimeSunrise+0.5*TimeNoon+0.25*TimeSunset+0.5*TimeMidnight;
    }

    vec3 Diffuse = Albedo  * (LightmapColor + (NdotL * GetShadow(Depth))*6*LightingMultiplayer + Ambient);

    #ifdef Fog
    Diffuse = mix(Diffuse,  mix(skyColor, fogColor, pow(sunAmount, 2.0)), FogDistanceSetup);
    vec3 CreateFog = mix(Albedo,  mix(skyColor, fogColor, pow(sunAmount, 2.0)), FogDistanceSetup);
    if(Id == 1.0){
          #ifdef WaterFog
       Diffuse += mix(vec3(0), vec3(0.25), FogDistance*WaterFogDensity);
           #endif

           #ifdef FakeFoam
       Diffuse = Foam(Diffuse);
          #endif
}
    #endif
//=============================FAKESHADOWS======================================================
#else
    vec3 LightmapCustomCol = vec3(1.0);
    #ifdef LightmapCustomColor
     LightmapCustomCol = vec3(1.52f,1.0f,1.0f)*vec3(1.52f,1.0f,1.0f)*TimeSunrise+vec3(1.52f,1.0f,1.0f)/2*TimeNoon+vec3(1.52f,1.0f,1.0f)*TimeSunset+vec3(0.1)*TimeMidnight;
    #endif

    vec3 Diffuse = Albedo * (LightmapColor/1.25*LightmapCustomCol + Ambient);

    #ifdef Fog
    vec3 AdjustedFog = vec3(fogColor.r *TimeSunrise*1+TimeSunset*3+TimeNoon*1+TimeMidnight*10.5, fogColor.g,fogColor.b);
    Diffuse = mix(Diffuse,  mix(skyColor, fogColor, pow(sunAmount, 2.0)), FogDistanceSetup);
    vec3 CreateFog = mix(Albedo,  mix(skyColor, fogColor, pow(sunAmount, 2.0)), FogDistanceSetup);
//-----------------------------------------------------------------------------------------
    if(Id == 1.0){
       Diffuse *= texture2D(colortex0, TexCoords+0.01).rgb;
          #ifdef WaterFog
       Diffuse += mix(vec3(0), vec3(0.25), FogDistance*WaterFogDensity);

           #endif
//-----------------------------------------------------------------------------------------
           #ifdef FakeFoam
       Diffuse = Foam(Diffuse);
          #endif
//-----------------------------------------------------------------------------------------
}

    #endif

#endif
//-----------------------------------------------------------------------------------------
vec4 WaterSreenSpaceReflections = vec4(1.0);
vec4 SSRMask = texture2D(colortex0, TexCoords);
#ifdef SSR
vec4 reflection;
if(Id == 1.0){
#ifdef LongSSR
float dither = fract(frameTimeCounter + bayer256(gl_FragCoord.xy));

#ifdef SSRfilter
reflection = raytrace((fragpos-ViewDirect*interleavedGradientNoise()), Normal);
#else
reflection = raytrace(fragpos-ViewDirect, Normal);
#endif

#else
reflection = raytrace(ViewDirect, Normal);
#endif
 WaterSreenSpaceReflections.rgb = mix(WaterSreenSpaceReflections.rgb, reflection.rgb*2.5, reflection.a * (vec3(1.0) - texture2D(colortex0, TexCoords).rgb));
 //(vec3(1.0) - texture2D(colortex0, TexCoords).rgb));
// reflection = raytrace(ViewDirect, Normal)*1.5;
  //WaterSreenSpaceReflections.rgb = mix(texture2D(colortex0, TexCoords).rgb, reflection.rgb, 1*reflection.a * (vec3(1.0) - texture2D(colortex0, TexCoords).rgb));
}else{ //vec3(0.5,0.5,0.5)*1.75
  WaterSreenSpaceReflections.rgba = vec4(1);
}
#endif

//----------------------------------------------------------------------------------------------------
vec4 rainPuddles = vec4(0);
#ifdef RainPuddles
vec4 reflection2Rain;
if(Id == 1.0){

}else{
float rainpuddleee = getRainPuddles(worldPos, Normal);
vec4 reflectionRain = raytrace(fragpos-ViewDirect, Normal)*dot(Normal,normalize(upPosition));
//reflection2Rain.rgb = mix(texture2D(gcolor, TexCoords).rgb, reflectionRain.rgb,frenselcolor*reflectionRain.a * (vec3(1.0) - colorRipple*dot(Normal,normalize(upPosition))));
  reflection2Rain.rgb = mix(SSRMask.rgb*0,  reflectionRain.rgb,reflectionRain.a * (vec3(1.0) - texture2D(colortex0, TexCoords).rgb));
 rainPuddles = rainpuddleee*reflection2Rain;

}
 #endif
//===============================================================================================
    gl_FragData[0] = vec4(Diffuse, 1.0f)*WaterSreenSpaceReflections+rainPuddles;
//===============================================================================================
    if(Depth == 1.0f){
        gl_FragData[0] = vec4(mix(CreateFog, Albedo, FogAffectSky*clamp(1.0 - rainStrength,0.1,1.0)), 1.0f);

        #ifdef Clouds
        if(Depth == 1.0 && sign(Cloud_Pos + cameraPosition.y) == sign(eyePlayerPos.y)) {
            vec4 Cloud = vec4(Albedo, 1.0f);
            Cloud = mix (Cloud, vec4(0.5,0.5,0.5,0.5), awan/1.7*TimeSunrise+awan/1.7*TimeNoon+awan/1.7*TimeSunset+awan/22.7*TimeMidnight);;
              gl_FragData[0] = mix(vec4(CreateFog, 1.0), Cloud, FogAffectSky*clamp(1.0 - rainStrength,0.1,1.0)), 1.0f;
            }else{
                  gl_FragData[0] = mix(vec4(CreateFog, 1.0), vec4(Albedo, 1.0f), FogAffectSky*clamp(1.0 - rainStrength,0.1,1.0)), 1.0f;
            }
        #endif

        return;
    }
}
