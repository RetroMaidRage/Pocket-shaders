#version 120




uniform sampler2D texture;
uniform sampler2D lightmap;
uniform vec4 entityColor;
uniform int entityId;

varying vec4 color;
varying vec4 normal;
varying vec2 lmcoord;
varying vec2 texcoord;

void main() {
   vec4 albedo  = texture2D(texture, texcoord) * color;

   // render thunder
   if(entityId == 1.0){
      albedo.a = 0.15
   }


   // render entity color changes (e.g taking damage)
   albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);


   gl_FragData[0] = albedo;

}
