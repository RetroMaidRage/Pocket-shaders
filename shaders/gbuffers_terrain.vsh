#version 120
//#include "/files/filters/noises.glsl"
//--------------------------------------------UNIFORMS------------------------------------------
attribute vec4 mc_Entity;
out vec3 vworldpos;
uniform float frameTimeCounter;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glColor;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
varying vec3 shadowLightPosition;
//out float BlockId;
varying vec3 SkyPos;
uniform float rainStrength;
flat out int BlockID;
uniform sampler2D normals;
varying vec3 NormalWT;
in vec3 at_midBlock;
//--------------------------------------------DEFINE------------------------------------------
#define waving_grass
#define waving_leaves_speed 0.1 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define waving_grass_speed 0.07 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define FakeGrassAO
//#define FakeGrassAOBlock
#define FakeGrassAOIntensity 0.7 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.65 0.7 0.8 0.9 1.0]

const float pi = 3.14f;
varying vec3 viewPos;

float tick = frameTimeCounter;
float Time = max(frameTimeCounter, 1100);

void main() {
		SkyPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
		BlockID = int(mc_Entity.x);
Normal = gl_NormalMatrix * gl_Normal;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

	vec4 position = gl_ModelViewMatrix * gl_Vertex;
  vec4 vpos = gbufferModelViewInverse*position;
  vworldpos = vpos.xyz + cameraPosition;
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    vec4 worldPos = gbufferModelViewInverse * vec4(viewPos, 1.0);

  #ifdef waving_grass
    if (mc_Entity.x == 2.0 || mc_Entity.x == 3.0 || mc_Entity.x == 4.0 || mc_Entity.x == 10015.0 ) {

      float magnitude = sin((tick * pi / (28.0)) + vworldpos.x + vworldpos.z) * 0.055 * (1.0 + rainStrength);


								vpos.x += sin(pow(tick, 1.0))*magnitude;
								vpos.z += sin(pow(tick, 1.0))*magnitude;
																vpos.x += sin(pow(tick, 1.0)+(vworldpos.x + 1.0+Time)+(vworldpos.z + 1.0+Time)+(vworldpos.y + 11.0+Time))*magnitude;
																vpos.z += cos(pow(tick, 1.0)+(vworldpos.x + 1.0+Time)+(vworldpos.z + 1.0+Time)+(vworldpos.y + 11.0+Time)/50)*magnitude;
																vpos.x += sin(pow(tick, 1.0)+(sin(vworldpos.x) + sin(2.0+Time))+(sin(vworldpos.z) + cos(3.0+Time))+(vworldpos.y + 11.0+Time))*magnitude;
																vpos.z += cos(pow(tick, 1.0)+(cos(vworldpos.x) + cos(8.0+Time))+(cos(vworldpos.z) + sin(5.0+Time))+(vworldpos.y + 11.0+Time))*magnitude;
    }



		 if (mc_Entity.x == 1.0 ) {
		 float fy = fract(vworldpos.y + 0.001);

	   if (fy > 0.002)
		 {

		 float displacement = 0.0;
		 float wave = 0.085 * sin(2 * pi * (tick*  0.75 + vworldpos.x /  7.0 + vworldpos.z / 13.0))
                + 0.085 * sin(1 * pi * (tick* 0.6 + vworldpos.x / 11.0 + vworldpos.z /  25.0));
		 displacement = clamp(wave, -fy, 1.0-fy);
																vpos.y += displacement/6* (1.0 + rainStrength);
																Normal.y += displacement/3* (1.0 + rainStrength);
		}
										         }
  #endif





vpos = gbufferModelView * vpos;
gl_Position = gl_ProjectionMatrix * vpos;
    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);

		vec3 worldPos2 = (gl_ModelViewMatrixInverse * gl_Vertex).xyz;



  vec2 InTexCoords = gl_MultiTexCoord0.st  ;

		vec4 pos2 = gl_ModelViewMatrix * gl_Vertex;
		pos2 = gl_ModelViewMatrixInverse * pos2;
		pos2.xyz += at_midBlock / 64.0;
	  Color = gl_Color;




#ifdef FakeGrassAO
				 if ( mc_Entity.x == 2.0){
					 Color  = gl_Color*   smoothstep(0.5, 0 , at_midBlock.y  )+gl_Color*FakeGrassAOIntensity*smoothstep(0, 0.5 , at_midBlock.y  );
				 }
#endif
#ifdef FakeGrassAOBlock
				 if (mc_Entity.x == 5.0){
					 Color  = gl_Color*   smoothstep(0.5, 0 , at_midBlock.y  )+gl_Color*FakeGrassAOIntensity*smoothstep(0, 0.5 , at_midBlock.y  );
				 }
#endif


}
