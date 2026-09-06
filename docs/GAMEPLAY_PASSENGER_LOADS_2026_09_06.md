# Passenger Load Gameplay - September 6, 2026

This pass replaces stateless automated boarding with vehicle-level passenger trips.

## Implemented

- Every operating car owns a passenger manifest grouped by destination stop.
- Boarding is limited by that car's available capacity.
- A full car does not reset a platform's pickup-recency clock or hide unmet demand.
- Destinations are selected from stops ahead in the car's direction of travel, with shorter trips more common.
- Destination passengers alight before new riders board, so capacity changes naturally over the route.
- Passenger exchange contributes to automatic station dwell time.
- Line operations expose onboard riders, total capacity, average load, and crowded-car count.
- High loads contribute to line pressure and produce an add-capacity recommendation.
- Switching controlled cars now shows the selected car's actual load.
- Passenger manifests and trip sequence state round-trip through campaign saves.
- Older saves restore their single onboard count as unassigned through riders who alight progressively.

## Verification

The save-roundtrip test covers capacity limits, destination-specific alighting, and JSON manifest persistence. Full project import and a timed headless scene run verify the integrated automated-service path.
