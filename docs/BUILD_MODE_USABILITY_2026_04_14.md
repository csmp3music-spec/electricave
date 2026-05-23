Build Mode Usability Pass

Research basis
- Nielsen Norman Group heuristic summary: visibility of system status, user control and freedom, recognition rather than recall, flexibility and efficiency of use.
- Nielsen Norman Group heuristic 6 note: make actions and options visible so the player does not have to remember them across screens or time gaps.
- Game Accessibility Guidelines: allow reminder of current objectives during play, allow reminder of controls during play, include contextual in-game help and guidance.

What changed in-game
- Build mode now forces a dedicated top-down orthographic camera instead of reusing the exploration camera.
- The camera restores the previous view when build mode closes, so the user gets a clear exit path instead of a camera trap.
- Build mode now supports edge-pan and arrow-key pan plus wheel zoom, which is materially faster for expansion work than rotating the normal camera around the placement cursor.
- The HUD build panel now surfaces anchor state and explicitly reminds the player that top-down build view is active and how to move it.
- Track build messaging now better reflects the actual two-step workflow: set anchor, then extend.

Files
- [SeamlessCamera.gd](/Users/atarick/Documents/electricave/scripts/ui/SeamlessCamera.gd)
- [StopPlacer.gd](/Users/atarick/Documents/electricave/scripts/ui/StopPlacer.gd)
- [HUD.gd](/Users/atarick/Documents/electricave/scripts/ui/HUD.gd)

Sources
- https://media.nngroup.com/media/articles/attachments/Heuristic_Summary1_A4_compressed.pdf
- https://media.nngroup.com/media/articles/attachments/Heuristic_6_compressed.pdf
- https://gameaccessibilityguidelines.com/indicate-allow-reminder-of-current-objectives-during-gameplay/
- https://gameaccessibilityguidelines.com/indicate-allow-reminder-of-controls-during-gameplay/
- https://gameaccessibilityguidelines.com/intermediate/
