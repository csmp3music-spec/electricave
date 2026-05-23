# Gameplay Improvements - 2026-04-08

This pass adds three linked gameplay loops:

1. Stop-level service ratings and crowding pressure.
2. Time-of-day and seasonal demand swings, especially for trolley-park traffic.
3. Monthly operating goals with cash bonuses and penalties.

## Research basis

- OpenTTD Wiki, `Game Mechanics`
  - https://wiki.openttd.org/en/Manual/Game%20Mechanics/
  - Used as the transport-game design precedent for making station quality depend on both recent pickups and the amount waiting at a station. The key sections are the station-rating factors and the way poor ratings cause cargo to be lost or withheld.
- Furth and Muller, `Service Reliability and Hidden Waiting Time: Insights from Automatic Vehicle Location Data`
  - https://journals.sagepub.com/doi/10.1177/0361198106195500110
  - Used for the reliability side of the gameplay loop: waiting cost is not just about mean headway, it is also strongly affected by service reliability, which justifies treating stale service and crowd buildup as separate gameplay penalties.
- National Amusement Park Historical Association, `What is a Trolley Park?`
  - https://napha.org/Resources/Facts-Figures/What-is-a-Trolley-Park
  - Used for the excursion mechanic. NAPHA explicitly describes trolley parks as a way to create weekend demand and extra revenue by drawing riders to line termini outside normal commuting periods.
- Norumbega Park history
  - https://www.norumbegapark.com/html/history.html
  - Used as the local Massachusetts example: Norumbega was built by the Commonwealth Avenue Street Railway to increase patronage and revenues on the Boston-Auburndale trolley route.

## Implementation notes

- `PassengerSim.gd`
  - Adds stop service ratings derived from frequency, connectivity, recent pickup age, and crowding.
  - Adds a network gameplay snapshot for HUD and economy systems.
  - Adds demand multipliers for downtown peak periods and summer/afternoon trolley-park traffic.
- `TownGrowthManager.gd`
  - Uses the new stop service snapshot so good service improves growth and poor crowding suppresses it.
  - Ridership demand is no longer purely a function of bare frequency/connectivity; it is now pulled by actual quality of service.
- `Economy.gd`
  - Generates a rotating monthly goal around service quality, crowding control, or cash reserve.
  - Applies an operating bonus for success or a service-claims penalty for failure.
  - Exposes banner text and goal progress to the UI.
- `HUD.gd`
  - Shows severe crowding warnings when needed.
  - Falls back to monthly-goal banners when no live driving announcement is active.
