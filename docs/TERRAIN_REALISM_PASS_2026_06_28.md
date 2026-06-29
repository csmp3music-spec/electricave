# Terrain Realism Pass

Implementation date: 2026-06-28

## Sources

- Godot spatial shader reference: https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html
- Godot MultiMesh optimization notes: https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh.html
- Godot decal documentation, used as research context for terrain projection tradeoffs: https://docs.godotengine.org/en/stable/tutorials/3d/using_decals.html

## Implemented Changes

- Added a procedural ground-detail layer to `RegionalScenery`.
- Added batched `MultiMeshInstance3D` assets for:
  - mixed grass clumps near stations, hills, and shore edges
  - reeds at lake, pond, and river margins
  - small upland stones on higher terrain
- Ground details are placed from existing terrain context, not random global scatter. The layer checks water, route clearance, stop clearance, and feature type before placing instances.
- Added weather response for grass, reeds, and stones so rain darkens and lowers roughness, while snow/frost cools and desaturates the detail materials.

## Notes

The pass avoids new downloaded texture files because the current volume is space-constrained. Detail geometry is procedural and batched, following Godot's recommended MultiMesh approach for large numbers of simple repeated objects.
