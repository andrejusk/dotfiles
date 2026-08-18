// Ghostty Custom Shader: Physical Fountain Ink, 3D Letterpress & Dotted Journal
//
// Advanced Stationery & Typography Pipeline:
//  - 3D Intaglio Letterpress: normal-mapped deboss relief with soft directional shading
//    and subtle paper ridge catchlights.
//  - Capillary Ink Bleed & Fiber Feathering: organic liquid ink seep into paper cotton fibers.
//  - Corner Ink Trapping & Liquid Pooling: physical pigment accumulation at stroke junctions.
//  - Archival Iron Gall / Carbon Tonal Depth: rich ink saturation and tonal depth.
//  - Risograph Drum Misregistration: sub-pixel chromatic separation on stroke perimeters.
//  - Bullet-Journal Dotted Grid: crisp anti-aliased graphite dots at 24px pitch.
//  - Heavy Cotton Paper Tooth: ultra-fine per-pixel stationery fiber texture.
//  - Matte Obsidian (Dark Mode): clean velvet contrast with subtle micro-grain.

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 px = 1.0 / iResolution.xy;

    // Base terminal sample
    vec4 src = texture(iChannel0, uv);
    float lum = dot(src.rgb, vec3(0.299, 0.587, 0.114));

    // Gentle radial vignette for soft ambient page warmth
    vec2 centerOffset = uv - 0.5;
    float dist = length(centerOffset);
    float vignette = smoothstep(0.95, 0.20, dist);

    vec3 finalColor = src.rgb;

    if (lum > 0.45) {
        // =========================================================
        // --- LIGHT MODE: EDITORIAL LETTERPRESS & PHYSICAL INK ---
        // =========================================================

        // 1. 8-Tap Directional Neighborhood Sampling for Ink Dynamics & Normal Mapping
        vec4 cN  = texture(iChannel0, uv + vec2(0.0, px.y));
        vec4 cS  = texture(iChannel0, uv - vec2(0.0, px.y));
        vec4 cE  = texture(iChannel0, uv + vec2(px.x, 0.0));
        vec4 cW  = texture(iChannel0, uv - vec2(px.x, 0.0));
        vec4 cNW = texture(iChannel0, uv + vec2(-px.x, px.y));
        vec4 cNE = texture(iChannel0, uv + vec2(px.x, px.y));
        vec4 cSW = texture(iChannel0, uv + vec2(-px.x, -px.y));
        vec4 cSE = texture(iChannel0, uv + vec2(px.x, -px.y));

        float lNW = dot(cNW.rgb, vec3(0.299, 0.587, 0.114));
        float lNE = dot(cNE.rgb, vec3(0.299, 0.587, 0.114));
        float lSW = dot(cSW.rgb, vec3(0.299, 0.587, 0.114));
        float lSE = dot(cSE.rgb, vec3(0.299, 0.587, 0.114));
        float lE  = dot(cE.rgb,  vec3(0.299, 0.587, 0.114));
        float lW  = dot(cW.rgb,  vec3(0.299, 0.587, 0.114));
        float lN  = dot(cN.rgb,  vec3(0.299, 0.587, 0.114));
        float lS  = dot(cS.rgb,  vec3(0.299, 0.587, 0.114));

        // Sobel gradient for continuous 3D surface normal reconstruction
        vec2 grad = vec2(
            (lNE + 2.0 * lE + lSE) - (lNW + 2.0 * lW + lSW),
            (lNW + 2.0 * lN + lNE) - (lSW + 2.0 * lS + lSE)
        );
        float edgeStrength = clamp(length(grad) * 1.3, 0.0, 1.0);

        // 2. 3D Intaglio Letterpress Normal Mapping & Lighting:
        // Debossed intaglio dips down into ink depression (NW ambient shadow, SE subtle catchlight)
        vec3 surfaceNormal = normalize(vec3(grad * 1.3, 0.45));
        vec3 lightDir = normalize(vec3(-0.55, 0.70, 0.85));
        float NdotL = dot(surfaceNormal, lightDir);

        float debossShadow = max(0.0, -NdotL) * edgeStrength * 0.14;
        float debossHighlight = max(0.0, NdotL) * edgeStrength * 0.08;

        // 3. Capillary Ink Bleed & Fiber Feathering:
        // Liquid fountain ink softly seeps along paper cotton fibers
        float fiberNoise = hash(fragCoord.xy * 1.5);
        vec2 fiberSeep = (vec2(fiberNoise, hash(fragCoord.xy * 2.7)) - 0.5) * px * 0.6;
        vec4 seepSrc = texture(iChannel0, uv + fiberSeep);
        
        vec3 diffusedInk = (src.rgb * 4.0 + cN.rgb + cS.rgb + cE.rgb + cW.rgb + seepSrc.rgb * 2.0) * 0.111;
        vec3 inkBase = mix(src.rgb, diffusedInk, 0.40 * edgeStrength);

        // 4. Corner Ink Trapping & Liquid Pooling:
        // Pigment accumulates in stroke intersections, acute corners, and glyph crossbars
        float localDarkness = (8.0 - (lNW + lNE + lSW + lSE + lE + lW + lN + lS)) * 0.125;
        float cornerPool = smoothstep(0.40, 0.85, localDarkness) * (1.0 - lum) * 0.16;

        // 5. Archival Carbon / Iron Gall Pigment Tonal Depth:
        vec3 pigmentTint = vec3(0.96, 0.94, 0.90);
        if (lum < 0.35) {
            inkBase = inkBase * pigmentTint;
        }

        // 6. Subtle Risograph Drum Misregistration:
        float rShift = texture(iChannel0, uv + px * vec2(-0.35, 0.15)).r;
        float bShift = texture(iChannel0, uv + px * vec2(0.35, -0.15)).b;
        vec3 risoColor = mix(inkBase, vec3(rShift, inkBase.g, bShift), 0.22 * edgeStrength);

        // 7. Apply 3D Letterpress Relief Shading & Ink Dynamics
        finalColor = risoColor;
        finalColor -= vec3(cornerPool * 0.85, cornerPool * 0.80, cornerPool * 0.70); // Liquid pooling
        finalColor -= vec3(debossShadow * 0.70, debossShadow * 0.60, debossShadow * 0.50); // NW deboss shadow
        finalColor += vec3(debossHighlight * 0.70, debossHighlight * 0.65, debossHighlight * 0.50); // SE catchlight

        // 8. Background Paper Mask
        float paperMask = smoothstep(0.55, 0.88, lum);

        // 9. Bullet-Journal Dotted Grid (24px pitch, anti-aliased graphite dots)
        vec2 gridCell = mod(fragCoord.xy, 24.0) - 12.0;
        float dotDist = length(gridCell);
        float dotShape = smoothstep(1.6, 0.6, dotDist);
        vec3 dotColor = finalColor * 0.80;
        finalColor = mix(finalColor, dotColor, dotShape * paperMask * 0.70);

        // 10. Heavy Cotton Stationery Micro-Grain (Porous Paper Fiber Tooth)
        float microGrain1 = hash(fragCoord.xy);
        float microGrain2 = hash(fragCoord.xy * 2.3 + vec2(71.2, 19.8));
        float fineGrain = (microGrain1 * 0.65 + microGrain2 * 0.35 - 0.5) * 0.022;
        
        vec3 grainTint = vec3(1.0, 0.96, 0.88);
        finalColor += fineGrain * paperMask * grainTint;
        finalColor += fineGrain * (1.0 - paperMask) * 0.25 * grainTint;

        // 11. Warm Parchment Edge Falloff
        float vigFactor = mix(0.95, 1.0, vignette);
        vec3 warmEdge = mix(vec3(0.97, 0.94, 0.88), vec3(1.0), vigFactor);
        finalColor *= warmEdge;

    } else {
        // =========================================================
        // --- DARK MODE: MATTE OBSIDIAN & VELVET GLOW ---
        // =========================================================
        float darkVig = mix(0.95, 1.0, vignette);
        finalColor = src.rgb * darkVig;

        // Subtle high-frequency tactile grain
        float darkGrain = (hash(fragCoord.xy) - 0.5) * 0.010;
        finalColor += vec3(darkGrain);
    }

    fragColor = vec4(clamp(finalColor, 0.0, 1.0), src.a);
}
