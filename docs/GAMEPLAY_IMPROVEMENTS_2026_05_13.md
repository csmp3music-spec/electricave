# Gameplay Improvements - 2026-05-13

## Research Basis

- OpenTTD station mechanics make station rating a core service-quality loop: pickup recency, waiting cargo, and vehicle service quality affect how much demand a station receives and whether cargo/passengers disappear from neglect.
- OpenTTD subsidies create explicit origin-to-destination incentives, giving players a short-term reason to open or improve a specific service instead of only expanding generally.
- A-Train emphasizes railway-company operation with route building, exact service control, and town growth around stations; the useful takeaway for Electric Avenue is to make line operations legible on the map and turn service decisions into visible objectives.

## Implemented Changes

- Added municipal route-link service contracts. These ask the player to serve a named origin stop and then a named destination stop before the offer expires, paying a bonus on success and damages on failure.
- Published stop service data into the system map snapshot: waiting riders, service rating, crowding pressure, perceived wait, and overcrowding state.
- Updated the system map to use stop heat markers and richer hover hints. Stop color now shows service quality and crowding pressure, while hover text shows rating, waiting riders, and perceived wait.

## Sources

- https://wiki.openttd.org/en/Manual/Game%20Mechanics/
- https://wiki.openttd.org/en/Manual/Subsidy/
- https://www.artdink.com/manual/aexpplus/english/about01/about01.html
- https://www.nintendo.com/us/store/products/a-train-all-aboard-tourism-switch/
