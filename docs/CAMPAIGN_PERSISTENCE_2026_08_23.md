# Campaign Persistence - August 23, 2026

This pass closes the largest release-readiness gap in Electric Avenue: campaigns now survive between sessions.

Implemented:

- Versioned JSON campaign saves under the Godot user-data directory.
- Manual save and load commands in the Game menu with `F5` and `F9` shortcuts.
- Three-minute autosaving while the simulation is running.
- Clean-scene restoration to prevent procedural scenery duplication.
- Persistence for finances, goals, contracts, milestones, calendar, passengers, towns, player-built stops, track, depots, signals, line headways, trolley operating state, weather clearance, active service, and driving mode.
- In-game success and error feedback for save/load operations.
- A focused temporary-slot validation script at `tools/validate_save_roundtrip.gd`.

Validation command:

```bash
godot --headless --path . --script res://tools/validate_save_roundtrip.gd
```
