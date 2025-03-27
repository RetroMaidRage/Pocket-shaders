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
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform int worldTime;
uniform sampler2D gaux4;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse
uniform vec3 cameraPosition;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 upPosition;
uniform float wetness;
uniform float rainStrength;
uniform float frameTimeCounter;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
const float sunPathRotation = -40.0f;
const int noiseTextureResolution = 128;
const float shadowDistance = 60.0f;

const float Ambient = 0.025f;

float Raining = clamp(wetness, 1.0, 100.0);

#define Fog
#define FogDefaultDensity 0.75  ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define FogStart 70 //[0 1 5 10 15 20 25 30 25 40 45 50 60 70 80 90 100 150 200 250 300 400 500 600 700 800 900 1000]
#define FogEnd 130 //[0 1 5 10 15 20 25 30 25 40 45 50 60 70 80 90 100 150 200 250 300 400 500 600 700 800 900 1000]

//#define ShadowRendering
#define ShadowLightmap
//#define ShadowLightmapLightOrDark
//#define LightmapCustomColor

#define shadowMapResolution 256 //[64 128 256 512 768 912 1024 1536 2048]
#define SHADOW_SAMPLES 2 //[1 2 3 4]

#define LightingMultiplayer 1.0 //[1.0 1.25 1.50 1.75 2.0 2.50 3.0]
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

bool sunrise =   (worldTime < 22000 || worldTime > 500);
bool day =   (worldTime < 1000 || worldTime > 8500);
bool sunset =   (worldTime < 8500 || worldTime > 12000);
bool night =   (worldTime < 12000 || worldTime > 21000);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
vec3 GetLightmapColor(in vec2 Lightmap){

    Lightmap = AdjustLightmap(Lightmap);

     vec3 TorchColor = vec3(1.0f, 0.25f, 0.08f);

    vec3 TorchLighting = Lightmap.x * TorchColor;
    vec3 SkyLighting = Lightmap.y * skyColor;
//skyColor*TimeSunrise+vec3(1.52f,1.0f,1.0f)*TimeNoon+skyColor*TimeSunset+vec3(0)*TimeMidnight
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
SkyLighting+= vec3(0.55);
#endif

#endif

    vec3 LightmapLighting = TorchLighting + SkyLighting/1.25;

    return LightmapLighting;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef ShadowRendering
float Visibility(in sampler2D ShadowMap, in vec3 SampleCoords) {
    return step(SampleCoords.z - 0.001f, texture2D(ShadowMap, SampleCoords.xy).r);
}

vec3 TransparentShadow(in vec3 SampleCoords){
    float ShadowVisibility0 = Visibility(shadowtex0, SampleCoords);
    float ShadowVisibility1 = Visibility(shadowtex1, SampleCoords);
    vec4 ShadowColor0 = texture2D(shadowcolor0, SampleCoords.xy);
    vec3 TransmittedColor = ShadowColor0.rgb * (1.0f - ShadowColor0.a); // Perform a blend operation with the sun color
    //vec3(1.52f,1.0f,1.0f)*vec3(1.52f,1.0f,1.0f)*TimeSunrise+vec3(1.52f,1.0f,1.0f)/2*TimeNoon+skyColor*TimeSunset+vec3(0.1)*TimeMidnight
    return mix(TransmittedColor * ShadowVisibility1, vec3(1.52f,1.0f,1.0f)*vec3(1.52f,1.0f,1.0f)*TimeSunrise+vec3(1.52f,1.0f,1.0f)/2*TimeNoon+vec3(1.52f,1.0f,1.0f)*TimeSunset+vec3(0.1)*TimeMidnight, ShadowVisibility0);
}


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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void main(){
//----------------------------------------------------------------------------------
    vec3 Albedo = pow(texture2D(colortex0, TexCoords).rgb, vec3(2.2f));
    vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);
//----------------------------------------------------------------------------------
    vec2 Lightmap = texture2D(colortex2, TexCoords).rg;
    vec3 LightmapColor = GetLightmapColor(Lightmap);
//----------------------------------------------------------------------------------
    float Depth = texture2D(depthtex0, TexCoords).r;
//----------------------------------------------------------------------------------
    vec3 screenPos = vec3(TexCoords, texture2D(depthtex0, TexCoords).r);
    vec3 clipPos = screenPos * 2.0 - 1.0;
    vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
    vec3 viewPos = tmp.xyz / tmp.w;
    vec3 P_world = (gbufferModelViewInverse * vec4(viewPos,1.0)).xyz + cameraPosition;
    float motion = simplex3d_fractal(P_world/30+pow(frameTimeCounter, 0.3));
//----------------------------------------------------------------------------------
    float FogDistance = length(viewPos);
    float FogDistanceSetup = smoothstep(FogStart, FogEnd, FogDistance*FogDefaultDensity*Raining);
    vec3 L = mat3(gbufferModelViewInverse) * normalize(shadowLightPosition.xyz);
    vec4 world_position = gbufferModelViewInverse * vec4(viewPos, 1.0);
    vec3 rd = normalize(vec3(world_position.x,world_position.y,world_position.z));
    float sunAmount = max(dot(rd, L), 0.0);
//----------------------------------------------------------------------------------

    if(Depth == 1.0f){
        gl_FragData[0] = vec4(Albedo, 1.0f);
        return;
    }
//=============================REALSHADOWS==================================================================
#ifdef ShadowRendering
    float NdotL = max(dot(Normal, normalize(shadowLightPosition)), 0.0f);
    float Id =  texture2D(colortex6, TexCoords).r * 255;

    if(Id == 2.0 || Id == 2.0){
      NdotL = 0.14*TimeSunrise+0.5*TimeNoon+0.25*TimeSunset+0.5*TimeMidnight;
    }

    vec3 Diffuse = Albedo  * (LightmapColor + (NdotL * GetShadow(Depth))*6*LightingMultiplayer + Ambient);

    #ifdef Fog
    if(Depth < 1.0){
    Diffuse = mix(Diffuse, vec3(0.8, 0.66, 0.5), FogDistanceSetup);
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
    if(Depth < 1.0){
    Diffuse = mix(Diffuse,  mix(skyColor, fogColor, pow(sunAmount, 2.0)), FogDistanceSetup);
    }
    #endif

#endif
//===============================================================================================
    gl_FragData[0] = vec4(Diffuse, 1.0f);
}

float NdotL = normalMat.x;
float diffuseSun = clamp(NdotL,0.0f,1.0f);
vec3 direct = lightCol.rgb;


//compute shadows only if not backface
if (diffuseSun > 0.001) {

  mat2 time = mat2(vec2(
  				((clamp(timefract, 23000.0f, 25000.0f) - 23000.0f) / 1000.0f) + (1.0f - (clamp(timefract, 0.0f, 2000.0f)/2000.0f)),
  				((clamp(timefract, 0.0f, 2000.0f)) / 2000.0f) - ((clamp(timefract, 9000.0f, 12000.0f) - 9000.0f) / 3000.0f)),

  				vec2(
//[0[1]
  				((clamp(timefract, 9000.0f, 12000.0f) - 9000.0f) / 3000.0f) - ((clamp(timefract, 12000.0f, 12750.0f) - 12000.0f) / 750.0f),
  				((clamp(timefract, 12000.0f, 12750.0f) - 12000.0f) / 750.0f) - ((clamp(timefract, 23000.0f, 24000.0f) - 23000.0f) / 1000.0f))
  );	//time[0].xy = sunrise and noon. time[1].xy = sunset and mindight.

  float transition_fading = 1.0-(
      clamp(0.00333333*timefract - 40.,0.0,1.0)-
      clamp(0.00333333*timefract - 43.3333,0.0,1.0)+
      clamp(0.005*timefract - 110.,0.0,1.0)-
      clamp(0.005*timefract - 117.,0.0,1.0)
  );
