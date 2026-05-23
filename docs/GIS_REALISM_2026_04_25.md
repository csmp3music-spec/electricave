## GIS Realism Research Notes

Date: 2026-04-25

Scope:
- Improve regional rendering with more map-like terrain and hydrographic cues.
- Improve the in-game system map so it reads like a compact GIS/cartographic product instead of a plain route overlay.

Applied takeaways:
- Use soft hillshade and ridge emphasis to communicate relief without overpowering the transit overlay.
- Use distinct hydrographic fills and outlines for rivers, lakes, bays, and harbors.
- Use route casing so lines stay legible over textured terrain and water.
- Add standard map surrounds such as a north arrow and scale bar to improve orientation and distance reading.
- Prefer town labeling hierarchy so larger centers stay visible and minor labels are collision-limited.

Source notes:
- ArcGIS hillshade guidance reinforced using shaded relief as a readability layer rather than as heavy terrain geometry.
- ArcGIS scale bar guidance justified a live distance reference tied to the map extent.
- Mapbox hillshade guidance supported using subtle raster-like shaded relief to add depth without obscuring overlays.
- Mapbox line styling guidance supported multi-stroke route rendering that behaves like cartographic casing.

Sources:
- https://pro.arcgis.com/en/pro-app/3.4/tool-reference/spatial-analyst/hillshade.htm
- https://pro.arcgis.com/en/pro-app/latest/help/layouts/scale-bars.htm
- https://docs.mapbox.com/studio-manual/examples/hillshade/
- https://docs.mapbox.com/style-spec/reference/layers/
