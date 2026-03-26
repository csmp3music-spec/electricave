# Gameplay Improvements

Research references used for this pass:

- NIMBY Rails official Steam page: <https://store.steampowered.com/app/1134710/NIMBY_Rails/>
- NIMBY Rails signaling devblog: <https://carloscarrasco.com/nimby-rails-september-2025/>
- Quaternius animated character pack reference: <https://quaternius.com/packs/ultimateanimatedcharacter.html>
- Mixamo character and animation library reference: <https://www.mixamo.com/>

What those sources suggest:

- Transit play gets stronger when demand is visible and tied to station behavior.
- Signaling matters more when the player is reading the line ahead while also managing stops.
- Character packs are useful for future passenger upgrades, but the gameplay loop should not wait on external art.

Implemented in this pass:

- Waiting passengers now appear at stations as animated crowd groups.
- Stations now act as service points instead of scenery.
- The controlled trolley must slow to platform speed to board passengers.
- Boarding clears part of the waiting crowd and applies fare revenue.
- HUD now shows waiting demand, onboard load, and recent boarding results.

Next upgrades worth building:

- Headway adherence and on-time service bonuses.
- Passenger satisfaction penalties for skipping stations at speed.
- Larger station crowds and more detailed passengers using imported rigged models.
- Dwell-time audio/announcements and platform ambience.
