## Graphic Realism Research Notes

Date: 2026-04-28

Goal:
- Make the world read less like a stylized prototype and more like a grounded outdoor scene without rewriting the renderer or tanking usability.

Applied takeaways:
- Use environment effects that reinforce contact lighting, not just sky color. Screen-space indirect lighting is a subtle complement to SSAO/SSR and helps dynamic detail feel less flat.
- Improve distant sunlight with better directional shadow cascade coverage and softer solar disc lighting.
- Use triplanar sampling on steep terrain materials to avoid texture stretching that immediately breaks realism on slopes and embankments.
- Treat foliage as a thin material instead of opaque cardboard. Back lighting and alpha-to-coverage reduce the cutout look on leaves and branches.

Implementation targets:
- `PhotorealSkyController.gd`: enable and tune SSIL when the environment exposes it.
- `TimeOfDayController.gd`: configure higher-quality directional shadow behavior on the sun.
- `GroundGrid.gdshader` and `TerrainMaterialController.gd`: blend steep rock surfaces toward triplanar sampling.
- `RegionalScenery.gd`: improve foliage transparency and transmitted light response.

Sources:
- https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- https://docs.godotengine.org/en/4.4/tutorials/3d/standard_material_3d.html
- https://docs.godotengine.org/en/4.4/tutorials/3d/3d_antialiasing.html
- https://docs.godotengine.org/en/stable/classes/class_directionallight3d.html
- https://docs.godotengine.org/en/4.5/classes/class_basematerial3d.html
