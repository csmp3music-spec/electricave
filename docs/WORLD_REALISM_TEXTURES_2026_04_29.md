## World realism pass

Date: 2026-04-29

Goal: push the overworld closer to a photographic Massachusetts landscape by fixing the lowest-fidelity systems first: flat roads, flat primitive buildings, uniform conifer forests, stylized lake water, and the absence of roadside/field stone walls.

### Research basis

- Godot StandardMaterial3D and BaseMaterial3D support the practical PBR features needed here: normal maps, roughness maps, anisotropic texture filtering, texture repeat, and triplanar/world-triplanar projection for large procedural meshes where authored UVs are weak or absent.
- Godot spatial shaders are the right place for water because the lake and river meshes are generated procedurally and need angle-dependent highlights, depth-like color absorption, and wave motion without unique authored assets.
- Khronos glTF PBR guidance remains the baseline for believable materials: the big gains come from calibrated albedo, roughness, normal detail, and restrained metallic use, not from saturated color pushes.
- Godot environment/post-processing guidance still applies at the world level: material work reads better when the scene uses physically plausible reflections and ambient response, so this pass builds on the prior environment tuning rather than replacing it.

### Implementation choices

- Roads now use real asphalt/cobble/soil texture sets rather than flat albedo colors. Urban and suburban streets get asphalt carriageways with stone/cobble edges; rural streets get softer shoulders plus low field-stone walls.
- Primitive town prefabs now receive runtime PBR materials based on mesh role and zoning category, while imported historic GLB assets are left alone. That improves the weakest buildings without flattening the better authored ones.
- Forests now mix a broadleaf canopy archetype into the existing conifer pass, with shoreline-biased broadleaf density so woods near lakes and rivers read less synthetic.
- Water shader tuning now emphasizes calmer lake swells, smaller high-frequency ripples, stronger depth absorption, and glancing-angle reflections instead of foam-heavy stylization.

### Sources

- Godot StandardMaterial3D: https://docs.godotengine.org/en/4.4/classes/class_standardmaterial3d.html
- Godot spatial shaders: https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html
- Godot environment and post-processing: https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- Khronos glTF PBR overview: https://www.khronos.org/gltf/pbr
