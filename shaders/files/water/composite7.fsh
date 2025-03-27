#version 120

//--------------------------------------------UNIFORMS------------------------------------------
#include "/files/filters/noises.glsl"
//#define UseTechFog
#ifdef UseTechFog
varying vec4 texcoord;
#else
varying vec4 texcoord
#endif
uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D composite;
uniform vec3 sunPosition;
uniform mat4 gbufferProjection;
uniform int worldTime;
uniform float rainStrength;
uniform float aspectRatio;
uniform float near;
uniform float far;
uniform sampler2D gaux1;
uniform vec3 fogColor;
uniform vec3 shadowLightPosition;
uniform sampler2D colortex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 previousCameraPosition;
uniform vec3 skyColor;
uniform float frameTimeCounter;
uniform int isEyeInWater;
uniform mat4 gbufferModelView;
varying vec2 TexCoords;
//-----------------------------------------DEFINE------------------------------------------------
#define Fog
//#define GroundFog
#define FogDestiny 0.00015 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GroundFogDestiny 0.015  ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define WaterFog
#define LavaFog
/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
const int colortex8Format = RGBA32F;
const int colortex7Format = RGBA32F;
*/
//-----------------------------------------------------------------------------------------------
float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

vec3 sunsetFogColWorld = vec3(1.0,0.9,0.7);
vec3 nightFogColWorld = vec3(0.5,0.6,1.7);

vec3 sunsetFogColSun = vec3(0.5,0.6,1.7)+skyColor;
vec3 nightFogColSun = vec3(0.5,0.6,1.7)+skyColor;

vec3 customFogColorSun = (sunsetFogColSun*TimeSunrise + skyColor*TimeNoon + sunsetFogColSun*TimeSunset + nightFogColSun*TimeMidnight);
vec3 customFogColorWorld = (sunsetFogColWorld*TimeSunrise + skyColor*TimeNoon + sunsetFogColWorld*TimeSunset + nightFogColWorld*TimeMidnight);
//-----------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------
vec3 applyFog( in vec3  rgb, in float distance, in vec3  rayDir, in float coeff, in vec3  sunDir ) {

    float fogAmount = 1.0 - exp( -distance*coeff );
    float sunAmount = max(dot(rayDir, sunDir), 0.0);
    vec3  fogColor  = mix( customFogColorSun, customFogColorWorld, pow(sunAmount,1.0) );
    return mix( rgb, fogColor, fogAmount );

}
//-----------------------------------------------------------------------------------------------

vec3 applyFog2( in vec3  rgb,      // original color of the pixel
               in float distance, // camera to point distance
               in vec3  rayDir,   // camera to point vector
               in vec3  sunDir, in float Fac )  // sun light direction
{
    float fogAmount = GroundFogDestiny*exp(-rayDir.y*0.07+Fac)*(1.0-exp(-distance*rayDir.y*0.07))/rayDir.y;
    //fogAmount += Fac;
    float sunAmount = max( dot( rayDir, sunDir ), 0.0 );
    vec3  fogColor  = mix( vec3(0.5,0.6,0.7)+(vec3(0.5,0.6,1.7)*TimeMidnight), // bluish
                           vec3(1.0,0.9,0.7), // yellowish
                           pow(sunAmount,7.0) );
    return mix( rgb, fogColor, fogAmount );
}
//----------------------------------------------------------------------------------------------
void main() {


//----------------------------------------------------------------------------------------------
	vec3 screenPos = vec3(texcoord.st, texture2D(depthtex0, texcoord.st).r);
	vec3 clipPos = screenPos * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
	vec3 viewPos = tmp.xyz / tmp.w;
	vec4 world_position = gbufferModelViewInverse * vec4(viewPos, 1.0);
	vec3 P_world = (gbufferModelViewInverse * vec4(viewPos,1.0)).xyz + cameraPosition;
  //----------------------------------------------------------------------------------------------
	vec3 L = mat3(gbufferModelViewInverse) * normalize(shadowLightPosition.xyz);
//----------------------------------------------------------------------------------------------
float distancefog = length(world_position.xyz);

vec3 fog = vec3(0);
vec3 rd = normalize(vec3(world_position.x,world_position.y,world_position.z));

float Depth = texture2D(depthtex0, TexCoords).r;
if(Depth == 1.0f){
		gl_FragData[0] =  texture2D(gcolor, texcoord.st);
		return;
}
//----------------------------------------------------------------------------------------------
vec3 color = texture2D(gcolor, texcoord.st).rgb;

float motion = simplex3d_fractal(P_world/30+pow(frameTimeCounter, 0.3));

#ifdef WaterFog
    if (isEyeInWater == 1) {
        color += applyFog(fog, distancefog,  rd, 0.005, L);
    }
#endif
//----------------------------------------------------------------------------------------------
#ifdef LavaFog
    if (isEyeInWater == 2) {
        color += applyFog(fog, distancefog,  rd, 0.005, L);
    }
#endif

#ifdef Fog
color += applyFog(fog, distancefog,  rd, FogDestiny, L)*5;
color += applyFog2(fog, distancefog,  rd, L, motion);
#endif
//color += applyFogGroundOver(fog, distancefogOver, normalize(cameraPosition), rd-Fac, L);
//----------------------------------------------------------------------------------------------
/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color.rgb, 1.0);
}
