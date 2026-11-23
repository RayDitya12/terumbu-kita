#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform float uIntensity;

out vec4 fragColor;

/// Pita cahaya (caustics) bergaya jaring berkilau: dua lapis domain-warp
/// sinusoidal. Puncak cahaya dekat permukaan, memudar mengikuti kedalaman.
void main() {
  vec2 fc = FlutterFragCoord().xy;
  vec2 uv = fc / max(uResolution, vec2(1.0));
  float aspect = uResolution.x / max(uResolution.y, 1.0);
  vec2 p = vec2(uv.x * aspect, uv.y);

  float t = uTime * 0.35;
  vec2 q = p * 3.2;
  q += vec2(sin(q.y * 1.7 + t * 1.3), cos(q.x * 1.9 - t)) * 0.45;
  q += vec2(sin(q.y * 2.3 - t * 0.7), cos(q.x * 2.1 + t * 1.1)) * 0.25;

  float bands = sin(q.x * 2.6 + q.y * 2.2 + t) + sin(q.x * 3.1 - q.y * 1.7 - t * 1.4);
  float glow = pow(max(0.0, 1.0 - abs(bands)), 3.0);

  float depthFalloff = mix(1.0, 0.2, smoothstep(0.0, 1.0, uv.y));
  glow *= depthFalloff * uIntensity;

  vec3 tint = vec3(0.55, 0.85, 0.95);
  fragColor = vec4(tint * glow, glow);
}
