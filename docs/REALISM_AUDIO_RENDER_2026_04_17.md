## Realism Pass: April 17, 2026

This pass focused on changes that improve realism without replacing the existing art direction or requiring a full asset rebuild.

### Research Takeaways

1. Godot's current guidance for photorealistic output favors ACES tonemapping, with a white reference in the `6.0` to `8.0` range for more realistic highlight rolloff.
2. Godot recommends combining non-volumetric and volumetric fog when distant atmospheric perspective matters, because volumetric fog alone has finite range.
3. Khronos' PBR guidance still treats roughness as the key control for reflection sharpness and clearcoat as the correct additional glossy layer for wet or coated surfaces.
4. Audiokinetic's obstruction/occlusion guidance reinforces that believable muffling is not just volume; LPF/HPF changes are part of the direct-path model.
5. Audiokinetic's reverb guidance separates early reflections from the reverb tail conceptually; for this project, the practical analogue is to keep dry signal intelligible while raising wet reverb in tunnels and stations.

### Implemented Changes

1. Environment realism
   - Switched the world environment to ACES tonemapping.
   - Tuned sky-driven ambient light, exposure, glow, SSAO, SSR, and volumetric fog defaults.
   - Extended weather response so clear days still carry light aerial haze while rain, snow, storms, and hurricanes drive stronger depth fog and volumetric density.

2. Camera realism
   - Added practical auto-exposure to the strategic camera and the runtime trolley cameras so surface/subway transitions adapt more naturally.

3. Material realism
   - Upgraded terrain sampling to anisotropic texture filtering.
   - Added wet-surface clearcoat response to the terrain and track shaders so rain reads as a second glossy layer instead of only darker albedo and lower roughness.
   - Retuned terrain normal and macro-variation strength slightly upward to keep distant surfaces from looking flat under the new tonemapping.

4. Audio realism
   - Reworked runtime audio into dedicated motor, track, cab, and station buses.
   - Added dynamic low-pass and reverb shaping driven by tunnel depth, station proximity, and weather.
   - Added a low-level cab/body bed layer so the trolley no longer sounds like only two isolated loops.

### Sources

- Godot 4.4 Environment and post-processing: https://docs.godotengine.org/en/4.4/tutorials/3d/environment_and_post_processing.html
- Godot 4 Volumetric fog and fog volumes: https://docs.godotengine.org/en/4.0/tutorials/3d/volumetric_fog.html
- Khronos glTF PBR guide: https://www.khronos.org/gltf/pbr
- Audiokinetic obstruction and occlusion reference: https://www.audiokinetic.com/en/public-library/2024.1.8_8898/?source=SDK&id=soundengine_obsocc.html
- Audiokinetic reverb realism article: https://www.audiokinetic.com/en/blog/adding-realism-to-your-sound-with-impulse-response-reverb/
