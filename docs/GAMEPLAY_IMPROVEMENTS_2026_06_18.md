# Gameplay Improvements - June 18, 2026

Research notes:

- Transit headway-control literature treats holding at stops as the main practical control for reducing bunching, because a vehicle that is too close to its leader creates a long downstream gap.
- Recent decision-support research on headway control emphasizes that holding must be operationally legible and should consider rider impacts, not only vehicle spacing.
- Bus bunching explanations consistently identify the feedback loop where the late lead vehicle gets more passengers while the following vehicle catches up with lighter loads.

Implemented in this pass:

- Added automated passenger boarding at scheduled stop dwells so non-player cars actually relieve platform crowds and generate passenger revenue.
- Added automated headway holding: cars dwell longer when they are too close to the leader, reducing bunching and downstream gaps.
- Added a crowding override to the hold logic so urgent platform rescues are not delayed by spacing control.
- Prevented automated cars from repeatedly re-entering dwell at the same stop after the dwell timer expires.

Sources:

- https://arxiv.org/abs/2606.12855
- https://arxiv.org/abs/2509.08231
- https://en.wikipedia.org/wiki/Bus_bunching
