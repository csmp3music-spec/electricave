# Tremont Street Subway Tunnel Notes

Date: 2026-03-29

## Scope

This note captures the visual assumptions used for the Tremont Street Subway tunnel and station shell pass in `CorridorSeed.gd`.

## Source Summary

1. National Park Service NRHP / NHL listing for the Tremont Street Subway confirms the surviving core structure is the original 1897-1898 subway and that Boylston Street Station remains essentially unaltered.
   Source: https://npgallery.nps.gov/AssetDetail/cc3a418b-95a0-41f8-bf6b-7ec357e2fd43
   Source text: https://npgallery.nps.gov/NRHP/GetAsset/NHLS/66000788_text

2. Boston.gov archives note confirms the subway was built under Tremont Street for streetcar congestion relief and opened in 1897, with the original route linking the Public Garden portal and the Haymarket end.
   Source: https://content.boston.gov/news/notes-archives-tremont-street-subway
   Source: https://www.boston.gov/news/onthisday-1895-boston-starts-construction-americas-first-subway

3. Celebrate Boston's historic image page shows the Tremont Street Subway interior at Boylston and describes the line as cut-and-cover construction. The surviving historic interior views read as arched / curved-lined tunnel volumes rather than a plain rectangular trench.
   Source: https://www.celebrateboston.com/mbta/green-line/tremont-street-subway.htm

## In-Game Visual Decisions

1. The Tremont tunnel now uses a segmented curved inner liner instead of flat wall finish panels.

2. Lower walls use a cream tile treatment, while upper vault segments use a darker soot-stained plaster / masonry tone.

3. Mac safe startup mode now keeps the Tremont subway shell active, but drops heavier mezzanine, shaft, surface box, and headhouse geometry so the line remains visible without restoring the full startup geometry load.

## Limits

1. This is still an inferred in-engine reconstruction, not a surveyed mesh of the actual tunnel profile.

2. The material set reuses local Boston texture libraries with Tremont-specific tinting; no new scanned Tremont texture atlas was imported in this pass.
