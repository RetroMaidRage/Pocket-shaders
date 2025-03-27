#version 120
out vec3 vworldpos;
varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
varying vec2 texcoord;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
void main() {
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
  vec4 vpos = gbufferModelViewInverse*position;
  vworldpos = vpos.xyz + cameraPosition;
 
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	gl_Position = ftransform();
	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));
}
