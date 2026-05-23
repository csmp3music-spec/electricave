# UI and Gameplay Control Pass - 2026-05-10

## Research references

- OpenTTD game interface: top menu bar sections for game controls, map, company, vehicle, zoom, construction, and other tools. Source: https://wiki.openttd.org/en/Manual/Game%20interface
- OpenTTD railway construction: construction tools expose autorail, depot, station, signal, remove, and build shortcuts from a construction toolbar. Source: https://wiki.openttd.org/en/Manual/Railway%20construction
- OpenTTD orders and timetables: vehicle orders, current destination, skip/delete/go-to controls, shared orders, and timetables are central to making routes profitable. Source: https://wiki.openttd.org/en/Manual/Orders
- OpenTTD signal building: dragging signal runs and changing signal density reduces repetitive construction. Source: https://wiki.openttd.org/en/Manual/Building%20signals
- A-Train: All Aboard! Tourism: the player acts as railroad company president, laying lines and stations to shape city growth. Source: https://www.artdink.com/games/a-tourism/index.html

## Implemented changes

- Moved the old bottom button strip into a top pulldown menu bar with Game, Build, Operations, View, Company, and Help menus.
- Kept the bottom HUD as a status panel only, matching the transport-sim pattern of top command menus plus bottom running status.
- Added one-click build presets for streetcar stops, subway transfers, interurban work, and terminals. Presets set platform length, track count, signal spacing, headway, and autorail state together.
- Added dispatcher controls in the timetable window for manual/auto driving, line cycling, trolley cycling, headway changes, depot launch/store, and build-mode entry.
- Added public corridor hooks so UI menus can directly switch cab/chase/main cameras and cycle the controlled trolley.

## Design intent

The pass borrows the high-level interaction pattern from Transport Tycoon Deluxe/OpenTTD: persistent top commands, construction submenus, route/timetable control, and quick dispatch actions. It also borrows A-Train's premise that station and line placement should directly steer town growth, so the Build and Operations menus prioritize presets, service line selection, depot actions, and headway control.
