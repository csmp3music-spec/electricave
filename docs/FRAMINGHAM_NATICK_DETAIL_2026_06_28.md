# Framingham and Natick B&W Detail Pass

Implementation date: 2026-06-28

## Sources

- User reference photos: `/Users/atarick/Downloads/IMG_0117 2.JPG`, `/Users/atarick/Downloads/IMG_0116.JPG`, `/Users/atarick/Downloads/IMG_0115.JPG`
- Boston and Worcester Street Railway route history: https://en.wikipedia.org/wiki/Boston_and_Worcester_Street_Railway
- Wellesley Hills station location context: https://en.wikipedia.org/wiki/Wellesley_Hills_station

## Implemented Changes

- Changed the B&W through-line Natick stop from `Natick Center` to `Natick Junction`, reflecting the map and the documented split point for the Natick branch.
- Added a local Natick branch from `Natick Junction` to `Natick Center` and `Natick Common`, following the documented Natick Junction to Natick Common shuttle pattern.
- Reworked the Framingham branch list so `Framingham Junction` feeds `Saxonville`, while `Framingham Center` feeds `South Framingham`.
- Added a Framingham Junction to South Framingham connector segment to represent the Concord Street route shown in the reference map.
- Added visible landmark labels for `Natick Common Terminal`, `Natick Junction Branch`, `Saxonville Branch`, and `South Framingham Transfer`.
- Added new car-barn landmarks at `Framingham Center` and `Wellesley Hills`, in addition to the existing Trolley Square/Framingham Junction car barn.

## Notes

The exact depot footprints are approximated for gameplay and visual legibility. The route topology follows the documented branch relationships and the supplied map photos, while coordinates use practical in-game anchors near the historic corridors.
