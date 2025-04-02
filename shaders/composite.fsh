
#version 120

#define LinearFog

#define FogAffectSky 0 //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define FogAffectClouds 0.75 //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define FogStart 20     //[0 5 10 20 30 40 50 60 70 80 90 100 200 300 500 1000]
#define FogEnd 300  //[0 5 10 20 30 40 50 60 70 80 90 100 200 300 500 1000]
#define FogDensity 1     //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0]

#define SmoothShadows
#define ShadowDarkness 1.25 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4]

//#define RenderShadowMap
#define ShadowMapIntensity 0.235 //[0.05 0.075 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.235 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.4 0.5 0.6 0.7 0.9 1.0]
#define shadowMapSmoothness 0.0075  //[0.0001 0.0002 0.0003 0.0004 0.0005 0.0006 0.0007 0.0075 0.0008 0.0009 0.001]

#define Flickr
#define FlickrSpeed 10 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 15 20 30 40 50]
#define FlickrIntensity 16  //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 30 40 50]

#define Ambient 0.55
#define TorchIntensity 1.5
#define LMapR 1   //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 4 5 6 7 8 9 10 15 20 30 40 50]
#define LMapG 1   //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 4 5 6 7 8 9 10 15 20 30 40 50]
#define LMapB 1  //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 4 5 6 7 8 9 10 15 20 30 40 50]

//#define Godrays
#define  density 1.0          //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0]
#define  power 1.0         //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4]
#define  jitter_quallity 0.5  //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0]
#define  decay 0.95       //[0.8 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0  1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4]      // Затухание (например, 0.95)
#define  samples 8     //[2 4 8 16 32 64 128]

#define RainPuddles
#define PuddlesIntensity 0.8 //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0]

#define SkyColorAffectLightmap 0.75 //[0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.7 0.7 0.8 0.9 1.0]
#define LightIntensity 1.0 //[0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.7 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0]
#define DetectWaterDepth

//#define Transmittance

#define Reflections
#define ReflectionIntensity 0.5 //[0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.7 0.7 0.8 0.9 1.0]

#define Foam
#define FoamDistance 1.5  //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 4 5 6 7 8 9 10 15 20 30 40 50]

//#define DebugMode
#define Renderer colortex1 //[colortex0 colortex1 normals colortex2 colortex4 colortex5 colortex6 colortex7 depthtex0 shadowtex0 ]
//--------------------------------------------------------------------------------------------
varying vec4 texcoord;
varying vec2 TexCoords;
uniform sampler2D texture;
uniform float aspectRatio;
uniform float viewWidth;
uniform float viewHeight;
varying vec4 glcolor;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D colortex9;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D gaux5;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform vec3 cameraPosition;
uniform int worldTime;
uniform float frameTimeCounter;
uniform float near;
uniform float far;
uniform sampler2D normals;
uniform vec3 shadowLightPosition;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex0HW;
uniform sampler2D noisetex;
uniform sampler2D gaux4;
uniform ivec2 eyeBrightnessSmooth;
uniform ivec2 eyeBrightness;
uniform vec3 upPosition;
uniform int isEyeInWater;


uniform float wetness;
const float wetnessHalflife = 700.0f;
const float drynessHalflife = 100.0f;

float Raining =  clamp(wetness, 0.0, 1.0);

#ifdef RenderShadowMap
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;
const float shadowIntervalSize = 100; // [1 10 50 100]
const int shadowMapResolution = 512;  // [32 64 128 256 512 1024 2048 4096 8192]
const float shadowDistance = 160.0f; // [12.0f 32.0f 48.0f 64.0f 84.0f 120.0f 160.0f 200.0f]
const bool shadowtexNearest = false;
const bool shadowcolor0Nearest = false;
#endif


const float ambientOcclusionLevel = 1.0f; //[0.0f 1.0f]
const float eyeBrightnessHalflife = 3.0f;

float eyeAdaptY = eyeBrightnessSmooth.y / 240.0; //sky
float eyeAdaptX = eyeBrightnessSmooth.x / 180.0; //block

float Id =  texture2D(colortex6, TexCoords).r * 255;

float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
const float sunPathRotation = -20.0f; //[-240f -120f -90f -60f -30f -20.0f 0f 30f 60f 120f 240f]
vec3 TimeColor = (fogColor*TimeSunrise +fogColor*TimeNoon + fogColor*TimeSunset +fogColor*TimeMidnight);
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 BiliaterBlur(vec2 uv) {
  vec3 color = texture2D(texture, uv).rgb * 0.2;

   float offset = 0.004; // Увеличенный offset для сильного размытия

   color += texture2D(texture, uv + vec2(offset, 0)).rgb * 0.2;
   color += texture2D(texture, uv - vec2(offset, 0)).rgb * 0.2;
   color += texture2D(texture, uv + vec2(0, offset)).rgb * 0.2;
   color += texture2D(texture, uv - vec2(0, offset)).rgb * 0.2;

   // Добавляем диагональные смещения для ещё большего размытия
   color += texture2D(texture, uv + vec2(offset, offset)).rgb * 0.1;
   color += texture2D(texture, uv - vec2(offset, offset)).rgb * 0.1;
   color += texture2D(texture, uv + vec2(-offset, offset)).rgb * 0.1;
   color += texture2D(texture, uv + vec2(offset, -offset)).rgb * 0.1;

   return color;
}

vec3 LightmapSetup(in vec2 LMap)
{

float cave = smoothstep(1.0, 0.7, LMap.y);
float undersky = smoothstep(0.69, 0.0, LMap.y);

//vec3 SkyLighting = LMap.y * mix(glcolor.rgb, TimeColor.rgb,  SkyColorAffectLightmap) + (cave  / 6) ;
vec3 SkyLighting = LMap.y * mix(glcolor.rgb, TimeColor.rgb,  SkyColorAffectLightmap)  ;///clamp(cave, 1, 1.1)
//vec3 LightLighting = AdjustLightmapTorch(LMap.x) * vec3(1,0.7,0.5) + (cave * 0.01) ;
float R = 2.0;

#ifdef Flickr
float Time = max(frameTimeCounter, 1000)*FlickrSpeed;
R = 2.0  + sin(Time)/FlickrIntensity ;
#endif

if (LMap.y < 0.1){
  R = 4.0;
}

vec3 LightLighting = pow(LMap.x, R) * vec3(1,0.7,0.5) * TorchIntensity;
//vec3 LightLighting = AdjustLightmapTorch(LMap.x) * vec3(1,0.7,0.5) *(cave * 1) ;

vec3 Lighting = SkyLighting + LightLighting;



return Lighting*1.1 ;
}




float getDepth(vec2 coord) {
    return 2.0 * near * far / (far + near - (2.0 * texture2D(depthtex0, coord).x - 1.0) * (far - near));
}

float get_linear_depth(in float depth)
{
      return 2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near));
}

#include "files/noise.glsl"


vec3 toScreenSpace(vec3 worldPos) {
    vec4 clipPos = gbufferProjection * gbufferModelView * vec4(worldPos, 1.0); // Перевод в Clip Space
    vec3 ndcPos = clipPos.xyz / clipPos.w;  // Перевод в NDC (-1 до 1)

    // Преобразование в координаты экрана (0 до screenSize)
    vec2 screenPos = (ndcPos.xy * 0.5 + 0.5);

    return vec3(screenPos, ndcPos.z); // z остается для глубины
}



void main() {

vec3 screenPos = vec3(TexCoords, texture2D(depthtex0, TexCoords).r);
vec3 clipPos = screenPos * 2.0 - 1.0;
vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
vec3 viewPos = tmp.xyz / tmp.w;



vec4 tpos = vec4(shadowLightPosition,1.0)*gbufferProjection;
tpos = vec4(tpos.xyz/tpos.w,1.0);

vec2 LightPos = tpos.xy/tpos.z;
vec2 Godray = LightPos*0.5+0.5;

vec3 viewDirection = normalize(viewPos);
vec4 worldPos = gbufferModelViewInverse * vec4(viewPos, 1.0);

vec3 feetPlayerPos = worldPos.xyz + gbufferModelViewInverse[3].xyz;
vec3 worldPos2 = feetPlayerPos + cameraPosition;

bool isCloud = texture2D(colortex7, TexCoords).x > 0f;
bool isHand =   texture2D(colortex8, TexCoords).x > 0f;
bool isParticle =   texture2D(colortex9, TexCoords).x > 0f;
float Depth = texture2D(depthtex0, texcoord.xy).r;

vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);
vec3 WorldNormal = mat3(gbufferModelViewInverse) * Normal;
vec3 WorldLight = mat3(gbufferModelViewInverse)*shadowLightPosition; //problem

vec4 color = texture2D(texture, texcoord.st) *glcolor ;

vec2 Lightmap = texture2D(colortex2, texcoord.xy).xy;
//shadow_lightmap
float LightmapSmooth =  smoothstep(0.915 ,smoothstep(0.91,0.935,1.0 ),Lightmap.y);
//float LightmapSmooth2 =  smoothstep(0.8,0.85,Lightmap.y);

float NdotL = max(dot(Normal, normalize(shadowLightPosition)), 0.0f);
float cave = smoothstep(1.0, 0.7, Lightmap.y);
if (WorldNormal.y > 0.9) NdotL = 1.0;  // Yeah, i'm a cool programmer
if (WorldNormal.y < -0.9) NdotL = 0.8;
if (abs(WorldNormal.y) < 0.5) NdotL = 0.5+(cave /2); // Ни

if (Id == 1.0 || Id == 2.0 || Id == 3.0 || Id == 4.0 || isHand){
 NdotL = 1;
}

vec4 LightmapSmoothColor = vec4(1.0);
//vec4 LightmapSmoothColor = vec4(1,1,1,1)/6;
#ifdef SmoothShadows
 LightmapSmoothColor = vec4(LMapR,LMapB,LMapG,1) * LightmapSmooth ;
#else
if (Lightmap.y < 0.915){
  LightmapSmoothColor -= vec4(0.15);
}
#endif

#ifdef RenderShadowMap
vec4 shadowSpace =  shadowProjection * shadowModelView * worldPos;
vec3 shadowCoords = shadowSpace.xyz * 0.5f + 0.5f;

float shadowColor = texture2D(shadowtex0, shadowCoords.xy).r;

float getShadow = smoothstep(shadowCoords.z - shadowMapSmoothness, shadowCoords.z, shadowColor) * 1;
getShadow = mix(1.0, getShadow, ShadowMapIntensity);
#endif

//vec4 LightmapSmoothColor = vec4(1,1,1,1) * mix(LightmapSmooth2/4, LightmapSmooth, 0.9);
vec4 LightmapColor = vec4(LightmapSetup(Lightmap), 1.0);

//fog
float FogDist = length(viewPos)+Raining*20;
  float Fog2Dist =  exp( FogDist *0.075 );
float Fog = smoothstep(FogStart, FogEnd, FogDist)*FogDensity ;
vec3 FogColor = TimeColor ;

//float Exposure = clamp(eyeAdaptX, eyeAdaptY,1);

#ifdef RenderShadowMap
//if (Id == 1 || Id == 2 || Id == 3 || Id == 4){
  //NdotL = 0.5;
//}
//vec4 Diffuse =    color  *LightmapColor*(NdotL+0.75)-getShadow  /ShadowDarkness;
vec4 Diffuse = color*LightIntensity*NdotL*LightmapColor*getShadow;
#else
vec4 Diffuse = color*LightIntensity*NdotL *LightmapColor/ShadowDarkness*(1+LightmapSmoothColor*(ShadowDarkness*ShadowDarkness)) ;
#endif

#ifdef LinearFog
Diffuse.rgb = mix(Diffuse.rgb, FogColor, Fog);
#endif

#ifdef Godrays

vec2 texCoord = texcoord.xy;
vec2 deltaTexCoord = (texCoord - Godray) * (1.0 / float(samples)) * density;

float illuminationDecay = 0.05;
vec3 godRayColor;

float threshold = 0.99 * far;
float sdc;
//float dotProduct = dot(viewPos, shadowLightPosition);
 //threshold = smoothstep(0.1, 1.0, dotProduct);  // 0.1 - порог, на котором начинается затухание

for(int i = 0; i < samples; i++) {
    float jitter = (rand(texCoord + vec2(float(i))) - 0.5) * 2;
    jitter =  (1.0 + jitter * jitter_quallity);
    texCoord -= deltaTexCoord* jitter; // 0.1;

    if (getDepth(texCoord) > threshold  ) {

    sdc = texture2D(texture, texCoord).x;

    }
        vec3 sampleColor = texture2D(texture, texCoord).rgb;
    //  vec3 sampleColor = BiliaterBlur(texCoord);

    sampleColor.rgb = fogColor;

    sampleColor *= illuminationDecay * sdc;
    godRayColor += sampleColor*power;
    illuminationDecay *= decay;
}


//float dotProduct = dot(normalize(shadowLightPosition), cameraPosition);
  //dEBUG   Diffuse.rgb  = mix(godRayColor,    Diffuse.rgb , 0);
     Diffuse.rgb +=godRayColor;

#endif
vec3 lightDir = normalize(shadowLightPosition);
vec3 viewDir = -normalize(viewPos);
vec3 halfDir = normalize(lightDir + viewDir);

#ifdef Reflections
vec3 reflectColor = vec3(0);

vec3 reflectionDirection = reflect(feetPlayerPos, WorldNormal );




vec3 screenSpaceReflectionPos = toScreenSpace(reflectionDirection);

reflectColor = texture(texture, screenSpaceReflectionPos.xy).rgb;

float borderDistX = min(screenSpaceReflectionPos.x, 1.0 - screenSpaceReflectionPos.x);
float borderDistY = min(screenSpaceReflectionPos.y, 1.0 - screenSpaceReflectionPos.y);
float minBorderDist = min(borderDistX, borderDistY);

float fadeFactor = smoothstep(0.0, 0.5, minBorderDist);
#endif

float  SpecularAngle  = pow(max(dot(halfDir, Normal  *texture2D(normals, TexCoords).rgb), 0.0), 8) * 1000;

#ifdef RainPuddles
 if(Id == 1.0 || isHand){
   }else
   {

 vec2 puddlesCoord = (worldPos2.xz/5000);

float rainPuddles = texture2D(noisetex, (puddlesCoord.xy*8)).x;
vec4 RainPuddlesTexture = rainPuddles *  texture2D(gaux4, worldPos2.xz)*vec4(0.25,0.25,0.25,1.0)*dot(Normal,normalize(upPosition))*PuddlesIntensity ;
float undersky = smoothstep(0.0, 1.0, Lightmap.y);

 Diffuse += RainPuddlesTexture*   undersky*(dot(Normal,normalize(upPosition))+SpecularAngle  )  *Raining;
  }
#endif




//sky
if(Depth == 1.0f ){

  float sunVector = max(dot( viewDirection , normalize(shadowLightPosition)), 0.0);
  	float sun = pow(sunVector, 5.5);

  	float horizonPos = dot(viewDirection, upPosition);
  	float smoothHorizonPos 	= pow(max(1.0 - abs(horizonPos) * 0.009  , 0.0), 3.0);
    float sunDist = distance(smoothHorizonPos, sun);
//float sunScatter = pow(max(sunDist, 0.0), 15.0); // Чем выше степень, тем резче эффект
//float sunScatter = pow(max(sun, 0.0),abs(horizonPos*50)); // Чем выше степень, тем резче эффект
	vec3 horizonVec = normalize(upPosition+viewDirection);

      // float sunDistance = distance(viewVec, clamp(SunVector, -1.0, 1.0));
     //	 sunDistance = distance(viewVec, clamp(SunVector, -1.0, 1.0));
vec3 CustomSky = mix(color.rgb , FogColor  , smoothHorizonPos  )  ;
//vec3 cky = mix(color.rgb, CustomSky, 0.5);
    gl_FragData[0] =  vec4(CustomSky, 1.0f);
  //  gl_FragData[0] =   mix(color, vec4(mix(color.rgb, FogColor, Fog), 1.0), FogAffectSky);
    return;
}

if(isCloud){
  Diffuse = mix(color, vec4(mix(Diffuse.rgb, FogColor, Fog), 1.0), FogAffectClouds) ;
}

if(Id == 1.0){
#ifdef DetectWaterDepth

    float depth_solid = get_linear_depth(texture2D(depthtex0, TexCoords).x);
    float depth_translucent = get_linear_depth(texture2D(depthtex1, TexCoords).x);

    float dist_fog = distance(depth_solid, depth_translucent);
//dist btw solid and fog
    vec3 WATER_FOG_COLOR = vec3(0.4, 0.07, 0.03);
    vec3 absorption = exp(-vec3(0.10)/4 * dist_fog) ;
    //Bedrok water Diffuse.rgb *= vec3(76, 97, 86)/128;

    #ifdef Foam
    float foam = smoothstep(FoamDistance, 0.0, dist_fog);
    Diffuse.rgb += vec3(0.2)*foam ;
    #endif

    #ifdef Transmittance
    if (dist_fog  < 200){
          Diffuse.rgb *= absorption;
    }

    #endif
#endif

#ifdef Reflections
if (isEyeInWater == 1){
}else{
Diffuse.rgb = mix(Diffuse.rgb, (mix(reflectColor, Diffuse.rgb, ReflectionIntensity)), fadeFactor);
}
#endif

Diffuse = Diffuse+SpecularAngle/1000;
Diffuse.rgb = mix(Diffuse.rgb, FogColor, Fog)  ;
}//*texture2D(gaux4,  worldPos2.xz).rgb*2;
//gl_FragData[0] =Diffuse*texture2D(gaux4,worldPos2.xz/200) +rainPuddles /4 ;

if (isParticle || Depth > 1){
  Diffuse.rgb = color.rgb;
}

gl_FragData[0] = Diffuse;

if (isEyeInWater == 1){
  gl_FragData[0] = mix(Diffuse, vec4(0,0.5,2,1)/2*smoothstep(2, 30, FogDist), 0.5)  ;
}
#ifdef DebugMode
vec4 DebugGbuffer = texture2D(Renderer, texcoord.st);
gl_FragData[0] =DebugGbuffer;
#endif
}
