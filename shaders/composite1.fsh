#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;

//#define OnlyTorches

void main() {

	vec3 color = texture2D(texture, texcoord).rgb;

   float brightness = dot(color, vec3(0.299, 0.587, 0.114));
   bool isBright = brightness > 0.7;

   #ifdef OnlyTorches

      bool isYellow = color.r > 0.6 && color.g > 0.6 && color.b < 0.4;
    #else

       bool isYellow = color.r > 0.9;

       #endif
/* DRAWBUFFERS:4 */

if (isBright && isYellow) {
       gl_FragData[0] = vec4(color, 1.0f);
   } else {
       gl_FragData[0] = vec4(0.0);
   }

}
