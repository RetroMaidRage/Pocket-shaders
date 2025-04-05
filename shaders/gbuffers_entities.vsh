#version 120
varying vec2 LightmapCoords;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 Normal;
varying vec4 glcolor;
 
void main() {
  LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);


	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

		Normal = gl_NormalMatrix * gl_Normal;
}
