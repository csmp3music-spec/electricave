GUI and gameplay improvements implemented on April 13, 2026.

Research basis

- Visibility of system status: the player should always be able to tell what state the system is in and what needs attention next.
- Recognition over recall and progressive disclosure: controls and next steps should be visible in the interface instead of hidden in memory or the console.
- Accessible guidance: short plain-language instructions, highlighted priorities, and persistent objective reminders improve comprehension and reduce friction.

Implemented changes

- Added a live dispatcher/advisor panel in the HUD that shows system priority, network summary, a recommended next action, the monthly goal, and the next milestone.
- Replaced the console-only help printout with an in-game help window that groups the controls into startup, camera, build, and driving sections.
- Renamed the finance-side service tab into an operations-oriented view so the player sees goals, milestones, stop quality, and crowding instead of only passive pricing data.
- Added once-only progression milestones with bonus cash so expansion and service cleanup produce short-term rewards beyond the monthly report.
- Added tooltips to major buttons and controls so the interface explains itself without requiring memorized hotkeys.
- Improved status visibility by surfacing pause and simulation speed directly in the bottom status panel.

Implementation files

- scripts/sim/Economy.gd
- scripts/ui/HUD.gd
