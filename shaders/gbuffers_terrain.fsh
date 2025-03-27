#version 120
//----------------------------------------------------INCLUDE----------------------------------------------
//#define WaterSpecularTech
#ifdef WaterSpecularTech
#include "/files/water/water_height.glsl"
#endif
//----------------------------------------------------UNIFORMS----------------------------------------------
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
uniform sampler2D noisetex;
uniform float rainStrength;
uniform sampler2D texture;
varying vec4 texcoord;
//in  float BlockId;
varying vec2 lmcoord;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
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

//#define Rain_Puddle_Old

#define PuddleStrenght 0.85 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

//#define TerrainGradient
#define GradientStrenght 0.7 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GradientTerrainStrenght 0.7 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

//#define MoreLayer

//#define LeavesGradient
#define GradientLeavesStrenght 1 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

//#define GrassGradient
#define GradientGrassStrenght 1 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

#define GradientColorRed 0.5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GradientColorGreen 0.5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GradientColorBlue 0.5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
//#define UseGradientColor

#define waveStrength 0.02; ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

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

  vec3 viewDir = -normalize(viewPos);
  vec3 halfDir = normalize(lightDir + viewDir);
  vec3 reflectDir = reflect(lightDir, viewDir);

    float NdotL = max(dot(TNormals, normalize(shadowLightPosition)), 0.0f);
#ifdef WaterSpecularTech
  vec3 posxz = vworldpos.xyz;


  posxz.x += sin(posxz.z+frameTimeCounter*2)*0.25;
  posxz.z += cos(posxz.x+frameTimeCounter*2*0.5)*1.25;


  float deltaPos = 0.2;
  float h0 = waterH(posxz, frameTimeCounter);
  float h1 = waterH(posxz + vec3(deltaPos,0.0,0.0),frameTimeCounter);
  float h2 = waterH(posxz + vec3(-deltaPos,0.0,0.0),frameTimeCounter);
  float h3 = waterH(posxz + vec3(0.0,0.0,deltaPos),frameTimeCounter);
  float h4 = waterH(posxz + vec3(0.0,0.0,-deltaPos),frameTimeCounter);

  float xDelta = ((h1-h0)+(h0-h2))/deltaPos;
  float yDelta = ((h3-h0)+(h0-h4))/deltaPos;

      vec3 newnormal = normalize(vec3(xDelta,yDelta,1.0-xDelta*xDelta-yDelta*yDelta));
//  float SpecularAngle = pow(max(dot(halfDir, newnormal), 0.0), 2);
    float SpecularAngle = pow(max(dot(halfDir, newnormal), 0.0), 1);
    float SpecularAngle2 = pow(max(dot(halfDir, newnormal*Normal), 0.0), 50);
#else
    float SpecularAngle = pow(max(dot(halfDir, Normal), 0.0), 50);
#endif
    float SpecularAngleRain = pow(max(dot(halfDir, Normal), 0.0), 50);
//---------------------------------------------------CAUSIC-------------------------------------------------

vec4 Albedo = texture2D(texture, TexCoords) * Color;

//----------------------------------------SPECULAR--------------------------------------------------------
if (id == 10008.0 || id == 1) {

if(id == 1){
 Albedo += SpecularAngle/5;
}
#ifdef WaterSpecularTech
Albedo += (SpecularAngle*Albedo)*0.25;
Albedo += (SpecularAngle2*Albedo)*1.0;
#else
//Albedo += (SpecularAngle*Albedo)*0.8;

#endif
if (id == 10008.0){
  Albedo += (SpecularAngle*Albedo)*1;
}
}else{
  if (id == 10010.0){


  Albedo += SpecularAngle;

 //Albedo =  dayColor/2* SimplexPerlin2D(vworldpos.xz/20);

}
}
  vec4 Lightmap = texture2D(lightmap, LightmapCoords);
  float LightmapSmooth =  smoothstep(0.95,smoothstep(0.91,0.95,1.0),lmcoord.y);

vec4 Albedo2 = texture2D(texture, TexCoords) * Color;
 //Albedo2.rgb -= vec3( 0.15);
if (LightmapSmooth > 1.0){
//Albedo2 +=   vec3(1);
}
//Albedo2 *=   texture2D(lightmap, lmcoord)+LightmapSmooth;



//if (LightmapCoords.y < 0.93){
 //Albedo2.rgb += vec3( 0.15);
//}
//--------------------------------------------------------------------------------------------------------

    /* DRAWBUFFERS:0126 */

  //  gl_FragData[0] = Albedo2+(Albedo *LightmapSmooth/2);

     gl_FragData[0] = Albedo2 ;
    gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);
    gl_FragData[3] = vec4(float(BlockID) / 255, 0, 0, 1); //writing the block data to a buffer
}
