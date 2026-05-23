## Passenger and terrain realism pass

Date: 2026-04-30

Goal: improve passenger gameplay feedback and make nearby passengers and terrain read as more physically grounded without adding new external assets.

### Research basis

- Transit waiting research consistently treats waiting time as a major driver of passenger experience. Actual and perceived waits can diverge, especially when service is uncertain, stops are crowded, or passengers have little comfort/information.
- Stop amenities can reduce perceived waiting pain, so the simulation now gives stations and important transfer points a comfort buffer instead of rating every stop by raw frequency alone.
- Godot's PBR material path supports believable real-time materials through restrained albedo, roughness, normals, ambient occlusion, and anisotropic filtering. The terrain pass builds on the existing texture sets rather than introducing unvetted art.
- Godot spatial shaders expose albedo, normal, roughness, specular, clearcoat, and AO outputs, making shader-side terrain variation the right place for slope normals, shoreline grit, and leaf-litter breakup.

### Implementation choices

- Passenger service snapshots now expose perceived wait, amenity score, and lost riders. Crowding and uncertain waits lower ratings more clearly; stations and high-connectivity stops reduce that penalty.
- Bad perceived waits now feed back into the live queue by causing some riders to walk away, so service neglect has a gameplay consequence beyond a lower dashboard number.
- Fallback passenger visuals now have richer roughness/specular treatment, skin/cloth/leather material categories, feet, optional bags, hats, and stronger fidget motion when platforms are stressed.
- Terrain now uses triplanar rock normal blending on slopes, subtle procedural normal breakup, leaf-litter darkening away from shorelines, and shoreline grit so large terrain areas look less tiled.

### Sources

- Passenger wait perception: https://digitalcommons.usf.edu/jpt/vol14/iss3/6/
- Waiting time amenities and perception: https://www.sciencedirect.com/science/article/pii/S0965856416303494
- Godot StandardMaterial3D: https://docs.godotengine.org/en/4.4/classes/class_standardmaterial3d.html
- Godot spatial shaders: https://docs.godotengine.org/en/4.6/tutorials/shading/shading_reference/spatial_shader.html
- Godot environment and post-processing: https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
