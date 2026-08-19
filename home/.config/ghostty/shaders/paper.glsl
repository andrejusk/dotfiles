// Ghostty Custom Shader: Stationery Dot Grid (Font Cell Aligned)
//
// Designed for ultra-crisp, native font rendering across both Retina
// and standard-DPI ultra-wide displays (e.g. CRG9):
//  - Text rendering is 100% untouched native terminal output.
//  - Font-aligned grid: Dots align with terminal character cells and
//    line-height boundaries (1 dot per line height, every 2-space tab stop),
//    offset by window padding.
//  - Adaptive DPI scaling: 1x (CRG9 1440p) vs 2x (Retina) scaling.
//  - Background-only mask: Dots only appear on empty stationery paper.

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;

    // Base terminal sample (untouched native text rendering)
    vec4 src = texture(iChannel0, uv);
    float lum = dot(src.rgb, vec3(0.299, 0.587, 0.114));

    vec3 finalColor = src.rgb;

    if (lum > 0.50) {
        // =========================================================
        // --- LIGHT MODE: CELL-ALIGNED DOTTED STATIONERY ---
        // =========================================================

        // Background paper mask (matches cream page background, isolates text & pills)
        float paperMask = smoothstep(0.78, 0.88, lum);

        if (paperMask > 0.01) {
            // Adaptive DPI scaling: 1x (CRG9 / 1440p) vs 2x (Retina)
            float isRetina = step(1600.0, iResolution.y);
            float dpi = mix(1.0, 2.0, isRetina);

            // Font & Grid Metrics for 14pt Fira Code with 20% cell height:
            // - 1 character cell width: ~8.5px * dpi
            // - Horizontal step: 17px * dpi (1 dot every 2 character columns)
            // - Vertical step: 22px * dpi (1 dot per line height row boundary)
            // - Window padding: 8px X, 6px Y * dpi
            float stepX = 17.0 * dpi;
            float stepY = 22.0 * dpi;
            float padX  = 8.0 * dpi;
            float padY  = 6.0 * dpi;
            float dotRadius = mix(0.85, 1.50, isRetina);

            // Align origin to window padding and top-left terminal cell grid
            float relX = fragCoord.x - padX;
            float relY = (iResolution.y - padY) - fragCoord.y;

            // Distance to nearest cell boundary intersection
            vec2 gridCell = vec2(
                mod(relX + stepX * 0.5, stepX) - (stepX * 0.5),
                mod(relY + stepY * 0.5, stepY) - (stepY * 0.5)
            );
            float dotDist = length(gridCell);
            float dotShape = smoothstep(dotRadius + 0.35, dotRadius - 0.25, dotDist);

            // Soft, delicate graphite journal dot (#C8C0AA tone)
            vec3 dotColor = src.rgb * 0.82;
            vec3 paperWithDots = mix(src.rgb, dotColor, dotShape * 0.45);

            finalColor = mix(src.rgb, paperWithDots, paperMask);
        }
    }

    fragColor = vec4(clamp(finalColor, 0.0, 1.0), src.a);
}
