#version 120

uniform sampler2D texture;
uniform sampler2D depthtex0;
varying vec2 texcoord;
varying vec4 glcolor;
uniform float frameTime;
uniform sampler2D colortex5; //blurred bloom
uniform sampler2D colortex9; //luminance

uniform ivec2 eyeBrightnessSmooth;

const float eyeBrightnessHalflife = 3.0f;
float eyeAdaptY = eyeBrightnessSmooth.y / 240.0;
float eyeAdaptX = eyeBrightnessSmooth.x / 180.0;

#define FastMultipassBloom
//#define ChromaticAberration
//#define Vibrant
//#define AutoExposure
#define ExposureMode 1 //[1 2]

//#define Tonemapping

//#define GammaCorrection
#define Gamma 1.0

vec3 tonemap(vec3 x) { //ACES
  const float a = 2.51;
   const float b = 0.03;
   const float c = 2.43;
   const float d = 0.59;
   const float e = 0.14;
   return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

vec3 getVibrant(vec3 color){
  float sepia = dot(color, vec3(0.299, 0.587, 0.114)); // Яркость
  vec3 vibrantColor = mix(vec3(sepia), color, 1.5); // Усиление цветности
  color = pow(vibrantColor, vec3(1)); // Усиление яркости
  color = mix(vec3(0.5), vibrantColor, 1); // Контраст
     return color;
}

vec3 SetChromaticAberration(vec3 color){
  vec2 center = vec2(0.5, 0.5);
    vec2 direction = texcoord.xy - center;
    float distortion = length(direction) * 2.0; // Усиление эффекта по краям

    vec2 offset = 0.005 * distortion * normalize(direction);

    color.r = texture2D(texture,  texcoord.xy + offset).r;
    color.g = texture2D(texture,  texcoord.xy).g;
    color.b = texture2D(texture,  texcoord.xy - offset).b;
    return color;
}

void main() {
float Depth = texture2D(depthtex0, texcoord.xy).r;
vec3 color = texture2D(texture, texcoord).rgb;

#ifdef ChromaticAberration
color = SetChromaticAberration(color);
#endif
vec3 multipassBloom = texture2D(colortex5, texcoord).rgb;

#ifdef FastMultipassBloom
color = color+multipassBloom ;
#endif

  if(Depth == 1.0f ){ //if it is Sky

      gl_FragData[0] = vec4(color, 1.0f);
      return;
  }

#ifdef AutoExposure

  float sceneLuminance = texture2D(colortex9, vec2(0.5)).r;
  float lastExposure = texture2D(texture, vec2(0.5)).r;

  float targetExposure = clamp(1.0 / (sceneLuminance + 0.001), 0.5, 2.0);
  float newExposure = mix(lastExposure, targetExposure, 1.0 - exp(-frameTime * 0.5));
  if(ExposureMode == 1){
      color *= newExposure;
  }

   if(ExposureMode == 2){

  color *= max(eyeAdaptY , 0.5);

}
#endif


#ifdef Vibrant
color = getVibrant(color);
#endif


#ifdef Tonemapping
color = tonemap(color);
#endif

#ifdef GammaCorrection
color = pow(color, vec3(1.0/ Gamma));
#endif



/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0) ; //gcolor
}
