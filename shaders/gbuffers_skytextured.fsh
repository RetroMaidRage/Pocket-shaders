#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;
uniform float wetness;
const float wetnessHalflife = 700.0f;
const float drynessHalflife = 100.0f;

float Raining =  clamp(wetness, 0.0, 1.0);
void main() {

	vec4 color = texture2D(texture, texcoord)-Raining;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}
