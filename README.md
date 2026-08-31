# Electric Avenue

Electric Avenue is a playable 1913 Massachusetts electric street railway management and driving sim built in Godot 4. It combines a seeded historical network, manual trolley operation, automated service, construction, passengers, fleet maintenance, company finances, town growth, weather, incidents, progression contracts, and persistent campaigns.

## Player Manual

For a full end-user guide covering controls, operations, building, growth, and the historical background of the subway and trolley systems in the game, see [docs/GAME_MANUAL.md](docs/GAME_MANUAL.md).

## Quick Start (Godot 4)
1. Open this folder in Godot 4.
2. Run the project; the historical network and operating fleet seed automatically.
3. Press `C` to cycle camera modes, scroll to zoom, `O` to toggle the historic overlay.
4. Press `T` to toggle stop placement tool. Click to place a stop. Use `]` / `[` or `+` / `-` to adjust frequency.
5. Press `F5` to save the campaign and `F9` to restore the latest save. The game also autosaves every three minutes.
6. Press `R` to watch car condition, service cars on depot leads, and manage failures before they disrupt the line.

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

## Release Development

The current build is a complete sandbox loop with persistence. Future release work is focused on content depth: pre-baked GIS terrain tiles, more historically specific rolling stock and architecture, scenario campaigns, accessibility settings, and performance tuning for dense districts.
