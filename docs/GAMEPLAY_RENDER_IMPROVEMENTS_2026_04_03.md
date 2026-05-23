# Gameplay And Render Improvements - 2026-04-03

This pass focused on two areas:

1. Stronger manual-driving gameplay feedback in the cab HUD.
2. Better material fidelity and safer texture loading for terrain, track, and water rendering.

## Research basis

- Godot 4.6 documentation, `Spatial shaders`
  - https://docs.godotengine.org/en/4.6/tutorials/shading/shading_reference/spatial_shader.html
  - Used to confirm the fragment-stage material outputs now driving the upgraded custom shaders, especially `NORMAL_MAP`, `ROUGHNESS`, `AO`, `SPECULAR`, and the broader spatial shader material pipeline.
- Godot documentation, `ImageTexture`
  - https://docs.godotengine.org/en/stable/classes/class_imagetexture.html
  - Used for the texture-loading correction. The docs explicitly warn to prefer `load()` for imported textures over `Image.load()` when working with project assets, because dynamic filesystem loading can fail in exported projects and bypasses imported texture resources.
- Godot 4.6 documentation, `Import process`
  - https://docs.godotengine.org/en/4.6/getting_started/workflow/assets/import_process.html
  - Used to justify routing project textures through the resource loader so Godot uses the imported `.godot/imported` resources, preserving import settings and export behavior.

## Implementation notes

- Driver gameplay:
  - The cab dashboard now surfaces a dedicated stop approach advisory and a dispatch/headway advisory instead of relying only on the signal and curve lamps.
  - Stop advice is inferred from current speed, next-station distance, dwell state, and headway hold state.
  - Headway advice is inferred from the leader gap and target spacing already tracked by the corridor simulation.
  - The speed indicator now expands to the active line limit and changes warning color when the player is above target, above the speed limit, or braking too late for the next stop.
- Texture/material handling:
  - Runtime texture loading now tries `load(res://...)` first in the terrain controller, corridor seed, and track builder. This keeps imported texture settings such as compression, mipmaps, and export-safe resource resolution instead of rebuilding plain `ImageTexture` objects for project assets.
  - Track materials now use normal maps for the buildable network meshes.
- Shader upgrades:
  - `TrackBlend.gdshader` now uses ballast, sleeper, and rail normal/AO textures, plus wetness and snow uniforms, so the track slab reads less flat and responds to weather.
  - The corridor-side track shader now receives live wet/snow state from the weather sync path.
  - `WaterSurface.gdshader` now adds shoreline tinting, edge foam bias, and a wave-derived normal response so harbor and river surfaces catch light more convincingly.
