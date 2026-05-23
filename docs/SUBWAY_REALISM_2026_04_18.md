## Subway Realism Pass: April 18, 2026

This pass focused on the parts of the subway that most strongly affect believability in play: wall finish, lighting, traction details, and tunnel/station service elements.

### Research Takeaways

1. The original Tremont Street Subway was a shallow cut-and-cover trolley subway with arched interior treatment, regular ventilation shafts, and incandescent lamps mounted on tunnel and station walls.
2. The Washington Street Tunnel opened on November 30, 1908 for Main Line rapid-transit service, not trolley operation, so a rapid-transit visual language is more accurate there than overhead trolley wire.
3. The East Boston Tunnel opened for streetcars on December 30, 1904, but it was converted to third-rail rapid-transit operation in 1924. Since the in-game line is already represented with rapid-transit rolling stock, third-rail detailing is the correct visual match.
4. The Cambridge subway opened in 1912 as rapid transit and later became the Cambridge-Dorchester line; larger rapid-transit cars and cleaner tiled station finishes are historically consistent there.
5. Historic photographs of Tremont, Summer Street, and East Boston stations consistently show stronger visible fixture hardware, tile/frieze treatment, and service/vent details than a bare box tunnel.

### Implemented Changes

1. Style-specific subway materials
   - Added white-tile, blue-tile, cream-tile, soot-plaster, and dark-grille subway material variants.
   - Reworked Washington, Cambridge, and Blue tunnel/station themes to use more specific wall and tile finishes instead of a shared generic plaster pass.

2. Tunnel realism
   - Non-Tremont tunnels now get a tile wainscot plus a colored frieze band, which makes rapid-transit segments read as finished subway interiors instead of utility corridors.
   - Rapid-transit tunnel styles now use third-rail detail and cable/conduit runs instead of trolley wire.
   - Tremont keeps the trolley wire treatment.

3. Lighting realism
   - Tremont tunnel lighting is now wall-mounted in the tunnel, matching the historic description more closely.
   - Other subway styles use visible centerline fixture hardware with style-aware light tone and brightness instead of only invisible floating omnis.
   - Station lighting now follows style-specific fixture layouts instead of a single generic placement rule.

4. Ventilation and service detail
   - Subway access shafts now have visible top grilles.
   - Rapid-transit tunnels gained additional service/conduit detail along the wall zone.

### Sources

- NPS Tremont Street Subway nomination PDF: https://npgallery.nps.gov/GetAsset/cc3a418b-95a0-41f8-bf6b-7ec357e2fd43
- Boston.gov archive note on the Tremont Street Subway: https://content.boston.gov/news/notes-archives-tremont-street-subway
- Celebrate Boston Tremont Street Subway historic images: https://www.celebrateboston.com/mbta/green-line/tremont-street-subway.htm
- Wikimedia Commons Summer Street / Washington Street Tunnel image page: https://commons.wikimedia.org/wiki/File:Washington_Street_Tunnel_from_Summer_Street_Station,_July_1908.jpg
- Celebrate Boston East Boston Tunnel historic images: https://www.celebrateboston.com/mbta/blue-line/east-boston-tunnel.htm
- MIT Boston Transit Milestones: https://ocw.mit.edu/courses/1-012-introduction-to-civil-engineering-design-spring-2002/pages/readings/green_line_project/
- Seashore Trolley Museum Cambridge-Dorchester history note: https://collections.trolleymuseum.org/items/151
