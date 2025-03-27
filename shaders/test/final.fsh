#version 120

#include "/files/filters/dither.glsl"

uniform float frameTimeCounter;
uniform float viewHeight;
uniform float viewWidth;
varying vec2 TexCoords;
uniform vec3 sunPosition;
uniform mat4 gbufferProjection;
uniform sampler2D colortex0;
uniform float rainStrength;
uniform vec3 fogColor;
uniform vec3 skyColor;
#define COLORCORRECT_RED 1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_GREEN 1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_BLUE 1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]

#define GammaSettings 2.2f  //[1.0f 1.1f 1.2f 1.3f 1.4f 1.5f 1.6f 1.7f 1.8f 1.9f 2.0f 3.0f 4.0f 5.0f 6.0f]

//#define CROSSPROCESS

#define Desaturation

#define VanillaColors

//#define EasyBloom
#define EasyBloomSamples 2 //[2 4 6 8 10 12]

//#define GodraysO
#define Sunrays
#define SUNRAYS_SAMPLES 12 //[1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 48 64 128 256 512 1024] //64
#define Sunray_Decay .974  //[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define Sunray_Exposure .04  //[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ] //.1
#define Sunray_Weight .25  //[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define Sunray_Density .95
//----------------------------------------------------------------

void main() {
	 #ifdef VanillaColors
   vec3 color2 = pow(texture2D(colortex0, TexCoords).rgb, vec3(1.0f / GammaSettings));
	 #else
	 vec3 color = pow(texture2D(colortex0, TexCoords).rgb, vec3(1.0f / GammaSettings));
	 #endif

  // vec2 GetSreenRes = vec2(viewWidth, viewHeight);

  // vec2 uv = gl_FragCoord.xy / GetSreenRes.xy - 0.5;
  // uv.x *= GetSreenRes.x/GetSreenRes.y; //fix aspect ratio

//   vec4 tpos = vec4(sunPosition,1.0)*gbufferProjection;
//   tpos = vec4(tpos.xyz/tpos.w,1.0);
//   vec2 LightPos = tpos.xy/tpos.z;
 //------------------------------------------------------------------------------------------------------------------
   #ifdef CROSSPROCESS
     color.r = (color.r*COLORCORRECT_RED);
       color.g = (color.g*COLORCORRECT_GREEN);
       color.b = (color.b*COLORCORRECT_BLUE);

     color = color / (color + 2.2) * (1.0+2.0);
   #endif
   //------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
#ifdef EasyBloom
vec4 bloom = vec4(0,0,0,0);
		for (int i = 1; i < EasyBloomSamples; i++){
		        bloom += textureLod(colortex0, TexCoords, float(i)) / float(i);
				#ifdef VanillaColors
				color2.rgb += bloom.rgb * 0.02;
				#else
				color.rgb += bloom.rgb * 0.02;
				#endif
}
#endif
//------------------------------------------------------------------------------------------------------------------
#ifdef Desaturation
     float Fac = 0.0;
     Fac = 0.3*clamp(rainStrength, 0.0, 1.0);

vec3 gray = vec3( dot( color2.rgb , vec3( 0.2126 , 0.7152 , 0.0722 )));
color2 = vec3( mix( color2.rgb , gray , Fac)  );

#endif
//----------------------------------------------------------------
vec4 tpos = vec4(sunPosition,1.0)*gbufferProjection;
tpos = vec4(tpos.xyz/tpos.w,1.0);
//----------------------------------------------------------------
vec2 LightPos = tpos.xy/tpos.z;
//------------------------BLUR--------------------------------
#ifdef Sunrays
    int Samples = 128;
    float Intensity = 0.125, Decay = 0.96875;
    vec2 TexCoord = TexCoords, Direction = vec2(0.5) - TexCoord;
    Direction /= Samples;
    vec3 Color = texture2D(colortex0, TexCoord).rgb;
	// vec3 Color = pow(texture2D(colortex0, TexCoords).rgb, vec3(1.0f / GammaSettings));

    for(int Sample = 0; Sample < Samples; Sample++)
    {
        Color += texture2D(colortex0, TexCoord).rgb * Intensity;
        Intensity *= Decay;
        TexCoord += Direction;
    }
#endif
//----------------------------------------------------------------
#ifdef GodraysO

	vec2 Godrays = LightPos*0.5+0.5;
	vec2 coord = TexCoords;
	float occ =  texture2D(colortex0, coord).x;
	vec2 dtc = (coord - Godrays) * (1. / float(SUNRAYS_SAMPLES) * Sunray_Density);
		 float illumdecay = 1.;

		 for(int i=0; i<SUNRAYS_SAMPLES; i++)
		 {
				 coord -= dtc;
				   float dither = fract(frameTimeCounter + bayer256(gl_FragCoord.xy));
           float s = texture(colortex0, coord+(dtc*dither)).x;
					// float s = texture(colortex0, coord).x;

				 s *= illumdecay * 	Sunray_Weight;
				 occ += s;
				 illumdecay *= .974;
		 }

#endif

#ifdef VanillaColors
      gl_FragColor = vec4(color2, 1.0f);//*vec4(Color, 1.0f);
#ifdef GodraysO
    gl_FragColor = vec4(color2, 1.0f)+occ*vec4(fogColor, 1.0f)*Sunray_Exposure;//*vec4(Color, 1.0f);
		#endif

	 #ifdef Sunrays
	    gl_FragColor = vec4(color2, 1.0f)*vec4(Color, 1.0f);
			#endif
#else
 gl_FragColor = vec4(color, 1.0f);
 #endif
}
