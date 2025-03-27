float interleavedGradientNoise() {
		return fract(52.9829189 * fract(0.06711056 * gl_FragCoord.x + 0.00583715 * gl_FragCoord.y + 0.00623715)) * 0.25;
}

float rand(float n)
{return fract(sin(n) * 43758.5453123);}

float randvec2(vec2 uv){
 return fract(sin(dot(uv, vec2(12.9898,78.233)))*43578.5453);
}

float noisee(float p){
	float fl = floor(p);
  float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}

float hash(in vec2 p)
{
    return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453123);
}

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * 1031);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p){
    vec2 p2 = fract(p * vec2(.1031,.1030));
    p2 += dot(p2, p2.yx+19.19);
    return fract((p2.x+p2.y)*p2);
}

vec2 hash23(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+19.19);
    return fract((p3.xx+p3.yz)*p3.zy);

}

float noise(in vec2 p)
{
    vec2 i = floor(p);
	vec2 f = fract(p);
	f *= f*(3.0-2.0*f);

    vec2 c = vec2(0,1);

    return mix(mix(hash(i + c.xx),
                   hash(i + c.yx), f.x),
               mix(hash(i + c.xy),
                   hash(i + c.yy), f.x), f.y);
}

float fbm(in vec2 p)
{
	float f = 0.0;
	f += 0.50000 * noise(1.0 * p);
	f += 0.25000 * noise(2.0 * p);
	f += 0.12500 * noise(4.0 * p);
	f += 0.06250 * noise(8.0 * p);
	return f;
}


float SimplexPerlin2D( vec2 P )
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/SimplexPerlin2D.glsl

    //  simplex math constants
    const float SKEWFACTOR = 0.36602540378443864676372317075294;            // 0.5*(sqrt(3.0)-1.0)
    const float UNSKEWFACTOR = 0.21132486540518711774542560974902;          // (3.0-sqrt(3.0))/6.0
    const float SIMPLEX_TRI_HEIGHT = 0.70710678118654752440084436210485;    // sqrt( 0.5 )	height of simplex triangle
    const vec3 SIMPLEX_POINTS = vec3( 1.0-UNSKEWFACTOR, -UNSKEWFACTOR, 1.0-2.0*UNSKEWFACTOR );  //  simplex triangle geo

    //  establish our grid cell.
    P *= SIMPLEX_TRI_HEIGHT;    // scale space so we can have an approx feature size of 1.0
    vec2 Pi = floor( P + dot( P, vec2( SKEWFACTOR ) ) );

    // calculate the hash
    vec4 Pt = vec4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += vec2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    vec4 hash_x = fract( Pt * ( 1.0 / 951.135664 ) );
    vec4 hash_y = fract( Pt * ( 1.0 / 642.949883 ) );

    //  establish vectors to the 3 corners of our simplex triangle
    vec2 v0 = Pi - dot( Pi, vec2( UNSKEWFACTOR ) ) - P;
    vec4 v1pos_v1hash = (v0.x < v0.y) ? vec4(SIMPLEX_POINTS.xy, hash_x.y, hash_y.y) : vec4(SIMPLEX_POINTS.yx, hash_x.z, hash_y.z);
    vec4 v12 = vec4( v1pos_v1hash.xy, SIMPLEX_POINTS.zz ) + v0.xyxy;

    //  calculate the dotproduct of our 3 corner vectors with 3 random normalized vectors
    vec3 grad_x = vec3( hash_x.x, v1pos_v1hash.z, hash_x.w ) - 0.49999;
    vec3 grad_y = vec3( hash_y.x, v1pos_v1hash.w, hash_y.w ) - 0.49999;
    vec3 grad_results = inversesqrt( grad_x * grad_x + grad_y * grad_y ) * ( grad_x * vec3( v0.x, v12.xz ) + grad_y * vec3( v0.y, v12.yw ) );

    //	Normalization factor to scale the final result to a strict 1.0->-1.0 range
    //	http://briansharpe.wordpress.com/2012/01/13/simplex-noise/#comment-36
    const float FINAL_NORMALIZATION = 99.204334582718712976990005025589;

    //	evaluate and return
    vec3 m = vec3( v0.x, v12.xz ) * vec3( v0.x, v12.xz ) + vec3( v0.y, v12.yw ) * vec3( v0.y, v12.yw );
    m = max(0.5 - m, 0.0);
    m = m*m;
    return dot(m*m, grad_results) * FINAL_NORMALIZATION;
}

#define round(x) floor( (x) + .5 )

float simplex2D(vec2 p ){
    const float K1 = (sqrt(3.)-1.)/2.;
    const float K2 = (3.-sqrt(3.))/6.;
    const float K3 = K2*2.;

    vec2 i = floor( p + dot(p,vec2(K1)) );

    vec2 a = p - i + dot(i,vec2(K2));
    vec2 o = 1.-clamp((a.yx-a)*1.e35,0.,1.);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + K3;

    vec3 h = clamp( .5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0. ,1. );

    h*=h;
    h*=h;

    vec3 n = vec3(
        dot(a,hash22(i   )-.5),
        dot(b,hash22(i+o )-.5),
        dot(c,hash22(i+1.)-.5)
    );

    return dot(n,h)*140.;
}

float Cloudrand(  vec2 n) {
 return fract(sin(dot(n, vec2(0.360,0.690))) * 1001.585);
}

float Cloudnoise( vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
 u = u*u*(3.0-2.0*u);

	float res = mix(
	 mix(Cloudrand(ip),Cloudrand(ip+vec2(1.0,0.0)),u.x),
	 mix(Cloudrand(ip+vec2(0.0,1.0)),Cloudrand(ip+vec2(1.0,1.0)),u.x),u.y);
 return res*res;
}

float getnoise(vec2 pos) {
	return abs(fract(sin(dot(pos ,vec2(18.9898f,28.633f))) * 4378.5453f));
}

float randomVal (float inVal)
{
		return fract(sin(dot(vec2(inVal, 2523.2361) ,vec2(12.9898,78.233))) * 43758.5453)-0.5;
}

vec2 randomVec2 (float inVal)
{
		return normalize(vec2(randomVal(inVal), randomVal(inVal+151.523)));
}

vec2 rand2(vec2 p)
{
    p = vec2(dot(p, vec2(12.9898,78.233)), dot(p, vec2(26.65125, 83.054543)));
    return fract(sin(p) * 43758.5453);
}

float rand3(vec2 p)
{
    return fract(sin(dot(p.xy ,vec2(54.90898,18.233))) * 4337.5453);
}

vec3 random3(vec3 c) {
	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
	vec3 r;
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}

/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;

/* 3d simplex noise */
float simplex3d(vec3 p) {
	 /* 1. find current tetrahedron T and it's four vertices */
	 /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	 /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/

	 /* calculate s and x */
	 vec3 s = floor(p + dot(p, vec3(F3)));
	 vec3 x = p - s + dot(s, vec3(G3));

	 /* calculate i1 and i2 */
	 vec3 e = step(vec3(0.0), x - x.yzx);
	 vec3 i1 = e*(1.0 - e.zxy);
	 vec3 i2 = 1.0 - e.zxy*(1.0 - e);

	 /* x1, x2, x3 */
	 vec3 x1 = x - i1 + G3;
	 vec3 x2 = x - i2 + 2.0*G3;
	 vec3 x3 = x - 1.0 + 3.0*G3;

	 /* 2. find four surflets and store them in d */
	 vec4 w, d;

	 /* calculate surflet weights */
	 w.x = dot(x, x);
	 w.y = dot(x1, x1);
	 w.z = dot(x2, x2);
	 w.w = dot(x3, x3);

	 /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	 w = max(0.6 - w, 0.0);

	 /* calculate surflet components */
	 d.x = dot(random3(s), x);
	 d.y = dot(random3(s + i1), x1);
	 d.z = dot(random3(s + i2), x2);
	 d.w = dot(random3(s + 1.0), x3);

	 /* multiply d by w^4 */
	 w *= w;
	 w *= w;
	 d *= w;

	 /* 3. return the sum of the four surflets */
	 return dot(d, vec4(52.0));
}

/* const matrices for 3d rotation */
const mat3 rot1 = mat3(-0.37, 0.36, 0.85,-0.14,-0.93, 0.34,0.92, 0.01,0.4);
const mat3 rot2 = mat3(-0.55,-0.39, 0.74, 0.33,-0.91,-0.24,0.77, 0.12,0.63);
const mat3 rot3 = mat3(-0.71, 0.52,-0.47,-0.08,-0.72,-0.68,-0.7,-0.45,0.56);

/* directional artifacts can be reduced by rotating each octave */
float simplex3d_fractal(vec3 m) {
    return   0.5333333*simplex3d(m*rot1)
			+0.2666667*simplex3d(2.0*m*rot2)
			+0.1333333*simplex3d(4.0*m*rot3)
			+0.0666667*simplex3d(8.0*m);
}
