# Photoreal Environment Sources

Terrain and vegetation sources used in this pass:

- Poly Haven `Farm Field (Pure Sky)` HDRI for clear sky reference
- Poly Haven `Quadrangle Cloudy` HDRI for overcast/rain sky reference
- Poly Haven `Pine Tree 01` trunk and twig texture set for tree bark and foliage cards

Historical weather basis:

- NOAA / NWS Boston: `The Great Hurricane of 1938`
- NOAA / NWS Upton: `The Great New England Hurricane of 1938`

Notes:

- The game uses local JPG panorama skies loaded at runtime rather than imported HDR sky resources.
- Trees are rendered as textured card-canopy instanced pines, not full downloaded high-poly hero trees, to keep the simulation performant.
- The 1938 hurricane is implemented as a scripted severe coastal weather event with multi-day damage closures on exposed coastal rapid-transit lines.
