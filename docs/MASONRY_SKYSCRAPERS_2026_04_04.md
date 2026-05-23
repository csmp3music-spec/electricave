# Masonry Skyscrapers - 2026-04-04

This pass adds new spawnable late-19th/early-20th-century masonry skyscraper prefabs to the town growth system.

## Research basis

- Boston Preservation Alliance, `The Ames Building`
  - https://bostonpreservation.org/advocacy-project/ames-building
  - Used for the Boston precedent: Romanesque/Byzantine character, masonry facade, and the idea of a strong stone base with a taller masonry tower above.
- Ames Building Study Report
  - https://bostonpreservation.org/sites/default/files/2024-05/Ames%20Building%20Study%20Report.pdf
  - Used for the explicit massing cue of a granite base below a taller sandstone shaft and a heavy skyline cornice.
- SAH Archipedia, `Monadnock Building`
  - https://sah-archipedia.org/buildings/IL-01-031-0059
  - Used for load-bearing masonry skyscraper proportions, three-sided oriel windows, and the idea of a unified brick shaft capped by a pronounced cornice.
- SAH Archipedia, `Chicago School`
  - https://sah-archipedia.org/Styles/Chicago-School
  - Used for the base-shaft-capital composition and simple geometric massing in brick and terra cotta.

## Implementation notes

- `HistoricMasonrySkyscraperA.tscn` is the heavier Romanesque/Boston tower:
  - dark stone base
  - warm sandstone shaft
  - projecting oriels
  - compact copper roof lantern
- `HistoricMasonrySkyscraperB.tscn` is the more restrained Chicago-school tower:
  - lighter stone base
  - buff brick shaft
  - vertical front piers
  - clear base/shaft/capital read
- Both prefabs are wired into the `commercial_high` building pool so dense station clusters can spawn older masonry towers instead of relying only on the existing generic high-rise set.
