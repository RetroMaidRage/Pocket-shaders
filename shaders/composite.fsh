
#version 120

#define FogStart 20     //[0 5 10 20 30 40 50 60 70 80 90 100 200 300 500 1000]
#define FogEnd 130  //[0 5 10 20 30 40 50 60 70 80 90 100 200 300 500 1000]
#define FogDensity 1     //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0]
#define ShadowDarkness 1.35 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4]
#define LambertFactor 0
#define Ambient 0.55

#define FogAffectSky 0 //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define FogAffectClouds 0.75 //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define LinearFog

#define Godrays
#define  density 1.0          //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0]
#define  power 1.0         //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4]
#define  jitter_quallity 0.5  //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0]
#define  decay 0.95       //[0.8 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0  1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4]      // Затухание (например, 0.95)
#define  samples 8     //[2 4 8 16 32 64 128]

//#define DebugMode
#define Renderer colortex1 //[colortex0 colortex1 colortex2 colortex4 colortex5 colortex6 colortex7 depthtex0]
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
uniform sampler2D gaux5;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform int worldTime;
uniform float near;
uniform float far;
uniform sampler2D normals;
uniform vec3 shadowLightPosition;

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
const float sunPathRotation = -10.0f;
vec3 TimeColor = (fogColor*TimeSunrise +fogColor*TimeNoon + fogColor*TimeSunset +fogColor*TimeMidnight);
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float henyeyGreenstein(float g, float cosTheta) {
    float g2 = g * g;
    return (1.0 - g2) / (4.0 * 3.141592653589793 * pow(1.0 + g2 - 2.0 * g * cosTheta, 1.5));
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




       float K =2 ;
       float P =  2.06f;
    //   float LightmapSmooth =  smoothstep(0.915 ,smoothstep(0.91,0.935,1.0 ),sky);
      // if (sky < 0.99){
      //   K =12  .5;;
    //   }
      return K * pow(torch, P);
}

vec3 LightmapSetup(in vec2 LMap)
{

float cave = smoothstep(1.0, 0.7, LMap.y);
float cave2 = smoothstep(1.0, 0.7, LMap.x);
vec3 SkyLighting = LMap.y * mix(TimeColor.rgb, glcolor.rgb, 0.75) ;
vec3 LightLighting = AdjustLightmapTorch(LMap.x) * vec3(1,0.7,0.5) *(cave * 1);

vec3 Lighting = SkyLighting + LightLighting;



return Lighting*1.25;
}
float getDepth(vec2 coord) {
    return 2.0 * near * far / (far + near - (2.0 * texture2D(depthtex0, coord).x - 1.0) * (far - near));
}

mat3 tbnNormalTangent(vec3 normal, vec3 tangent) {
    // For DirectX normal mapping you want to switch the order of these
    vec3 bitangent = cross(normal, tangent);
    return mat3(tangent, bitangent, normal);
}

void main() {



vec3 screenPos = vec3(TexCoords, texture2D(depthtex0, TexCoords).r);
vec3 clipPos = screenPos * 2.0 - 1.0;
vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);

vec3 viewPos = tmp.xyz / tmp.w;

vec4 tpos = vec4(shadowLightPosition,1.0)*gbufferProjection;
tpos = vec4(tpos.xyz/tpos.w,1.0);
  //----------------------------------------------------------------
vec2 LightPos = tpos.xy/tpos.z;
vec2 Godray = LightPos*0.5+0.5;

bool isCloud = texture2D(colortex7, TexCoords).x > 0f;

float Depth = texture2D(depthtex0, texcoord.xy).r;

vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);



vec3 WorldNormal = mat3(gbufferModelViewInverse)*Normal; //problem
vec3 WorldLight = mat3(gbufferModelViewInverse)*shadowLightPosition; //problem

vec3 WorldTangent = mat3(gbufferModelViewInverse)*at_tangent.xyz;

vec4 TexNormal = texture2D(normals, TexCoords);
vec3 TextureNormal = vec3(TexNormal.xy, sqrt(1.0 - dot(TexNormal.xy, TexNormal.xy)))*2.0 - 1.0;



mat3 TBN = tbnNormalTangent(WorldNormal, WorldTangent.rgb);

vec3 WorldSpaceNormal = TBN * TextureNormal;


vec4 color = texture2D(texture, texcoord.st) *glcolor ;


vec2 Lightmap = texture2D(colortex2, texcoord.xy).xy;

float LightmapSmooth =  smoothstep(0.915 ,smoothstep(0.91,0.935,1.0 ),Lightmap.y);
float LightmapSmooth2 =  smoothstep(0.85,0.9,Lightmap.y);


//vec3 NdotL2 = WorldSpaceNormal - normalize(WorldLight );
//float NdotL = max(dot(normalize(WorldLight), WorldSpaceNormal), 0.0f);
//float LightmapSmooth =  smoothstep(Lightmap.y/0.915 ,smoothstep(0.91,0.935,1.0 ),Lightmap.y);

    float NdotL = max(dot(Normal, normalize(shadowLightPosition)), 0.0f);

vec4 LightmapSmoothColor = vec4(1,1,1,1) * mix(LightmapSmooth2/4, LightmapSmooth, 0.9);
vec4 LightmapColor = vec4(LightmapSetup(Lightmap), 1.0);

//--------------------------------------------------------------------------------------------
//if (Lightmap.y < 0.93){
//  color -= 0.1;
//}

//float LightmapSmooth =  smoothstep(0.915,0.935,Lightmap.y);
//vec4 Diffuse = color*LightmapColor*(LightmapColor+LightmapSmoothColor/2);

float FogDist = length(viewPos);
float Fog = smoothstep(FogStart, FogEnd, FogDist)*FogDensity;

vec3 FogColor = TimeColor;
//vec3 FogColor = pow(TimeColor, vec3(2.2))*Fog*FogDensity;

if(Id == 1.0){
//  FogColor = vec3(0);
}

//vec4 Diffuse = color*(LightmapSmoothColor+color*2) ;
//-----------------------------------vec4 Diffuse = color*(LightmapColor+LightmapSmoothColor) ;
float Exposure = clamp(eyeAdaptX+Ambient, eyeAdaptY,1);
vec4 Diffuse = color*LightmapColor/ShadowDarkness*(1+LightmapSmoothColor*(ShadowDarkness*ShadowDarkness)) ;
//vec4 Diffuse = color*Exposure*LightmapColor/ShadowDarkness ;
//vec4 Diffuse = color*LightmapColor/2*(1+LightmapSmoothColor*5) ; - темнее

//vec4 Diffuse = color*LightmapColor*(LightmapColor/2+LightmapSmoothColor*22);

//vec4 Diffuse = color*LightmapColor*(LightmapColor/2 - уменьшение всего +LightmapSmoothColor*22 умножение освещенности);
//vec4 Diffuse = color*LightmapColor*(LightmapColor+vec4(SmColor, 1.0)*22);
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
  //  vec3 sampleColor = BiliaterBlur(texCoord);
    sampleColor *= illuminationDecay * sdc;
    godRayColor += sampleColor*power;
    illuminationDecay *= decay;
}


float dotProduct = dot(normalize(shadowLightPosition), cameraPosition);
  //dEBUG   Diffuse.rgb  = mix(godRayColor,    Diffuse.rgb , 0);
     Diffuse.rgb +=godRayColor;




#endif
if(Depth == 1.0f ){ //if it is Sky

    gl_FragData[0] = mix(color, vec4(mix(color.rgb, FogColor, Fog), 1.0), FogAffectSky);
    return;
}

if(isCloud){

  Diffuse = mix(color, vec4(mix(Diffuse.rgb, FogColor, Fog), 1.0), FogAffectClouds);
}

  if(Id == 1.0){
Diffuse = Diffuse;
  }


	//gl_FragData[0] = vec4(WorldSpaceNormal, 1.0);

gl_FragData[0] =Diffuse;
#ifdef DebugMode
vec4 DebugGbuffer = texture2D(Renderer, texcoord.st);
gl_FragData[0] =DebugGbuffer;
#endif
}
