# Improvements Pass — 2026-03-22

Research references used for this pass:

- OpenTTD construction manual: <https://wiki.openttd.org/en/Manual/Construction>
- OpenTTD timetable manual: <https://wiki.openttd.org/en/Manual/Timetable>
- Godot custom GUI controls docs: <https://docs.godotengine.org/en/4.4/tutorials/ui/custom_gui_controls.html>
- Nintendo A-Train: All Aboard! Tourism official page: <https://www.nintendo.com/es-es/Juegos/Programas-descargables-Nintendo-Switch/A-Train-All-Aboard-Tourism-1932860.html>

What those sources suggest:

- Construction-heavy transport games work better when tools are directly selectable with hotkeys, not buried behind a single cycle action.
- Timetable and spacing systems get more legible when stations impose a visible dwell/hold phase instead of instant service.
- Clickable map controls should act directly on the underlying simulation objects, not only reposition the camera.
- Tycoon play needs operating costs and financial feedback that reflect the actual network being built.

Implemented in this pass:

- Dynamic finance tabs now reflect real monthly revenue, monthly operating costs, capital spending, cash, load factor, and service metrics.
- Construction hotkeys `1-5` now directly select `Track`, `Station`, `Depot`, `Signal`, and `Bulldoze`.
- Clicking a trolley on the system map now transfers player control to that car and moves the camera to it.
- Station handling now uses a dwell timer, with extra hold time recommended when the player is bunching the car too closely behind another trolley.
