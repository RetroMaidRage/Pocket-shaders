#version 120

uniform sampler2D texture;
uniform sampler2D depthtex0;
varying vec2 texcoord;
varying vec4 glcolor;

uniform sampler2D colortex5;

#define FastMultipassBloom

void main() {
float Depth = texture2D(depthtex0, texcoord.xy).r;
vec3 color = texture2D(texture, texcoord).rgb;
vec3 multipassBloom = texture2D(colortex5, texcoord).rgb;

vec4 output = vec4(color ,1.0f );

#ifdef FastMultipassBloom
  output = vec4(color ,1.0f )+vec4(multipassBloom ,1.0f ) ;
  #endif
  if(Depth == 1.0f ){ //if it is Sky

      gl_FragData[0] = vec4(color, 1.0f);
      return;
  }
/* DRAWBUFFERS:0 */
	gl_FragData[0] = output; //gcolor
}
