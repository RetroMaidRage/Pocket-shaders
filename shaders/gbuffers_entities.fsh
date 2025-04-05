#version 120

varying vec2 texcoord;
varying vec4 glcolor;
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
uniform vec4 entityColor;
uniform sampler2D texture;
uniform sampler2D colortex0;
uniform sampler2D lightmap;
varying vec2 lmcoord;
uniform int entityId;

#define RemoveEntityShadow

void main(){

  vec4 albedo  = texture2D(texture, texcoord);

  vec4 color = texture2D(texture, texcoord) * glcolor;
  	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);



  #ifdef RemoveEntityShadow
  if(entityId == 1.0){
  color.a  -= 0.5;
  }
  #endif

    /* DRAWBUFFERS:0128 */

	gl_FragData[0] = color/1.1  ;
  gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
  gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f)    ;
  gl_FragData[3] = vec4(10.0f);

}
