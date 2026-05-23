# Gameplay Contracts Research Notes - 2026-05-11

## References

- OpenTTD subsidies use time-limited public offers that reward the first company to provide a specific service before expiration, then pay bonus rates for the awarded service: https://wiki.openttd.org/en/Manual/Subsidy
- OpenTTD orders emphasize explicit vehicle instructions, depot servicing, loading rules, timetables, shared orders, and order-problem warnings as the core of transport management: https://wiki.openttd.org/en/Manual/Orders
- Transport Fever describes its fun loop around meeting city needs, dynamic passenger/city simulation, missions, campaign tasks, and clear construction tools: https://www.transportfever.com/game-info/overview/
- Transport Fever features call out fleet management, missions with multiple solution paths, passenger decisions, and an intuitive UI/tutorial layer: https://www.transportfever.com/game-info/features/
- A-Train: All Aboard! Tourism frames stations as catalysts for town growth and tourist access as a measurable network objective: https://store.steampowered.com/app/1685460/ATrain_All_Aboard_Tourism/

## Implemented Loop

Electric Avenue now adds service contracts on top of the existing passenger, economy, and advisor systems. Contracts are active timed objectives picked from live network conditions:

- Build the first depot if the line has stops but no carhouse.
- Add another car when the fleet is too small for the stop count.
- Relieve the worst severe crowding stop when platforms are overloaded.
- Raise average stop rating and keep crowding controlled once the network is running.

Contracts pay through the finance ledger as `Service contract bonus` or charge `Contract damages` on failure. The active contract is shown in the gameplay banner, advisor panel, and Finance > Operations tab so the player has a clear short-term objective beyond sandbox expansion.

## Design Rationale

This borrows OpenTTD's subsidy pressure without needing a separate freight/city-pair UI yet. It borrows Transport Fever and A-Train's stronger "serve demand to make the city thrive" framing by tying objectives to live stop queues, reliability, depots, and fleet capacity. The loop is meant to make each session produce an immediate operational decision: build, launch, improve headway, or relieve a bottleneck.
