#version 120

//--------------------------------------------------------------------------------------------
varying vec4 texcoord;
uniform float wetness;
uniform sampler2D lightmap;
uniform sampler2D texture;
varying vec2 lmcoord;
//--------------------------------------------------------------------------------------------
#define rainPower 0.2 //[0 1 2 3 4 5]
#define VanillaRain
//--------------------------------------------------------------------------------------------
float Raining = clamp(wetness, 0.0, 1.0);
//--------------------------------------------------------------------------------------------
void main() {

vec4 color = texture2D(texture, texcoord.st)*wetness*rainPower;
color *= texture2D(lightmap, lmcoord);

color.r = 1.0;
color.g = 1.0;
color.b = 1.0;
//--------------------------------------------------------------------------------------------

/* DRAWBUFFERS:0 */
#ifdef VanillaRain
	gl_FragData[0] = color; //gcolor
	#endif
}
