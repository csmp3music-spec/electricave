# Regional Building And Safety Pass

Research basis used for this pass:

- Federal Transit Administration safety advisory on street-running rail collisions and signal overruns:
  - <https://www.transit.dot.gov/regulations-and-programs/safety/street-running-rail-collisions-safety-advisory-24-2>
- National Transportation Safety Board MBTA Green Line rear-end collision investigation:
  - <https://www.ntsb.gov/investigations/Pages/RIR-22-10.aspx>
- City of Framingham historic preservation context for preserved downtown and civic stock:
  - <https://www.framinghamma.gov/306/Historic-Preservation>
- City of Worcester Union Station historical context:
  - <https://www.worcesterma.gov/worcester-rediscovers/transportation/union-station>
- MassGIS hydrography and route corridor terrain references already used elsewhere in the project:
  - <https://www.mass.gov/info-details/massgis-data-massdep-hydrography-125000>

Implementation decisions:

- Building stock was expanded with corridor-relevant archetypes instead of generic boxes:
  - Boston triple-decker
  - Route 9 shop block
  - Framingham/Worcester mill block
  - town hall / civic block
  - Worcester station-style civic block
- Placement was made more regional:
  - Boston core stops bias toward denser commercial and civic uses
  - streetcar suburbs bias toward medium-density housing and mixed local retail
  - western centers bias toward civic, commercial, and industrial mill stock
  - steep slopes now reject most building placement
- Vegetation and hills are driven from the Route 9 backdrop data:
  - visible hill masses for named terrain features
  - tree scatter around hills, shorelines, and town outskirts
- Failure modes are deterministic instead of random:
  - derailment on overspeed through tight curves
  - rear-end collision when running into traffic ahead
  - manual recovery action after an incident
