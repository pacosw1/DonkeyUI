#include <metal_stdlib>
using namespace metal;

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - HSL Helpers
// ─────────────────────────────────────────────────────────────────────────────

half3 rgbToHSL(half3 rgb) {
    half mn = min3(rgb.r, rgb.g, rgb.b);
    half mx = max3(rgb.r, rgb.g, rgb.b);
    half delta = mx - mn;
    half3 hsl = half3(0.0h, 0.0h, 0.5h * (mx + mn));
    if (delta > 0.0h) {
        if (mx == rgb.r) hsl[0] = fmod((rgb.g - rgb.b) / delta, 6.0h);
        else if (mx == rgb.g) hsl[0] = (rgb.b - rgb.r) / delta + 2.0h;
        else hsl[0] = (rgb.r - rgb.g) / delta + 4.0h;
        hsl[0] /= 6.0h;
        if (hsl[2] > 0.0h && hsl[2] < 1.0h)
            hsl[1] = delta / (1.0h - abs(2.0h * hsl[2] - 1.0h));
        else hsl[1] = 0.0h;
    }
    return hsl;
}

half3 hslToRGB(half3 hsl) {
    half c = (1.0h - abs(2.0h * hsl[2] - 1.0h)) * hsl[1];
    half h = hsl[0] * 6.0h;
    half x = c * (1.0h - abs(fmod(h, 2.0h) - 1.0h));
    half3 rgb = half3(0.0h);
    if (h < 1.0h) rgb = half3(c, x, 0.0h);
    else if (h < 2.0h) rgb = half3(x, c, 0.0h);
    else if (h < 3.0h) rgb = half3(0.0h, c, x);
    else if (h < 4.0h) rgb = half3(0.0h, x, c);
    else if (h < 5.0h) rgb = half3(x, 0.0h, c);
    else rgb = half3(c, 0.0h, x);
    return rgb + (hsl[2] - 0.5h * c);
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Shimmer / Shine Sweep
// Diagonal light sweep using HSL lightness boost. Adapted from Inferno.
// ─────────────────────────────────────────────────────────────────────────────

[[ stitchable ]] half4 shimmer(
    float2 position, half4 color, float2 size,
    float time, float duration, float gradientWidth, float maxLightness
) {
    if (color.a == 0.0h) return color;

    float loopedProgress = fmod(time, duration);
    half progress = half(loopedProgress / duration);
    half2 uv = half2(position / size);

    half start = (0.0h - half(gradientWidth))
        + (1.0h + 2.0h * half(gradientWidth)) * progress
        + half(gradientWidth) * uv.y;
    half end = start + half(gradientWidth);

    if (uv.x > start && uv.x < end) {
        half gradient = smoothstep(start, end, uv.x);
        half intensity = sin(gradient * M_PI_H);
        half3 hsl = rgbToHSL(color.rgb);
        hsl[2] = hsl[2] + half(maxLightness * (maxLightness > 0.0f ? 1.0f - float(hsl[2]) : float(hsl[2]))) * intensity;
        color.rgb = hslToRGB(hsl);
    }
    return color;
}
