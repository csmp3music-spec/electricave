# Electric Avenue

Electric Avenue is a 1913 Massachusetts electric street railway management sim. This repo is the MVP scaffold built in Godot 4 (GDScript) with hooks for GIS import, historic overlays, seamless zoom camera, track building, economy, passengers, and events.

## Player Manual

For a full end-user guide covering controls, operations, building, growth, and the historical background of the subway and trolley systems in the game, see [docs/GAME_MANUAL.md](docs/GAME_MANUAL.md).

## Quick Start (Godot 4)
1. Open this folder in Godot 4.
2. Run the project; you should see a blank scene with camera controls.
3. Press `C` to cycle camera modes, scroll to zoom, `O` to toggle the historic overlay.
4. Press `T` to toggle stop placement tool. Click to place a stop. Use `]` / `[` or `+` / `-` to adjust frequency.

## Map & GIS Pipeline
The GIS importer is a stub ready for real assets:
- Heightmap GeoTIFF (USGS) -> `data/heightmaps/ma_height.tif`
- OSM PBF -> `data/osm/ma.osm.pbf`
- Historic overlay image -> `assets/maps/historic_overlay.jpg`

Massachusetts bounds are in `data/ma_bounds.tres` and can be refined if needed.

## Project Layout
- `scenes/Main.tscn` – Main scene wiring
- `scripts/geo/*` – GIS importer and geo projection helpers
- `scripts/ui/*` – Camera + overlay systems
- `scripts/builders/*` – Track construction logic
- `scripts/sim/*` – Vehicles, passengers, economy, historical events
- `scripts/sim/town/*` – Transit-driven town growth system (streetcar suburbs)
- `scripts/sim/streets/StreetGenerator.gd` – Main-street grid generator for stop-centered layouts
- `scenes/town/props/StopMarker.tscn` – 3D stop marker with town label
- `data/buildings/default_building_db.tres` – Starter building database resource (placeholder prefabs)
- `scripts/viewers/*` – Street-level view scaffolding
- `assets/maps/*` – Overlay and map assets

## Next Steps
- Drop the historic overlay into `assets/maps/historic_overlay.jpg`.
- Implement GIS import (GDAL/OSM pre-processing or pre-baked data).
- Generate terrain + tile streaming.
- Build track placement tool UI and route editor.
- Add real building prefabs to `BuildingDatabase` and wire era-based swaps.
