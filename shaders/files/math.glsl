float pi = 3.14;

float saw1(float t, float amplitude, float frequency, float phase){
    // .5 aligns the start of the wave at 0
    return amplitude * (mod(.5 + t * frequency - phase, 1.) * 2. -1.);
}

vec2 saw2(vec2 uv, float t, float amplitude, float frequency){
    return vec2(uv.x + saw1(uv.y, amplitude, frequency, t), uv.y);
}

float waterWave(vec3 pos, float timefract)
{
float fy = fract(pos.y + 0.001);
float displacement = 0.0;
float wave = 0.085 * sin(2 * pi * (timefract*0.75 + pos.x /  7.0 + pos.z / 13.0)) + 0.085 * sin(1 * pi * (timefract*0.6 + pos.x / 11.0 + pos.z /  5.0));
   displacement = clamp(wave, -fy, 1.0-fy);
	 return pos.y += displacement/6 ;
}
