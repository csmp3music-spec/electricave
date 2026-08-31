# Fleet Maintenance Gameplay - 2026-08-31

## Research Basis

- OpenTTD ties reliability and breakdown risk to regular depot servicing. Servicing restores reliability, while neglected vehicles become progressively more likely to fail and disrupt traffic.
- OpenTTD timetables make delays and breakdowns operationally meaningful because one failed vehicle can destroy even spacing and station pickup regularity.
- Transport Fever 2 exposes vehicle condition and lets players spend more on maintenance to prevent deterioration, making maintenance a visible operating tradeoff rather than only a monthly accounting line.

## Implemented Changes

- Every trolley now tracks condition, distance since service, and operating time since service.
- Condition falls primarily with mileage. Below the maintenance threshold the UI marks a car `DUE`; below the critical threshold traction-equipment failures become increasingly likely.
- Mechanical failures stop the car and remove it from effective line capacity. The controlled failed car can receive a paid roadside repair with `K` or the Operations menu.
- Roadside repair restores limited condition. Full depot service restores the car to 100 percent and charges a condition-based `Car maintenance` expense.
- The Operations window, line statistics, bottom HUD, finance advisor, and campaign saves now include maintenance state.
- Seeded fleets begin with varied but serviceable condition, while newly purchased or depot-launched cars begin fully serviced.

## Sources

- https://wiki.openttd.org/en/Manual/Servicing
- https://wiki.openttd.org/en/Manual/Depots
- https://wiki.openttd.org/en/Manual/Timetable
- https://www.transportfever2.com/wiki/doku.php?id=gamemanual:linesvehicles
