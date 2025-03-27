#version 120
uniform sampler2D colortex4;
varying vec2 texcoord;
uniform float blurSize;
uniform float weight[5] = float[] (0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);
#define BloomRadius 128 //[ 8 16 32 48 64 96 128 256 512]
#define BloomIntensity 0.5 //[ 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0]
//#define BiliaterBlurBloom
vec3 BiliaterBlur(vec2 uv) {
  vec3 color = texture2D(colortex4, uv).rgb * 0.2;

   float offset = 0.002; // Увеличенный offset для сильного размытия

   color += texture2D(colortex4, uv + vec2(offset, 0)).rgb * 0.2;
   color += texture2D(colortex4, uv - vec2(offset, 0)).rgb * 0.2;
   color += texture2D(colortex4, uv + vec2(0, offset)).rgb * 0.2;
   color += texture2D(colortex4, uv - vec2(0, offset)).rgb * 0.2;

   // Добавляем диагональные смещения для ещё большего размытия
   color += texture2D(colortex4, uv + vec2(offset, offset)).rgb * 0.1;
   color += texture2D(colortex4, uv - vec2(offset, offset)).rgb * 0.1;
   color += texture2D(colortex4, uv + vec2(-offset, offset)).rgb * 0.1;
   color += texture2D(colortex4, uv + vec2(offset, -offset)).rgb * 0.1;

   return color;
}

void main() {
    vec4 sum = vec4(0.0);
    vec2 tex_offset = texcoord/BloomRadius;
  //   sum.rgb = BiliaterBlur(texcoord);
     for(int i = 1; i < 5; ++i)
           {
               sum.rgb += texture2D(colortex4, texcoord + vec2(tex_offset.x * i, 0.0)).rgb * weight[i];
               sum.rgb += texture2D(colortex4, texcoord - vec2(tex_offset.x * i, 0.0)).rgb * weight[i];
           }

           for(int i = 1; i < 5; ++i)
            {
                sum.rgb += texture2D(colortex4, texcoord + vec2(0.0, tex_offset.y * i)).rgb * weight[i];
                sum.rgb += texture2D(colortex4, texcoord - vec2(0.0, tex_offset.y * i)).rgb * weight[i];
            }

#ifdef BiliaterBlurBloom
sum.rgb = BiliaterBlur(texcoord);
#endif
    /* DRAWBUFFERS:5   */
    	gl_FragData[0] =  sum * BloomIntensity;
}
