#version 120
//----------------------------------------------------INCLUDE----------------------------------------------
//#define WaterSpecularTech
#ifdef WaterSpecularTech

#endif

#define SpecularTerrain
//----------------------------------------------------UNIFORMS----------------------------------------------
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec3 skyColor;
varying vec3 fogColor;
varying vec4 Color;
uniform sampler2D noisetex;
uniform float rainStrength;
uniform sampler2D texture;
varying vec4 texcoord;
//in  float BlockId;
varying vec2 lmcoord;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex11;
uniform float frameTimeCounter;
varying vec3 vworldpos;
varying vec3 SkyPos;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;
varying vec3 viewPos;
varying vec3 upPosition;
varying vec4 vpos;
uniform int isEyeInWater;
flat in int BlockID;
uniform int worldTime;
uniform sampler2D gaux4;
uniform sampler2D gaux5;
uniform sampler2D lightmap;
uniform sampler2D normals;


/*
const int colortex2Format = RGBA32;
*/

//----------------------------------------------------DEF----------------------------------------------
#define specularTerrainStrenght 2 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define FakeCaustic
#define FakeCloudShadows
//#define UglyNormalMapping
#define Transparency 0.8 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1]
#define SpecularIntesity 2.5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define SpecularRadius 8 //[1 2 4 8 16 32 64 128]
//----------------------------------------------------CONST----------------------------------------------

//--------------------------------------------------------------------------------------------------------

void main(){
//--------------------------------------------------------------------------------------------------------

  int id = int(BlockID + 0.5);
//----------------------------------------------------SPECULAR----------------------------------------------
  vec3 ShadowLightPosition = normalize(shadowLightPosition);
  vec3 NormalDir = normalize(Normal);
  vec3 TNormals = texture2D(normals, TexCoords).rgb;
  vec3 lightDir = normalize(ShadowLightPosition);

vec3 TextureNormals = normalize(TNormals);

  vec3 viewDir = -normalize(viewPos);
  vec3 halfDir = normalize(lightDir + viewDir);
  vec3 reflectDir = reflect(lightDir, viewDir);
   vec3 R = reflect(-ShadowLightPosition, Normal);
    float NdotL = max(dot(TNormals, normalize(lightDir)), 0.0f);

    float SpecularAngle = pow(max(dot(halfDir, Normal*texture2D(texture, TexCoords).rgb), 0.0), SpecularRadius);
    float SpecularAngleT = pow(max(dot(halfDir, Normal*texture2D(texture, TexCoords).rgb), 0.0), 12);
//---------------------------------------------------CAUSIC-------------------------------------------------

#ifdef UglyNormalMapping
vec4 Albedo = texture2D(texture, TexCoords)*TNormals.r*2   * Color;
#else
vec4 Albedo = texture2D(texture, TexCoords) * Color;
#endif
//----------------------------------------SPECULAR--------------------------------------------------------


if(id == 1){

 Albedo += (SpecularAngle *mix(vec4(1), vec4(fogColor, 1), 0.5))*SpecularIntesity;
 Albedo.a = Transparency;
}

#ifdef SpecularTerrain
if(id == 5){

 Albedo += (SpecularAngleT *mix(vec4(1), vec4(fogColor, 1), 0.5))*5*SpecularIntesity;

}
#endif

  vec4 Lightmap = texture2D(lightmap, LightmapCoords);
  float LightmapSmooth =  smoothstep(0.95,smoothstep(0.91,0.95,1.0),lmcoord.y);



//--------------------------------------------------------------------------------------------------------

    /* DRAWBUFFERS:0126 */

  //  gl_FragData[0] = Albedo2+(Albedo *LightmapSmooth/2);

     gl_FragData[0] = Albedo ;
    gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);
    gl_FragData[3] = vec4(float(BlockID) / 255, 0, 0, 1); //writing the block data to a buffer
}
