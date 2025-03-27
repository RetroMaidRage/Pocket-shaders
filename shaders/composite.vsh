#version 120
//--------------------------------------------UNIFORMS------------------------------------------wwww
varying vec2 texcoord;
varying vec4 glcolor;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec2 TexCoords;
//--------------------------------------------DEFINE------------------------------------------
void main() {
		vec4 position = gl_Vertex;
TexCoords = gl_MultiTexCoord0.st;
gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * position);
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	    Normal = gl_NormalMatrix * gl_Normal;

}
