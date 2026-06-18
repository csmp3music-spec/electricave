# Gameplay Improvements - May 24, 2026

Research notes:

- OpenTTD station rating rewards frequent pickup and penalizes long pickup gaps and large waiting cargo piles, making service regularity a central gameplay pressure.
- Transport Fever 2 exposes line load, frequency, rate, and balance so players can diagnose which service is failing instead of guessing from global score alone.
- Mini Metro's core tension comes from visible station overcrowding pressure that demands immediate rerouting or dispatch decisions.

Implemented in this pass:

- Added station overcrowding rescue timers to `PassengerSim`. Overcrowded stops now accumulate pressure, expose seconds remaining, and escalate from watch state into urgent rescue state.
- Added recent rescue events when the player serves an overcrowded platform before it clears. `Economy` claims those events and pays a `Crowding rescue bonus`.
- Added rescue-aware advisor, announcement, and Operations-tab text so the player sees the exact stop, waiting crowd, and seconds left.

Sources:

- OpenTTD station rating mechanics: https://wiki.openttd.org/en/Manual/Game%20Mechanics/
- Transport Fever 2 statistics and data layers: https://www.transportfever2.com/wiki/doku.php?id=gamemanual%3Astatisticsdatalayers
- Mini Metro overview and overcrowding loop: https://en.wikipedia.org/wiki/Mini_Metro_(video_game)
