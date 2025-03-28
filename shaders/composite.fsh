
#version 120

#define LinearFog

#define FogAffectSky 0 //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define FogAffectClouds 0.75 //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define FogStart 20     //[0 5 10 20 30 40 50 60 70 80 90 100 200 300 500 1000]
#define FogEnd 130  //[0 5 10 20 30 40 50 60 70 80 90 100 200 300 500 1000]
#define FogDensity 1     //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0]

#define SmoothShadows
#define ShadowDarkness 1.25 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4]

#define Flickr
#define FlickrSpeed 10 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 15 20 30 40 50]
#define FlickrIntensity 12  //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 30 40 50]

#define Ambient 0.55
#define LMapR 1   //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 4 5 6 7 8 9 10 15 20 30 40 50]
#define LMapG 1   //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 4 5 6 7 8 9 10 15 20 30 40 50]
#define LMapB 1  //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 4 5 6 7 8 9 10 15 20 30 40 50]

//#define Godrays
#define  density 1.0          //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0]
#define  power 1.0         //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4]
#define  jitter_quallity 0.5  //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0]
#define  decay 0.95       //[0.8 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0  1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4]      // Затухание (например, 0.95)
#define  samples 8     //[2 4 8 16 32 64 128]
#define SkyColorAffectLightmap 0.75   //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
#define DetectWaterDepth
//#define Transmittance

//#define DebugMode
#define Renderer colortex1 //[colortex0 colortex1 colortex2 colortex4 colortex5 colortex6 colortex7 depthtex0 shadowtex0 ]
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
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D gaux5;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform int worldTime;
uniform float frameTimeCounter;
uniform float near;
uniform float far;
uniform sampler2D normals;
uniform vec3 shadowLightPosition;
uniform sampler2D shadowtex0;
uniform ivec2 eyeBrightnessSmooth;
uniform ivec2 eyeBrightness;

in vec4 at_tangent;
in vec3 vaNormal;

const float ambientOcclusionLevel = 1.0f;
const float eyeBrightnessHalflife = 3.0f;

float eyeAdaptY = eyeBrightnessSmooth.y / 240.0; //sky
float eyeAdaptX = eyeBrightnessSmooth.x / 180.0; //block

float Id =  texture2D(colortex6, TexCoords).r * 255;

float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
const float sunPathRotation = -20.0f;
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

float AdjustLightmapTorch(in float torch ) {


       float K =2;

       #ifdef Flickr
       float Time = max(frameTimeCounter, 1000)*FlickrSpeed;
       float R = 2+ sin(Time)/FlickrIntensity ;
       #else
       float R = 2.0f;
       #endif

      return K * pow(torch, R);
}

vec3 LightmapSetup(in vec2 LMap)
{

float cave = smoothstep(1.0, 0.7, LMap.y);

vec3 SkyLighting = LMap.y * mix(TimeColor.rgb, glcolor.rgb, SkyColorAffectLightmap) ;
vec3 LightLighting = AdjustLightmapTorch(LMap.x) * vec3(1,0.7,0.5) *(cave * 1);

vec3 Lighting = SkyLighting + LightLighting;



return Lighting*1.1;
}

float getDepth(vec2 coord) {
    return 2.0 * near * far / (far + near - (2.0 * texture2D(depthtex0, coord).x - 1.0) * (far - near));
}

float get_linear_depth(in float depth)
{
      return 2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near));
}


void main() {

vec3 screenPos = vec3(TexCoords, texture2D(depthtex0, TexCoords).r);
vec3 clipPos = screenPos * 2.0 - 1.0;
vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);

vec3 viewPos = tmp.xyz / tmp.w;

vec4 tpos = vec4(shadowLightPosition,1.0)*gbufferProjection;
tpos = vec4(tpos.xyz/tpos.w,1.0);

bool isCloud = texture2D(colortex7, TexCoords).x > 0f;

float Depth = texture2D(depthtex0, texcoord.xy).r;
vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);

vec3 WorldLight = mat3(gbufferModelViewInverse)*shadowLightPosition; //problem

vec4 color = texture2D(texture, texcoord.st) *glcolor ;

vec2 Lightmap = texture2D(colortex2, texcoord.xy).xy;
//shadow_lightmap
float LightmapSmooth =  smoothstep(0.915 ,smoothstep(0.91,0.935,1.0 ),Lightmap.y);
float LightmapSmooth2 =  smoothstep(0.8,0.85,Lightmap.y);
//float LightmapSmooth2 =  smoothstep(0.8,0.9,Lightmap.y);
float NdotL = max(dot(Normal, normalize(shadowLightPosition)), 0.0f);

vec4 LightmapSmoothColor = vec4(1,1,1,1)/6;

#ifdef SmoothShadows
 LightmapSmoothColor = vec4(LMapR,LMapB,LMapG,1) * LightmapSmooth;
#else
if (Lightmap.y < 0.915){
  LightmapSmoothColor -= vec4(0.15);
}
#endif
//vec4 LightmapSmoothColor = vec4(1,1,1,1) * mix(LightmapSmooth2/4, LightmapSmooth, 0.9);
vec4 LightmapColor = vec4(LightmapSetup(Lightmap), 1.0);

//fog
float FogDist = length(viewPos);
float Fog = smoothstep(FogStart, FogEnd, FogDist)*FogDensity;
vec3 FogColor = TimeColor;

float Exposure = clamp(eyeAdaptX, eyeAdaptY,1);
vec4 Diffuse = color*LightmapColor/ShadowDarkness*(1+LightmapSmoothColor*(ShadowDarkness*ShadowDarkness))  ;

#ifdef LinearFog
Diffuse.rgb = mix(Diffuse.rgb, FogColor, Fog);
#endif


#ifdef Godrays
vec2 LightPos = tpos.xy/tpos.z;
vec2 Godray = LightPos*0.5+0.5;
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

//sky
if(Depth == 1.0f ){
    gl_FragData[0] = mix(color, vec4(mix(color.rgb, FogColor, Fog), 1.0), FogAffectSky) ;
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

    vec3 absorption = exp(-vec3(0.10)/4 * dist_fog) ;

    if (dist_fog <= 0.3){
    Diffuse.rgb += vec3(0.1);
    }

    #ifdef Transmittance
    Diffuse.rgb *= absorption  ;
    #endif

#endif
Diffuse = Diffuse;
Diffuse.rgb = mix(Diffuse.rgb, FogColor, Fog);
}



gl_FragData[0] =Diffuse;
#ifdef DebugMode
vec4 DebugGbuffer = texture2D(Renderer, texcoord.st);
gl_FragData[0] =DebugGbuffer;
#endif
}
