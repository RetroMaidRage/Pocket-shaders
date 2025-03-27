#version 120
#define shadow_buffer
#ifdef shadow_buffer
uniform float viewHeight;
uniform float viewWidth;
#else
uniform float viewHeight
uniform float viewWidth
#endif
varying vec2 TexCoords;
varying vec4 Color;

uniform sampler2D texture;

void main() {
    gl_FragData[0] = texture2D(texture, TexCoords) * Color;
}
