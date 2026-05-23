Boston / Eastern Massachusetts GIS Terrain Pass

What I used
- USGS elevation products as the baseline reference for real-world relief and hydro-derived terrain behavior, specifically The National Map elevation stack / NED lineage and 3DEP program context.
- USGS National Hydrography Dataset as the reference model for major river centerlines, estuaries, and waterbody topology.
- MassGIS elevation-point and terrain-model documentation as the Massachusetts-specific grounding for how bare-earth elevation is published and reduced in-state.
- MassGIS hydrography layers as the Massachusetts-specific grounding for shoreline, streams, and water polygons.

Implementation approach
- The game does not ship a raw DEM raster or shapefile import pipeline yet. Instead, the active terrain system now uses a reduced GIS control mesh in [route9_features.json](/Users/atarick/Documents/electricave/data/route9_features.json).
- That dataset stores real lat/lon anchors for major hills, ridge chains, rivers, harbor polygons, bays, lakes, and reservoirs in the Boston-Worcester-Lowell-South Shore play area.
- Elevations are stored as real-world meters, then compressed in [Route9Backdrop.gd](/Users/atarick/Documents/electricave/scripts/sim/world/Route9Backdrop.gd) with a nonlinear function before they hit the render terrain. This is deliberate: full real vertical relief would bury or float existing legacy route geometry.
- River and harbor meshes are now generated from actual polyline / polygon features instead of cylinders, and the terrain sampler carves lowlands and shore bands against those features.
- The ground shader now receives vertex color context for elevation, shoreline proximity, river floodplain proximity, and coastal proximity, so the same texture set can render drier uplands, silty banks, floodplains, and coastal sand more plausibly.

Important simplification
- This is GIS-derived terrain, not a raw 1:1 raster DEM import.
- The water polygons and river centerlines are low-resolution in-engine reductions inferred from official USGS / MassGIS datasets and public map geometry.
- Boston shoreline and harbor shapes are approximate play-space reductions, not survey-grade harbor polygons.

Primary source links
- USGS The National Map - Elevation: https://www.usgs.gov/index.php/publications/national-map-elevation
- USGS National Hydrography Dataset: https://www.usgs.gov/index.php/national-hydrography/national-hydrography-dataset
- USGS 3D Elevation Program: https://www.usgs.gov/3d-elevation-program
- MassGIS Digital Elevation Points from 1990's Aerial Imagery: https://www.mass.gov/info-details/massgis-data-digital-elevation-points-from-1990s-aerial-imagery
- MassGIS MassDEP Hydrography (1:25,000): https://www.mass.gov/info-details/massgis-data-massdep-hydrography-125000
