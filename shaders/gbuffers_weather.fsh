#version 120

//--------------------------------------------------------------------------------------------
varying vec4 texcoord;
uniform float wetness;
uniform sampler2D lightmap;
uniform sampler2D texture;
varying vec4 glcolor;
//--------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------
float Raining = clamp(wetness, 0.0, 1.0);
//--------------------------------------------------------------------------------------------
void main() {

vec4 color = texture2D(texture, texcoord.st)*glcolor*Raining ;

//--------------------------------------------------------------------------------------------

/* DRAWBUFFERS:0 */

	gl_FragData[0] = color; //gcolor

}
