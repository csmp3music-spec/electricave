# Transport Tycoon Building Pass

Research references used:

- OpenTTD Manual: <https://wiki.openttd.org/en/Manual/>
- OpenTTD railway construction section from the manual index: signals, stations, junctions, rail designs

What those sources imply for this project:

- Construction tools need to be piece-based and predictable rather than freeform-only.
- Autorail-style path creation matters more than cosmetic UI similarity.
- Station and depot placement should expose orientation and size choices at build time.
- Signal placement should support dragging a run of repeated posts instead of one post per click.

Implemented in this pass:

- Autorail-style L-shaped track routing layered on top of the existing click-anchor build flow.
- Rotatable station and depot placement.
- Station platform length scaling at build time.
- Drag-built signal runs with adjustable spacing.
- HUD hints and hotkeys to make those controls discoverable in-game.
