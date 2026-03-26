# Real Geography And Weather Workflow

This project now has a live first-pass weather runtime and a North Shore heavy-rail extension, but the next realism step is to move more of the world off hand-authored control points and onto official GIS and climate sources.

## Data Sources

- MBTA GTFS / static feed documentation for route and stop geometry:
  - https://github.com/mbta/gtfs-documentation
- Massachusetts commuter rail schedules for validating North Shore stop ordering, including Salem:
  - https://cdn.mbta.com/sites/default/files/media/route_pdfs/2025-03-24-cr-newburyport-rockport-line-temporary-construction-schedule.pdf
- USGS 3DEP / National Map elevation services for terrain height:
  - https://www.usgs.gov/faqs/what-types-elevation-datasets-are-available-what-formats-do-they-come-and-where-can-i-download
- MassGIS hydrography for rivers, harbor edges, and lakes:
  - https://www.mass.gov/info-details/massgis-data-massdep-hydrography-125000
- MassGIS place names for station-area labels and town anchors:
  - https://www.mass.gov/info-details/massgis-data-geographic-place-names
- NOAA / NCEI climate normals for Boston precipitation and snowfall tuning:
  - https://www.ncei.noaa.gov/products/land-based-station/us-climate-normals
- NOAA coastal flood tools for Boston Harbor exposure assumptions:
  - https://coast.noaa.gov/floodexposure/

## Recommended Pipeline

1. Import MBTA stop and route geometry from GTFS into `data/` as normalized JSON.
2. Import USGS 3DEP elevation tiles, resample them onto the game world grid, and drive both terrain displacement and track/road vertical placement from the same height field.
3. Import MassGIS hydrography polygons and use them to:
   - block building placement in water
   - define shoreline materials
   - tag portals and low-lying track segments as flood-prone
4. Import MassGIS place names and town centroids to seed realistic station-area growth and landmarks.
5. Tune weather probabilities and seasonal snow/rain intensity against NOAA normals instead of ad hoc values.

## Current Implementation Notes

- The Blue/Salem line added in this pass is an inferred North Shore continuation beyond the current Blue Line. The in-game route uses the existing Blue Line downtown harbor alignment and then continues north using Salem-area rail geography as a playable extension.
- Weather currently affects:
  - fog / sky tone
  - portal closures on coastal lines
  - snow-order speed restrictions
  - snow-plow work cars
- Terrain and route placement are still partially hand-authored. The workflow above is the path to making them data-driven.
