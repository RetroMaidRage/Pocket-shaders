#version 120

varying vec2 texcoord;
varying vec4 glcolor;
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
uniform vec4 entityColor;
flat in int entID;
uniform sampler2D texture;
uniform sampler2D colortex0;
uniform sampler2D lightmap;
varying vec2 lmcoord;
void main(){

  vec4 albedo  = texture2D(texture, texcoord);

  // render thunder
  if(entID == 1.0){
     albedo.a = 0.15;

  }
  vec4 color = texture2D(texture, texcoord) * glcolor;
  	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
  	//color *= texture2D(lightmap, LightmapCoords);
    /* DRAWBUFFERS:012 */
  // render entity color changes (e.g taking damage)



float cave =  smoothstep(0.915 ,smoothstep(0.91,0.935,1.0 ),LightmapCoords.y);

	gl_FragData[0] = color/1.1  ;
   gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f)    ;
}
