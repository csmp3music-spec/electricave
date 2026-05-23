# Gameplay Improvements - 2026-05-22

## Research Basis

- OpenTTD makes station rating depend on practical service behavior such as recent pickups and the amount waiting at the station. That supports making line pressure and crowding visible before the player loses riders.
- OpenTTD cargo income also rewards distance and timely delivery, which supports keeping route contracts and operating goals tied to real service movement instead of abstract score.
- A-Train Exp.+ exposes train schedules, station passenger handling, and drive-mode station information, which supports putting operations data next to the controls that change service.
- Transport Fever 2 line statistics surface each line's vehicles, load, frequency, rate, and balance, which supports a per-line performance summary instead of only a global network rating.

## Implemented Changes

- Added a line operations snapshot from `CorridorSeed`: fleet count, stop count, route length, weighted average headway, active vs suggested car count, capacity pressure, worst segment, and recommendation.
- Added line-capacity pressure to the Economy advisor and Finance > Operations tab so the game can recommend adding cars, tightening headways, or rebalancing a named segment.
- Added live line stats to the Operations & Timetable window so the user sees the problem and the controls to fix it in the same panel.

## Sources

- https://wiki.openttd.org/en/Manual/Game%20Mechanics/
- https://wiki.openttd.org/en/Manual/Game%20Mechanics/Cargo%20income
- https://www.artdink.com/manual/aexpplus/english/train19/train19.html
- https://wiki.transportfever2.com/doku.php?id=gamemanual%3Astatisticsdatalayers
