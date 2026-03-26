# Tycoon Build Mode

Implemented on 2026-03-20 for `Electric Avenue`.

## Research basis

- Nintendo official page for A-Train: All Aboard! Tourism:
  - https://www.nintendo.com/us/store/products/a-train-all-aboard-tourism-nintendo-switch-2-edition-switch-2/
  - Used for the idea of a dedicated `Construction` workflow instead of hiding placement behind scattered commands.
- OpenTTD construction manual:
  - https://wiki.openttd.org/en/Manual/Construction
  - Used for the tool breakdown around track, stations, depots, and signals.
- Steam page for OpenTTD:
  - https://store.steampowered.com/app/1536610/OpenTTD/
  - Used for the high-level loop of building network infrastructure to connect towns and services.

## Implementation mapping

The current game now includes a first-pass tycoon construction layer with:

- `Track` building with live cost preview.
- `Station` placement with headway setting.
- `Depot` placement.
- `Signal` placement.
- `Bulldoze` mode with partial refunds.
- Economy-backed capital spending and refunds.
- Snap-to-main-line behavior so expansion starts from the existing corridor.
- Dedicated construction palette in the HUD.

This is intentionally the first operational pass, not a full clone of either game.
